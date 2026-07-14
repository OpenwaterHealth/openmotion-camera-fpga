# Full-frame capture runbook (validated 2026-07-05 night)

## Proven end-to-end recipe

From `tools/full_frame_capture/` (both sensors + console on USB):

1. Dark scene (trigger runs with laser/TA off; SyncOut drives FSIN):
   `python capture.py --bitstream validated_bitstream\HistoFPGAFw_impl1_2026-07-05.bit --out captures --scene dark`
2. Laser scene:
   `python capture.py --bitstream <same> --out captures --scene laser --skip-program`
   (`--skip-program` only if no camera power cycle since the previous run —
   FPGA images are SRAM/volatile and are SDK-uploaded at capture time)
3. `python report.py --captures captures --out captures/report.html`

~40 lines/s per camera, all 8 per sensor in parallel → ~35 s + programming
(~12 s/camera when needed). Outputs: lossless `.npy` (uint16 1280x1920, raw
10-bit values) + 16-bit PNG + `meta.json` (temps, missing lines) + report.

Run `python smoke_test.py` first on any fresh setup or after firmware/bench
changes.

## Replicating on a fresh test setup

Everything required is on this branch (`feature/5-i2c-line-readout`);
Lattice Diamond is NOT needed if you use the committed validated bitstream.

1. **Host (Windows):** Python 3.13 + `numpy`, with the `omotion` SDK
   importable (`pip install -e <openmotion-sdk checkout>`). Validated
   against the 2026-07-04 SDK tree (`0eee01e`); any current `next` works —
   the tooling needs only `MotionInterface` +
   `parse_histogram_packet_structured`, and it patches the SDK's
   histogram-sum check at runtime. Sensor USB driver = WinUSB via Zadig
   (VID 0x0483 / PID 0x5A5A); the console uses the OS VCP driver.
2. **Sensor firmware — REQUIRED PATCH.** Stock firmware cannot program
   host-uploaded bitstreams (sensor-fw#82: `xi2c_write_long` clobbers its
   own source buffer, so the SRAM path programs zeros). Flash BOTH sensors
   with firmware built from openmotion-sensor-fw branch
   `fix/82-sram-upload-path` (validated at `e9d3b1a`), **Debug
   configuration only** (Release images have not booted on this hardware),
   via sensor-fw's `deploy.py`. Gotchas:
   - Close any app holding the sensor USB before flashing.
   - dfu-util's "leave" does not reset the STM32 — a full power cycle is
     required before the sensor re-enumerates (see `shelly_cycle.py`, or
     unplug/replug).
3. **Bitstream:** `validated_bitstream/HistoFPGAFw_impl1_2026-07-05.bit` is
   the exact image behind the 2026-07-05 dataset (SHA256
   `6aeebe3ff8270b14bdb7ed35c77e3cc9f8d259664dc7a3fadbbd19ec7468a2cb`).
   To rebuild instead: `HistoFPGAFw/synth.tcl` via pnmainc (Diamond 3.14).
4. **Power-cycling:** manual unplug/replug, or a Shelly smart plug +
   `python shelly_cycle.py --host <plug-ip>` (the original bench's plug is
   192.168.1.81).
5. **Flash safety:** the capture flow uploads the bitstream to FPGA SRAM
   only (volatile) — it does NOT touch a sensor's flash bitstream sector.
   Only `update_bitstream.py` writes flash (0x081A0000); it saves the
   pre-flash sector to `--backup-dir` (default `backups/`), and
   `--restore <file> --side <side>` puts the original back.
6. **Dataset hygiene:** capture outputs are gitignored — archive them
   outside the repo. The original dataset + analysis reports live at
   `Projects/investigations/full_frame_readout_2026-07-05/`; the
   self-contained handoff doc is `captures/DATASET_REPORT.md` (tracked on
   this branch).

## Original bench state (2026-07-05) — for the record

- Both sensors ran `1.8.1-rc.3-dirty` = tag + the `fix/82-sram-upload-path`
  patch set.
- Bitstream built from this branch; includes the bring-up fixes: SDA/SCL
  pin swap (legacy LPF had them backwards), control plane on the
  MIPI-derived clock (the OSCI HF oscillator never runs in these builds),
  self-releasing resets (firmware holds the GPIO0 external-reset net low
  permanently), GSR inference off.
- Both original-bench sensors still hold an intermediate image in the
  flash bitstream sector; exact restore images are committed in `backups/`
  (`python update_bitstream.py --restore backups/bitstream_<side>.bin --side <side>`).

## Hard-won facts (also in issues #5/#6, sensor-fw#82, PR #7)

- FPGA register access works ONLY while the camera streams (control plane is
  clocked from the MIPI clock). Order: enable_camera → I2C. The capture
  script handles this.
- The SDK's `send_bitstream_fpga` 1 KB blocks always get rejected (512 B
  comms RX buffer) — use `fpga_link.upload_bitstream` (500 B blocks).
- The SDK parser drops samples on a fixed histogram-sum check — capture.py
  disables `EXPECTED_HISTOGRAM_SUM` (image packets have arbitrary sums).
- USART-based cameras come out of FPGA programming with a bit-shifted
  receiver (data × 2^n) unless the firmware's post-program USART realign
  runs — the patched program path does this.
