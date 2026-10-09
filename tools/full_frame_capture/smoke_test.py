"""Bring-up smoke test: program the new bitstream into ONE camera's FPGA SRAM,
verify the I2C control plane, verify histogram mode still streams.

Usage: python smoke_test.py <bitstream.bit> [--side left] [--cam 0]
"""
import argparse
import queue
import sys
import time

from omotion import MotionInterface

from capture import setup_trigger
from fpga_link import FpgaRegs, force_program_fpga


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bitstream", nargs="?", default=None,
                    help="unused at runtime — bitstream is flash-resident "
                         "(see update_bitstream.py); kept for provenance")
    ap.add_argument("--side", default="left", choices=["left", "right"])
    ap.add_argument("--cam", type=int, default=0)
    ap.add_argument("--skip-program", action="store_true",
                    help="skip SRAM programming (already loaded)")
    a = ap.parse_args()

    iface = MotionInterface(data_dir="smoke_out")
    iface.start(wait=True, wait_timeout=2.0)
    iface.wait_for_ready(console=True, sensors=1, timeout=15)
    sensor = iface.left if a.side == "left" else iface.right
    assert sensor.uart is not None, f"{a.side} sensor not connected"
    mask = 1 << a.cam

    print(f"[1/5] power on cam {a.cam}")
    assert sensor.enable_camera_power(mask), "camera power-on failed"

    if a.skip_program:
        print("[2/5] skipping FPGA programming (--skip-program)")
    else:
        # Bitstream lives in the sensor's flash (update_bitstream.py); the
        # cameras are NVCM-programmed so a FORCED SRAM load is required.
        print("[2/5] force-load FPGA from flash-resident bitstream (~10 s)")
        assert force_program_fpga(sensor, mask), "force load failed"
        time.sleep(0.3)
    print(f"[2b] configure sensor registers:")
    assert sensor.camera_configure_registers(mask), "sensor config failed"

    print("[3/5] I2C control plane")
    regs = FpgaRegs(sensor, a.cam)
    assert regs.check_id(), "ID register != 0x5A — I2C slave not answering"
    assert regs.read(0x01) == 0x01, "VERSION mismatch"
    assert regs.scratch_test(), "SCRATCH write/read failed"
    print("      ID/VERSION/SCRATCH OK")

    print("[4/5] histogram mode still works (default mode)")
    setup_trigger(iface.console, "dark")   # SyncOut on, TA (laser) off
    assert sensor.enable_camera_fsin_ext(), "fsin ext failed"
    q = queue.Queue()
    sensor.uart.histo.flush_stale_data(expected_size=32833)
    sensor.uart.histo.start_streaming(q, expected_size=32833)
    assert sensor.enable_camera(mask), "enable_camera failed"
    assert iface.console.start_trigger(), "start_trigger failed"
    got = None
    t0 = time.time()
    while time.time() - t0 < 5:
        try:
            got = q.get(timeout=0.5)
            break
        except queue.Empty:
            pass
    assert got, "no histogram packet in 5 s"
    print(f"      histogram packet OK ({len(got)} B), FRAME_CNT={regs.frame_count()}")

    print("[5/5] image mode round-trip (packets flow, line counter advances)")
    regs.set_image_mode(start_line=0)
    time.sleep(2.0)
    cur = regs.get_line()
    assert cur > 0, f"line counter did not advance (still {cur})"
    print(f"      line counter advanced to {cur}")
    regs.set_histogram_mode()
    iface.console.stop_trigger()
    sensor.disable_camera_fsin_ext()
    sensor.disable_camera(mask)
    sensor.uart.histo.stop_streaming()
    print("SMOKE TEST PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
