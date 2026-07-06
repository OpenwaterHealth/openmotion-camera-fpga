"""Capture one lossless full-frame image (1920x1280, 10-bit) from every camera
by streaming one line per camera frame through the histogram SPI envelope.

Usage:
  python capture.py --bitstream <path.bit> --out captures --scene dark
  python capture.py --bitstream <path.bit> --out captures --scene laser --skip-program
Options: --sides left,right   --cams 0,1,...,7   --skip-program
"""
import argparse
import json
import queue
import threading
import time
from pathlib import Path

import numpy as np
from omotion import MotionInterface
import omotion.MotionProcessing as _MP
from omotion.MotionProcessing import parse_histogram_packet_structured

from fpga_link import (FpgaRegs, MAGIC, force_program_fpga,  # noqa: F401
                       upload_bitstream, upload_program_fpga)

# The SDK parser validates every sample against a fixed histogram photon-count
# sum and drops mismatches. Image-line packets (and histogram packets after an
# image session) have arbitrary sums — disable the check for capture tooling.
_MP.EXPECTED_HISTOGRAM_SUM = None

WIDTH, HEIGHT, PAIRS = 1920, 1280, 960
EXPECTED_SIZE = 32833


def setup_trigger(console, scene: str, freq_hz: float = 40.0):
    """Configure the console trigger: SyncOut drives the sensors' FSIN on
    this harness, so BOTH scenes need the trigger running. TA (laser) firing
    is enabled only for the laser scene."""
    import json as _json
    cfg = console.get_trigger_json()
    if isinstance(cfg, str):
        cfg = _json.loads(cfg)
    cfg["EnableSyncOut"] = True
    cfg["EnableTaTrigger"] = (scene == "laser")
    cfg["TriggerFrequencyHz"] = float(freq_hz)
    out = console.set_trigger_json(data=cfg)
    assert out, "set_trigger_json failed"
    print(f"[trigger] {out}")


def decode_line(hist: np.ndarray):
    """hist: uint32[1024] from a HistogramSample. Returns (line, row) or None
    if the packet is not an image packet (no magic in word 2's spacer)."""
    spac = (hist >> 24) & 0xFF
    if int(spac[2]) != MAGIC:
        return None
    line = int(spac[0]) | ((int(spac[1]) & 0x0F) << 8)
    pairs = hist[:PAIRS] & 0xFFFFFF
    row = np.empty(WIDTH, np.uint16)
    row[0::2] = (pairs & 0x3FF).astype(np.uint16)
    row[1::2] = ((pairs >> 10) & 0x3FF).astype(np.uint16)
    return line, row


class CameraAccum:
    def __init__(self):
        self.rows = {}
        self.temps = []
        self.n_packets = 0

    def add(self, sample):
        d = decode_line(sample.histogram)
        if d is None:
            return
        line, row = d
        self.n_packets += 1
        if line < HEIGHT:
            self.rows[line] = row
        t = float(sample.temperature_c)
        if np.isfinite(t):
            self.temps.append(t)

    def missing(self):
        return sorted(set(range(HEIGHT)) - set(self.rows))

    def image(self):
        img = np.zeros((HEIGHT, WIDTH), np.uint16)
        for ln, row in self.rows.items():
            img[ln] = row
        return img


