"""Power-cycle the sensor rig via a Shelly smart plug.

Usage: python shelly_cycle.py --host <plug-ip> [--off-seconds 8]

Needed after any DFU session: dfu-util's "leave" does not reset the STM32,
so sensor USB will not re-enumerate without a full power cycle. Works with
Gen2+ (RPC) and Gen1 (HTTP relay) Shelly plugs. Manual unplug/replug is an
equally valid substitute on benches without a smart plug.
"""

import argparse
import time
import urllib.error
import urllib.request


def _get(url: str, timeout: float = 5.0) -> bytes:
    with urllib.request.urlopen(url, timeout=timeout) as r:
        return r.read()


def set_relay(host: str, on: bool) -> None:
    want = "true" if on else "false"
    try:
        _get(f"http://{host}/rpc/Switch.Set?id=0&on={want}")  # Gen2+ RPC
        return
    except urllib.error.URLError:
        pass
    _get(f"http://{host}/relay/0?turn={'on' if on else 'off'}")  # Gen1


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Power-cycle the rig via a Shelly smart plug."
    )
    ap.add_argument("--host", required=True, help="Shelly plug IP or hostname")
    ap.add_argument(
        "--off-seconds",
        type=float,
        default=8.0,
        help="how long to hold power off (default 8 s)",
    )
    args = ap.parse_args()

    set_relay(args.host, False)
    time.sleep(args.off_seconds)
    set_relay(args.host, True)
    print(f"power-cycled rig via {args.host} (off {args.off_seconds:.0f} s)")


if __name__ == "__main__":
    main()
