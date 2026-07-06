# Full-frame capture runbook (updated end of 2026-07-05 session)

## Rig state right now

- **Both sensors run force-capable firmware** `1.8.1-rc.3-dirty` = exact tag
  1.8.1-rc.3 + ONLY the feature/68 force-load hunk (OW_FPGA_PROG_SRAM
  reserved==2 → `program_fpga(i, force=true)`). Build tree:
  `C:\Users\ethan\AppData\Local\Temp\claude\sensorfw-rc3` (worktree of
  sensor-fw at the tag + patch). Official rc3 raw.bin restore copy:
  `<that tree>\build\Release\official-rc3-backup.bin` and the GitHub release.
- **Both sensors' flash bitstream sectors (0x081A0000) hold the NEW FPGA
  image** (I2C slave @0x5A + line readout), byte-exact verified. Backups of
  the previous content: `backups/bitstream_{left,right}.bin` (restore:
  `python update_bitstream.py --restore backups/bitstream_<side>.bin --side <side>`).
- **All 16 cameras are NVCM-programmed** → the FPGAs boot the OLD image from
  NVCM at power-on. Loading the NEW image requires the FORCED SRAM load
  (`fpga_link.force_program_fpga`, ~10 s/camera). SRAM loads are volatile —
  re-force after any camera power cycle.
- **Shelly plug `192.168.1.81` power-cycles the whole rig**
  (`python C:\Users\ethan\AppData\Local\Temp\claude\shelly_cycle.py`).
  Sensor USB never re-enumerates after a DFU session without this.

## THE BLOCKER (needs eyes on the bench)

**No camera produces frames tonight in ANY configuration** — stock firmware
(official rc3 re-flashed and tested) + stock NVCM image + configured sensors
+ console trigger running (tried SyncOut on/off, TA on/off, laser config
applied or not, single-capture's manual FSIN pulse, internal enable path,
1 camera or all 8, both sensors). All 16 OV2312s answer on I2C; all enables
succeed from a clean boot; zero histogram packets ever arrive (5 s firmware
HISTO timeout on single captures).

Everything from USB down to the sensors' I2C is proven good, so the missing
link is frame sync (FSIN) or something physical: check the console→sensor
sync/trigger cabling and anything the 60 Hz bench session (morning of 07-05)
may have left disconnected or re-jumpered. The morning's all-16 60 Hz run
used the feature/68 dev firmware + console trigger and worked.

## Capture sequence (once frames work)

From `tools/full_frame_capture/` (worktree
`...\openmotion-camera-fpga\.claude\worktrees\admiring-moore-975f35`):

1. `python smoke_test.py --side left --cam 0`
   (force-loads the FPGA, checks I2C ID/SCRATCH at 0x5A, histogram packet
   with dark trigger, image-mode line counter advance)
2. Dark scene (rig covered; trigger runs with TA/laser OFF):
   `python capture.py --out captures --scene dark`
3. Laser scene:
   `python capture.py --out captures --scene laser --skip-program`
   (`--skip-program` only if cameras were NOT power-cycled since step 2)
4. `python report.py --captures captures --out captures/report.html`

Outputs per camera: lossless `.npy` (uint16 1280x1920, raw 10-bit values) +
16-bit PNG + `meta.json` (temps, missing lines) + `report.html`.

## Gotchas

- FPGA I2C regs (0x5A) may only respond while the camera stream is enabled —
  the FPGA's external reset (fw "GPIO1" → FPGA GPIO0, schematic swap) is
  raised in enable_camera_stream and dropped in disable. The capture flow
  sets image mode AFTER enable_camera for this reason. (Unverified on
  hardware tonight — frames blocker prevented the check; if 0x5A stays mute
  with streaming running and frames flowing, capture debug continues there.)
- First histogram packet after leaving image mode is invalid (camera-fpga
  issue #5/#6 docs).
- LINE_CUR readback is display-only; SPI packet spacers are authoritative.
- sensor-fw#82: the firmware's host-upload SRAM path is broken — do NOT use
  enter_sram_prog/send_bitstream/PROG_SRAM(reserved=0); the flash-resident
  route above is the working path.
