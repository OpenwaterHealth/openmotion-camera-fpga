# Full-frame capture runbook (morning of 2026-07-06)

## State as of last night (2026-07-05)

- Both sensor modules' STM32 flash carries the NEW FPGA bitstream (with the
  I2C slave @0x5A + image-line readout) at 0x081A0000, written over DFU and
  **verified**: right = full 163489-byte readback identical; left = write
  completed + first bytes verified over SWD. Firmware code untouched
  (1.8.1-rc.3), motion_config/serial sector untouched.
- Backups of the previous flash content: `backups/bitstream_left.bin`,
  `backups/bitstream_right.bin` (exactly 163489 B each). Restore with:
  `python update_bitstream.py --restore backups/bitstream_<side>.bin --side <side>`
- Both sensors' USB is down until a POWER CYCLE (the app's USB does not
  recover after a DFU session — both apps are running and healthy otherwise).
  The left sensor may also be recovered by BOOT button / power cycle; no
  reflash needed on either sensor.
- The firmware's host-upload SRAM path is broken (sensor-fw bug filed) —
  that's why the flash route was used. FPGA programming now uses the STOCK
  `program_fpga` path which streams our flash-resident image.

## Morning sequence

1. **Power cycle both sensor modules** (and check they enumerate: two
   healthy 0483:5A5A composites).
2. Smoke test one camera (from `tools/full_frame_capture/`):
   `python smoke_test.py --side left --cam 0`
   Expect: ID/VERSION/SCRATCH OK, histogram packet OK, line counter advances.
   (First `program_fpga` per sensor takes ~10 s/camera — 8 cams ≈ 80 s.)
3. Dark scene (rig covered/dark):
   `python capture.py --out captures --scene dark`
4. Laser scene (console drives laser; FSIN external + trigger handled by the
   script): `python capture.py --out captures --scene laser --skip-program`
5. Report: `python report.py --captures captures --out captures/report.html`

Outputs: per camera `captures/<scene>/<side>_cam<N>.npy` (raw uint16
1280x1920, values 0..1023) + 16-bit PNG (lossless), `meta.json` with
temperatures + missing-line stats, and `report.html` with all previews.

## Gotchas

- If a camera's FPGA ID check fails after programming: that camera may be
  NVCM-programmed (firmware skips SRAM load; 1.8.1-rc.3 has no force flag).
  The capture script skips it and records it in meta.json.
- The first HISTOGRAM packet after any image-mode session is invalid by
  design (accumulated bins) — irrelevant to captures, but don't be surprised
  in other tooling. FPGA repo issue #5 has details; bin +4/frame defect is
  issue #6.
- LINE_CUR I2C readback (regs 0x06/0x07) is display-only; the authoritative
  line number rides in each packet's spacer bytes.
