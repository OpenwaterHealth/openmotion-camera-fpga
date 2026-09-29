# Validated camera-FPGA bitstreams

Prebuilt images so a bench session never needs a Diamond build (or license).
Flash-merge them into the sensor firmware image (copy to
`openmotion-sensor-fw/fpga/openmotion-camera-fpga.bin` before configuring the
Debug-BareMetal build) and force-load into camera SRAM from the host.

| File | Register map | Built from | SHA256 | Used for |
|---|---|---|---|---|
| `HistoFPGAFw_impl1_2026-07-05.bit` | v1 (single-line image mode) | feature/5 | see RUNBOOK.md | 2026-07-05 line-by-line composite dataset (#5) |
| `HistoFPGAFw_impl1_2026-09-29_map-v3-stride.bit` | v3 (sweep + STRIDE `0x0A`) | `68c9972` on `feature/8-drip-scan-single-frame` | `799c28379f85ba714b6223d686e15fba0b2e696803803df268a40d9edb1a782d` | 1 Hz full-frame stride composites (epic OpenwaterHealth/openmotion-bloodflow-app#480) |

The map-v3 image is 163,489 B (the size `crosslink.c` expects). Diamond 3.14
headless build (`pnmainc synth.tcl` in `HistoFPGAFw/`): 100% routed, timing
score 0/0, EBR 15/20, SLICEs 65%. Hardware-validated on all 16 cameras of the
bench rig on 2026-09-29.