def capture_side(sensor, side, cams, timeout_s=90, retry_rounds=5):
    """Stream image-line packets from all cams on one sensor until every line
    of every camera is collected (or retries exhausted). Returns {cam: CameraAccum}.

    NOTE: the FPGA control plane is clocked from the MIPI-derived pixel clock,
    so register access only works while the camera is streaming — enable
    first, then talk I2C."""
    accum = {c: CameraAccum() for c in cams}
    regs = {c: FpgaRegs(sensor, c) for c in cams}
    mask = 0
    for c in cams:
        mask |= 1 << c

    q = queue.Queue()
    stop = threading.Event()

    def consume():
        # USB delivers multi-camera packets (~32 KB) split across reads:
        # accumulate and let the parser's bytes_consumed drive the cursor.
        buf = bytearray()
        while not stop.is_set() or not q.empty():
            try:
                buf += q.get(timeout=0.2)
            except queue.Empty:
                continue
            while True:
                sof = buf.find(b"\xaa")
                if sof < 0:
                    buf.clear()
                    break
                if sof:
                    del buf[:sof]
                try:
                    pkt = parse_histogram_packet_structured(memoryview(buf))
                except Exception:
                    # incomplete (or garbage) — wait for more data unless the
                    # buffer is absurdly large, then resync past this SOF
                    if len(buf) > 4 * EXPECTED_SIZE:
                        del buf[:1]
                        continue
                    break
                for s in pkt.samples:
                    if s.cam_id in accum:
                        accum[s.cam_id].add(s)
                del buf[:max(pkt.bytes_consumed, 1)]

    sensor.uart.histo.flush_stale_data(expected_size=EXPECTED_SIZE)
    sensor.uart.histo.start_streaming(q, expected_size=EXPECTED_SIZE)
    t = threading.Thread(target=consume, daemon=True)
    t.start()
    assert sensor.enable_camera(mask), f"{side}: enable_camera failed"
    time.sleep(1.0)  # MIPI clock + control plane come up with streaming

    live = []
    for c in cams:
        ok = regs[c].check_id()
        print(f"  [{side}] cam{c} control plane: {'OK' if ok else 'NO ANSWER'}")
        if ok:
            regs[c].set_image_mode(start_line=0)
            live.append(c)
    cams = live
    for c in list(accum):
        if c not in live:
            del accum[c]

    def total_missing():
        return sum(len(accum[c].missing()) for c in cams)

    t0 = time.time()
    last_progress, last_missing = time.time(), total_missing()
    while time.time() - t0 < timeout_s:
        time.sleep(1.0)
        m = total_missing()
        if m == 0:
            break
        if m < last_missing:
            last_missing, last_progress = m, time.time()
        elif time.time() - last_progress > 5.0:
            break  # stalled — fall through to retry rounds

    for rnd in range(retry_rounds):
        gaps = {c: accum[c].missing() for c in cams if accum[c].missing()}
        if not gaps:
            break
        print(f"  [{side}] retry round {rnd + 1}: "
              + ", ".join(f"cam{c}:{len(g)} missing" for c, g in gaps.items()))
        for c, g in gaps.items():
            regs[c].set_line(g[0])  # auto-inc replays from the first gap
        deadline = time.time() + 40
        while time.time() < deadline and any(accum[c].missing() for c in cams):
            time.sleep(1.0)

    for c in cams:
        try:
            regs[c].set_histogram_mode()  # while clock still runs
        except IOError:
            pass
    sensor.disable_camera(mask)
    stop.set()
    sensor.uart.histo.stop_streaming()
    try:
        sensor.uart.histo.drain_final(expected_size=EXPECTED_SIZE)
    except Exception:
        pass
    t.join(timeout=3)
    return accum


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bitstream", default=None,
                    help="unused at runtime — bitstream is flash-resident "
                         "(see update_bitstream.py); kept for provenance")
    ap.add_argument("--out", default="captures")
    ap.add_argument("--scene", required=True, choices=["dark", "laser"])
    ap.add_argument("--sides", default="left,right")
    ap.add_argument("--cams", default="0,1,2,3,4,5,6,7")
    ap.add_argument("--skip-program", action="store_true")
    a = ap.parse_args()
    sides = [s for s in a.sides.split(",") if s]
    cams = [int(c) for c in a.cams.split(",")]
    cam_mask = 0
    for c in cams:
        cam_mask |= 1 << c
    out = Path(a.out) / a.scene
    out.mkdir(parents=True, exist_ok=True)

    # Console is needed for BOTH scenes: its trigger SyncOut drives FSIN.
    iface = MotionInterface(data_dir=str(out / "sdk_data"))
    iface.start(wait=True, wait_timeout=2.0)
    iface.wait_for_ready(console=True, sensors=len(sides), timeout=20)
    sensors = {}
    for s in sides:
        sen = getattr(iface, s)
        assert sen is not None and sen.uart is not None, f"{s} sensor not connected"
        sensors[s] = sen

    prepared = {}
    for s, sen in sensors.items():
        print(f"[{s}] camera power on (mask 0x{cam_mask:02X})")
        assert sen.enable_camera_power(cam_mask), f"{s}: power-on failed"
        if not a.skip_program:
            # Pure-SDK path (validated on hardware): upload the bitstream once
            # into the sensor's RAM buffer, then a verified forced ISC program
            # per camera (~12 s each; the firmware realigns USART receivers
            # after each program).
            assert a.bitstream, "--bitstream required unless --skip-program"
            print(f"[{s}] uploading bitstream ...")
            assert upload_bitstream(sen, a.bitstream), f"{s}: upload failed"
            for c in cams:
                ok = upload_program_fpga(sen, c)
                print(f"[{s}] cam{c} FPGA program: {'OK' if ok else 'FAILED'}")
        print(f"[{s}] configuring sensor registers")
        assert sen.camera_configure_registers(cam_mask), f"{s}: config failed"
        # Control-plane ID checks happen inside capture_side once streaming
        # runs (the FPGA register interface needs the MIPI-derived clock).
        prepared[s] = (sen, cams)

    if a.scene == "laser":
        print("[laser] applying laser power config")
        assert iface.apply_laser_power(), "apply_laser_power failed"
    setup_trigger(iface.console, a.scene)
    for s, (sen, _) in prepared.items():
        assert sen.enable_camera_fsin_ext(), f"{s}: enable FSIN ext failed"
    assert iface.console.start_trigger(), "start_trigger failed"

    results = {}
    try:
        threads = {}
        for s, (sen, good) in prepared.items():
            th = threading.Thread(
                target=lambda s=s, sen=sen, good=good:
                    results.__setitem__(s, capture_side(sen, s, good)))
            th.start()
            threads[s] = th
        for th in threads.values():
            th.join()
    finally:
        iface.console.stop_trigger()
        for s, (sen, _) in prepared.items():
            sen.disable_camera_fsin_ext()

    from PIL import Image
    meta = {"scene": a.scene,
            "captured_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "width": WIDTH, "height": HEIGHT, "bit_depth": 10,
            "scaling": "none — raw 10-bit sensor values 0..1023 in 16-bit files",
            "cameras": {}}
    for s, acc in results.items():
        for c, a_ in acc.items():
            img = a_.image()
            key = f"{s}_cam{c}"
            np.save(out / f"{key}.npy", img)
            Image.fromarray(img).save(out / f"{key}.png")
            meta["cameras"][key] = {
                "lines_received": len(a_.rows),
                "missing_lines": a_.missing(),
                "temperature_c_median": (float(np.median(a_.temps))
                                          if a_.temps else None),
                "temperature_c_last": a_.temps[-1] if a_.temps else None,
                "image_packets_seen": a_.n_packets,
            }
            print(f"[{key}] {len(a_.rows)}/{HEIGHT} lines, "
                  f"median temp {meta['cameras'][key]['temperature_c_median']}")
    (out / "meta.json").write_text(json.dumps(meta, indent=2))
    print(f"done -> {out}")


if __name__ == "__main__":
    main()
