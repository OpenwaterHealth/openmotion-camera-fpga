"""Update the FPGA bitstream stored in a sensor module's STM32 flash.

The firmware programs camera FPGAs from an embedded bitstream at flash
sectors 5-6 of bank 2 (ADDR_CAMERA_BITSTREAM = 0x081A0000, exactly 163489
bytes streamed by fpga_configure). The firmware's host-upload programming
path is broken in 1.8.x (xi2c_write_long clobbers its own source buffer), so
the reliable zero-firmware-change route is to rewrite those two flash sectors
over DFU and let the stock programming path load our image.

Sector 7 (motion_config + hardware serial) is above this region and is not
touched. The previous sector content is backed up first for exact restore.

Usage:
  python update_bitstream.py <bitstream.bit> --side left [--backup-dir backups]
  python update_bitstream.py --restore backups/bitstream_left.bin --side left
"""
import argparse
import subprocess
import sys
import time
from pathlib import Path

from omotion import MotionInterface
from omotion.DFUProgrammer import DFUProgrammer

BITSTREAM_ADDR = "0x081A0000"
BITSTREAM_LEN = 163489


def find_dfu_util(prog: DFUProgrammer) -> Path:
    return Path(prog._dfu_util_base_args()[0])


def wait_sensor_back(iface, side, timeout=30):
    t0 = time.time()
    while time.time() - t0 < timeout:
        c, l, r = iface.is_device_connected()
        if (side == "left" and l) or (side == "right" and r):
            sen = getattr(iface, side)
            if sen.uart is not None:
                return sen
        time.sleep(0.5)
    raise TimeoutError(f"{side} sensor did not re-enumerate after DFU")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bitstream", nargs="?")
    ap.add_argument("--restore", help="restore a backup file instead")
    ap.add_argument("--side", required=True, choices=["left", "right"])
    ap.add_argument("--backup-dir", default="backups")
    a = ap.parse_args()

    payload = Path(a.restore) if a.restore else Path(a.bitstream)
    assert payload.is_file(), f"payload not found: {payload}"
    size = payload.stat().st_size
    if not a.restore:
        assert size == BITSTREAM_LEN, (
            f"bitstream is {size} B, expected exactly {BITSTREAM_LEN} B — "
            "firmware streams exactly that many bytes")

    iface = MotionInterface(data_dir="dfu_out")
    iface.start(wait=True, wait_timeout=2.0)
    iface.wait_for_ready(console=False, sensors=1, timeout=15)
    sensor = getattr(iface, a.side)
    assert sensor.uart is not None, f"{a.side} sensor not connected"
    print(f"[{a.side}] fw version: {sensor.get_version()}")

    prog = DFUProgrammer(vidpid="0483:df11")
    dfu_util = find_dfu_util(prog)

    print(f"[{a.side}] entering DFU mode ...")
    assert sensor.enter_dfu(), "enter_dfu failed"
    time.sleep(5.0)
    assert prog.wait_for_dfu_device(timeout_s=30), "DFU device never appeared"

    if not a.restore:
        Path(a.backup_dir).mkdir(parents=True, exist_ok=True)
        backup = Path(a.backup_dir) / f"bitstream_{a.side}.bin"
        print(f"[{a.side}] backing up current sector content -> {backup}")
        r = subprocess.run(
            [str(dfu_util), "-d", "0483:df11", "-a", "0",
             "-s", f"{BITSTREAM_ADDR}:{BITSTREAM_LEN}",
             "-U", str(backup)],
            capture_output=True, text=True, timeout=120)
        if r.returncode != 0 or not backup.is_file():
            print(r.stdout)
            print(r.stderr)
            raise RuntimeError("backup upload failed — NOT flashing")
        print(f"[{a.side}] backup OK ({backup.stat().st_size} B)")

    # Step 1: download WITHOUT leave (a leave here would jump into the
    # bitstream address — that is exactly what wedged the left sensor).
    print(f"[{a.side}] flashing {payload.name} at {BITSTREAM_ADDR} (no leave) ...")
    res = prog.flash_bin(payload, address=BITSTREAM_ADDR, leave=False,
                         usb_reset=False, echo_output=True)
    assert res.success, f"DFU flash failed (rc={res.returncode})"

    # Step 2: verify by reading the sectors back and comparing byte-for-byte.
    verify = Path(a.backup_dir) / f"verify_{a.side}.bin"
    verify.unlink(missing_ok=True)
    r = subprocess.run(
        [str(dfu_util), "-d", "0483:df11", "-a", "0",
         "-s", f"{BITSTREAM_ADDR}:{size}", "-U", str(verify)],
        capture_output=True, text=True, timeout=120)
    assert r.returncode == 0 and verify.is_file(), "verify upload failed"
    assert verify.read_bytes() == payload.read_bytes(), (
        "READBACK MISMATCH — flash content differs from payload; "
        "NOT leaving DFU. Investigate before rebooting this sensor.")
    print(f"[{a.side}] readback verified ({size} B identical)")

    # Step 3: leave DFU with the jump target at the FIRMWARE base — a
    # zero-length DfuSe download at 0x08000000 with :leave, the same exit the
    # stock full-firmware flash flow uses. No erase happens for a 0-byte file.
    empty = Path(a.backup_dir) / "_empty.bin"
    empty.write_bytes(b"")
    r = subprocess.run(
        [str(dfu_util), "-d", "0483:df11", "-a", "0",
         "-s", "0x08000000:leave", "-D", str(empty)],
        capture_output=True, text=True, timeout=60)
    print(r.stdout[-400:] if r.stdout else "")

    print(f"[{a.side}] waiting for sensor to come back ...")
    sensor = wait_sensor_back(iface, a.side, timeout=60)
    print(f"[{a.side}] back online, fw {sensor.get_version()}")
    print("UPDATE OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
