# Full-frame capture runbook (final — validated 2026-07-05 night)

## Proven end-to-end recipe

From `tools/full_frame_capture/` (both sensors + console on USB):

1. Dark scene (trigger runs with laser/TA off; SyncOut drives FSIN):
   `python capture.py --bitstream ..\..\HistoFPGAFw\impl1\HistoFPGAFw_impl1.bit --out captures --scene dark`
2. Laser scene:
   `python capture.py --bitstream <same> --out captures --scene laser --skip-program`
   (`--skip-program` only if no camera power cycle since the previous run —
   FPGA images are SRAM/volatile and are SDK-uploaded at capture time)
3. `python report.py --captures captures --out captures/report.html`

~40 lines/s per camera, all 8 per sensor in parallel → ~35 s + programming
(~12 s/camera when needed). Outputs: lossless `.npy` (uint16 1280x1920, raw
10-bit values) + 16-bit PNG + `meta.json` (temps, missing lines) + report.

## Requirements / current bench state

- **Firmware**: both sensors run `1.8.1-rc.3-dirty` = tag + the
  `fix/82-sram-upload-path` patch set (sensor-fw branch, pushed). Stock
  firmware CANNOT program host-uploaded bitstreams (sensor-fw#82 et al.).
- **Bitstream**: build from this branch (`HistoFPGAFw/synth.tcl` via
  pnmainc). Includes the bring-up fixes: SDA/SCL pin swap (legacy LPF had
  them backwards), control plane on the MIPI-derived clock (the OSCI HF
  oscillator never runs in these builds), self-releasing resets (firmware
  holds the GPIO0 external-reset net low permanently), GSR inference off.
- **Shelly plug 192.168.1.81** power-cycles the rig
  (`python C:\Users\ethan\AppData\Local\Temp\claude\shelly_cycle.py`);
  needed after any DFU session (sensor USB won't re-enumerate without it).

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
- Flash bitstream sectors (0x081A0000) on both sensors currently hold an
  intermediate image; backups for exact restore in `backups/`
  (`python update_bitstream.py --restore backups/bitstream_<side>.bin --side <side>`).
