# Open-Motion 16-Camera Full-Frame Capture — Dataset Report

**Purpose of this document:** self-contained handoff for downstream analysis.
Everything needed to work with this dataset without access to the capture
session. Written 2026-07-05 (captures taken the same evening).

## 1. What this data is

First-ever full-frame image captures from the Open-Motion optical speckle
imaging system: 2 sensor modules ("left", "right") × 8 cameras each ×
2 illumination scenes = **32 images**, each **complete (1280/1280 lines)**.

- **Sensor:** OmniVision OX02C1B (datasheet: `Projects/component-datasheets/
  OX02C1S_OX02C1B_a-CSP_DS_1.0.pdf`), 1920×1280 active, 10-bit, NIR.
- **Scenes:**
  - `dark/` — console trigger running (frame sync only), laser TA disabled,
    laser power never configured. Bench in ambient/dark state.
  - `laser/` — console `apply_laser_power()` + TA trigger enabled: normal
    laser illumination through the system optics. 40 Hz trigger,
    1000 µs trigger pulse, 250 µs laser pulse delay, 1000 µs laser pulse.
- **Sensor config:** firmware default register set
  (`camera_configure_registers`, X02C1B_SENSOR_CONFIG) — no per-camera gain or
  exposure adjustments were made.

## 2. File inventory & formats

```
captures/
  dark/    left_cam0..7.npy/.png, right_cam0..7.npy/.png, meta.json
  laser/   left_cam0..7.npy/.png, right_cam0..7.npy/.png, meta.json
  report.html              # visual gallery, normalized previews
  uniformity_report.pdf    # human-readable analysis (8 pages)
  DATASET_REPORT.md        # this file
```

- **`.npy`** — the authoritative data: `uint16`, shape `(1280, 1920)`
  (rows, cols), values are **raw 10-bit sensor codes 0..1023, no scaling,
  no dark subtraction, lossless**.
- **`.png`** — same values in 16-bit grayscale PNG (lossless; appears very
  dark in normal viewers because values ≤1023 of 65535).
- **`meta.json`** — per camera: `lines_received`, `missing_lines` (all empty),
  `temperature_c_median` / `temperature_c_last` (OV2312 die temperature read
  by the MCU during the capture), `image_packets_seen`.
  ⚠ `dark/meta.json`'s right_cam* entries were reconstructed from run logs
  after an overwrite (temps are the medians printed during the original run);
  left entries and all laser entries are original.
- **Reusable analysis code:** `../analysis_report.py` (loading, dark
  correction, local speckle contrast, column profiles, asymmetry metrics).

## 3. Provenance — how a frame was captured (matters for analysis!)

Images were captured **one line per camera frame**: the FPGA buffers a single
selected video line each 40 Hz frame and ships it; the host reassembles
1280 lines into a frame, auto-incrementing through the image.

Consequences for analysis:

1. **Rows are not simultaneous.** Row *r* and row *r+1* were captured on
   consecutive trigger periods (~25 ms apart); a full image spans ~32 s of
   wall time. Horizontal (within-row) statistics are single-exposure;
   vertical statistics mix independent moments in time.
2. For **laser speckle** this means vertically adjacent pixels come from
   *different speckle realizations* (speckle decorrelates between frames on
   this system). Spatial speckle contrast computed over 2D windows therefore
   blends spatial and temporal ensembles. Row-wise (1D horizontal) contrast
   is the "pure single-exposure" statistic; comparing 1D-horizontal vs 2D
   window contrast is itself informative.
3. Any slow drift (thermal, laser power) appears as **row-direction banding**
   with a ~32 s ramp, not as a scene feature. Conversely, column-direction
   structure is immune to drift.
4. Each row's data comes from a **different exposure**, but always the same
   line number in sensor space — fixed-pattern (column) artifacts are real
   sensor/illumination properties.

## 4. Capture conditions & timing caveats

- Trigger: 40.0 Hz, console SyncOut → sensor FSIN (external frame sync).
- `laser/` scene: both modules captured in the same run (parallel threads).
- `dark/` scene: **right module captured in an earlier run than left**
  (~1 h apart, two rig power cycles in between). Right's dark-scene die temps
  (48–75 °C) reflect a hotter, long-running state; left's (52–62 °C) a
  recently power-cycled state. Scene darkness was nominally identical.
- Die temperatures during `laser/`: left 52.6–63.8 °C, right 43.0–55.7 °C
  (right ran cooler after its power cycle).
- Dark pedestal ≈ 128 counts on every camera (black-level clamp active);
  dark mean vs temperature correlation is weak (r=0.44, p=0.086) because the
  clamp absorbs most of it.

## 5. Findings so far (see uniformity_report.pdf for figures)

### 5.1 Intensity uniformity ("brighter left, darker right")

Left/right asymmetry of the dark-corrected laser signal, defined as
(mean of left third − mean of right third)/overall mean, in sensor pixel
coordinates:

| cam | left module | right module |
|----:|------------:|-------------:|
| 0 | +7.0% | +8.5% |
| 1 | +8.7% | +10.6% |
| 2 | +14.3% | +13.2% |
| 3 | +21.3% | +21.0% |
| 4 | +19.9% | +18.2% |
| 5 | +10.9% | +11.9% |
| 6 | +8.3% | +7.7% |
| 7 | +6.8% | +6.2% |

- **Horizontal component never flips sign** (all 16 positive).
- **Vertical (top/bottom) component flips exactly at the cam3|cam4 midline**
  on both modules: cams 0–3 ≈ −7…−13%, cams 4–7 ≈ +4…+9%.
- Fitted 2D gradient vectors mirror around the module center; magnitudes
  peak at center positions (~3,000–4,200 counts/1000 px) and are smallest at
  the edges (~700–1,200).
- Edge cameras (0, 1, 6, 7) have their brightness **maximum inside the frame**
  (column ~670–825, "peaked" profiles); center cameras (2–5) are monotonic.

### 5.2 Dark frames

Dark-frame left/right asymmetry: −0.9%…+0.1% (essentially flat) — no
pedestal/dark-current tilt.

### 5.3 Thermal correlations (across 16 cameras)

- temp vs signal asymmetry: r = +0.36, p = 0.166 (not significant)
- temp vs dark asymmetry:  r = +0.49, p = 0.052 (marginal, tiny magnitudes)
- temp vs median speckle K: r = −0.01, p = 0.985 (nothing)

### 5.4 Speckle contrast (K = σ/μ, 15×15 px windows, dark-corrected laser)

- K is far more uniform spatially than intensity: L/R asymmetry −4.6%…+0.7%
  (slightly higher K on the dimmer side — consistent with shot-noise
  contribution at lower signal).
- **Median K varies by camera position: 0.369 … 0.663**, with the same
  left/right module symmetry (cam1/cam6 ≈ 0.37; cam0/cam7 ≈ 0.52–0.66;
  centers ≈ 0.47–0.52). Position-locked, not temperature-locked.

### 5.5 Session conclusion (to be tested further)

The intensity gradient is **illumination geometry**, not thermal: absent in
dark frames, uncorrelated with die temperature, reproduced identically on two
modules at different temperatures, and structured as a vector field that
mirrors around the module's mechanical midline (each camera appears to view a
different flank of one off-center illumination lobe per module).

## 6. Mechanical context

Each camera is held relative to the laser by a "sled". Drawings (added
2026-07-05, `Projects/component-datasheets/`):

- `300-00048 300-00048, Sled, Motion, DVT Rev-4.pdf` — sled
- `700-00038 Camera Module, Motion, DVT Rev-3.pdf` — camera module
- Also relevant: `NIR CAMERA BOARD_20250804 (2).pdf` — camera PCB

The gradient-vector field (§5.1) should be checked against the sled's
laser-to-camera offsets; mounting orientation per position determines the
mapping from sensor pixel coordinates to physical directions.

## 7. Suggested analyses for the next pass

1. **Geometry fit:** project each camera's measured 2D gradient vector and
   brightness-peak location against laser/camera offsets from the sled
   drawing; a single per-module source position should explain all 8 vectors
   if the illumination-geometry hypothesis is right.
2. **K baseline vs position (0.37–0.66):** decompose into speckle size /
   coherence / depolarization / defocus candidates; check whether K scales
   with the geometry fit from (1). This matters directly for BFI calibration.
3. **Shot-noise-corrected K:** K_corr² ≈ K² − (1/μ_e); requires the sensor
   gain (e-/DN) — not measured here (firmware default gain).
4. **Row-direction temporal analysis:** exploit the line-sequential capture
   (§3) — row-mean vs row-index gives a ~32 s time series of laser power /
   thermal drift per camera, free.
5. **1D-horizontal vs 2D-window speckle contrast** comparison (§3.2) to
   separate spatial from temporal speckle statistics.
6. **FPN/PRNU:** dark frames enable offset-FPN maps; no flat-field exists in
   this dataset (would need a diffuse uniform target).

## 8. Known artifacts & gotchas

- Values are 10-bit in uint16; a handful of pixels reach 622–736 max in the
  laser scene — no saturation (1023) observed anywhere.
- Dark-corrected signal (`laser − dark`) can clip at 0 where laser adds
  little; `analysis_report.py` clips negatives to 0.
- The per-frame die temperature rides in every data packet; `meta.json`
  carries the median/last per capture. Temperature during an image is not
  constant (cameras warm over the ~32 s).
- Unrelated to images, for context: the production histogram path has a known
  +4 counts/frame defect (openmotion-camera-fpga issue #6).
- Capture pipeline validation state: all 32 images complete, no missing
  lines, line numbers verified from in-band tags (packet spacer bytes).
