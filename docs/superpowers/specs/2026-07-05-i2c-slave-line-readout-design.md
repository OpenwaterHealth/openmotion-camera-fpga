# Design: FPGA I2C Slave + Full-Frame Image Readout in Line Chunks

**Date:** 2026-07-05
**Repo:** openmotion-camera-fpga (`HistoFPGAFw/`, device LIF-MD6000-6UWG36I)
**Status:** Approved by Ethan (brainstorming session 2026-07-05)

## Problem

1. The MCU (STM32H743, openmotion-sensor-fw) has no way to address the FPGA at
   runtime. The camera-flex I2C bus (one TCA9548A channel per camera) carries the
   OV2312 sensor at 0x36 and the CrossLink configuration port at 0x40, but the
   user design tri-states SDA and offers no control plane.
2. We want full-frame image readout for focus/alignment/diagnostics. The chip
   cannot buffer a frame (~25 Mb vs 180 Kb total EBR), so the frame is read out
   one line per camera frame over the existing FPGA→MCU SPI link. The
   `full-image2` branch proved the concept (line index slaved to a frame
   counter) but is unmergeable: it rewired `histogram3` into a dual-personality
   module, left `data_b` undriven, and offers no MCU control.

## Decisions (made with Ethan)

- **Exclusive modes.** A mode register selects histogram OR image-line readout.
  The SPI link carries one stream at a time.
- **Start-line register + auto-increment.** MCU writes a start line once; the
  FPGA captures that line, sends it, and increments. MCU may rewrite the
  register at any time to rewind/jump.
- **One line per camera frame.** SPI packet keeps the exact histogram envelope
  (1024 words x 4 B); MCU DMA path is untouched. Full 1080-line image in ~27 s
  at 40 fps — accepted.
- **I2C address 0x5A** (7-bit), a Verilog parameter. Clear of 0x36 / 0x40 /
  0x70 and both reserved ranges.
- **Architecture A: new self-contained `line_capture` module with its own RAM**
  (3 EBR, same 1024x24 geometry). Histogram logic stays bit-identical; only the
  serializer is hoisted to top level. Fallback if the device overflows: share
  the histogram RAM (not expected; ~9 of ~20 EBR in use today).
- **Soft I2C slave**, not the CrossLink hardened I2C core (which is not
  simulatable in the repo's Icarus flow and drags in LMMI/Diamond IP overhead).

## Architecture

```
MIPI ─► mipidphy2cmos ─► 20-bit pixel pairs + fv/lv ─┬─► histogram_module (core unchanged)
                                                     │         │ word[31:0] + serialize_active
                                                     └─► line_capture (NEW, own 1024x24 RAM)
                                                               │ word[31:0] + serialize_active
                                          mode ──► readout mux ─► Serializer ─► SPI ─► MCU SPI6
SDA/SCL (0x5A) ─► i2c_slave (NEW) ─► fpga_regs (NEW) ─ mode, line select ─► CDC ─► pixel domain
                                            ▲  frame count, current line ◄─ CDC ◄─┘
```

### New modules

**`i2c_slave.v`** — synthesizable 7-bit I2C slave.
- Clock: `clk_osc` (free-running internal oscillator) so the MCU can reach it
  with the camera/MIPI clock dead.
- SCL/SDA double-flop synchronized; edges detected on synced signals only.
- SDA open-drain: drive 0 or release (1'bz). No clock stretching.
- Write: `[S][addr W][reg][data]+[P]`, register address auto-increments.
- Read: combined format `[S][addr W][reg][Sr][addr R][data]+[P]`, auto-increment,
  master NACK terminates cleanly.
- STOP at any point returns the FSM to idle; repeated START re-arms addressing.
- Interface to regs: `reg_addr[7:0]`, `wr_data[7:0]`, `wr_strobe`, `rd_data[7:0]`.

**`fpga_regs.v`** — register file, `clk_osc` domain. Owns the line counter.

| Addr | Name       | Access | Reset | Contents |
|------|------------|--------|-------|----------|
| 0x00 | ID         | RO     | 0x5A  | presence check |
| 0x01 | VERSION    | RO     | 0x01  | bump on any map change |
| 0x02 | SCRATCH    | RW     | 0xA5  | bus sanity test |
| 0x03 | CTRL       | RW     | 0x00  | bit0 MODE: 0=histogram, 1=image line |
| 0x04 | LINE_L     | RW     | 0x00  | target line [7:0] (staging) |
| 0x05 | LINE_H     | RW     | 0x00  | target line [11:8]; writing commits {H,L} to the line counter |
| 0x06 | LINE_CUR_L | RO     | —     | line counter [7:0] (next line to capture) |
| 0x07 | LINE_CUR_H | RO     | —     | line counter [11:8] |
| 0x08 | FRAME_CNT  | RO     | 0x00  | free-running fv-edge counter (osc domain) |
| 0x09 | STATUS     | RO     | —     | bit0 pll_lock, bit1 image mode active (pixel domain echo) |

Undefined reads return 0x00. Writes to RO/undefined addresses are ignored.
LINE commit rule: LINE_L is staging only; the {H,L} pair is committed on the
LINE_H write (write L then H; a lone H write commits H with the last-staged L).

**`line_capture.v`** — pixel domain (`clk_pixel_hs`), parameterized
`LINE_WIDTH_PAIRS = 960`, `NUM_WORDS = 1024`.
- Tracks line number by counting `lv` rising edges inside `fv`; column number by
  counting valid pixel clocks inside `lv`. Fully synchronous counters — no
  gated-clock `always @(posedge frame_valid)` idioms.
- When enabled and tracked line == synced target line: write the 20-bit pixel
  pair to its own RAM (new SCUBA `ram_dp_s`-geometry instance) at the column
  address.
- Serialization starts at the frame_valid FALLING edge (not at line end).
  Rationale: the MCU re-arms SPI DMA in its FSIN ISR; a packet transmitted
  mid-frame (worst case: line 0, ~10 us after FSIN) can race the ISR's
  copy/re-arm and lose bytes. Histogram packets transmit during vertical
  blanking and never hit this; image packets must keep the same timing
  envelope (~1 ms drain at ~33 MHz SCLK; frame period 25 ms).
- On packet completion, flips a `line_sent` toggle to `fpga_regs` (increment)
  and receives the new target via the CDC handshake before the next frame.
- Maintains its own fv-edge frame counter for packet metadata.

### Modified modules

**`histogram_module`** — interface hoist only, internals bit-identical:
- `Serializer` instance moves to top level. New outputs: `word_o[31:0]`
  (= `{spacer, data}`), `serialize_active`; keeps `serializer_done` as an input.
- New `enable` input gates the state machine's IDLE→HISTO transition
  (histogram mode only). An in-flight SERIALIZE always completes.

**`top.v`** — instantiate the three new modules + serializer/readout mux:
- `Serializer.data_in` = mode-selected word; `.reset` =
  `reset | ~(histo_serialize_active | line_serialize_active)`.
- SDA becomes a real open-drain bidirectional; SCL an input.

## Verified system facts (2026-07-05 exploration)

- **Active resolution: 1920 x 1280** (`X02C1B_Sensor_Config.h` regs 0x3808-0x380b)
  → 960 pixel-pairs/line, 1280 line packets per full frame.
- **A packet is 1025 words = 4100 bytes** (= firmware `SPI_PACKET_LENGTH`): on
  entering SERIALIZE, the serializer's ready line fires one phantom done pulse
  that advances the word counter 0x3FF→0 before any byte is sent. Transmitted
  word order: 0,1,...,1023, then word 0 repeated. The MCU forwards the first
  4096 bytes; host `histogram[k]` = word k, and `histogram[1023]>>24` is the
  frame counter — matching the SDK's existing frame_id parsing.
- **Host control plane needs zero firmware changes**: `OW_CMD_I2C_REG_READ`
  (SDK `MotionSensor.i2c_read_register`) with `reg_addr_size=2` emits
  `START,addr+W,[hi],[lo],RESTART,addr+R,read` — to our slave, [hi] sets the
  register pointer and [lo] is a register write. With `reg_addr_size=1` it is
  a plain read. `mux_channel` selects the camera.
- **Bitstream size constraint**: firmware's SRAM programming streams exactly
  163489 bytes (`crosslink.c:497`). The Diamond-produced .bit must match this
  length (compare with the released asset; pad/adjust if needed).
- **MCU-side**: no packet validation before USB forwarding; DMA armed per
  camera at stream-enable and re-armed per frame in the FSIN ISR path; all 8
  cameras stream simultaneously; per-sample OV2312 die temperature is already
  in every parsed histogram block (SDK `HistogramSample.temperature_c`).

## SPI packet — image mode

Identical envelope to a histogram packet: 1024 words x 4 bytes, same serializer,
same LSB-first bit order, same word transmission order (word 0x3FF first, then
0x000..0x3FE — the existing bin-counter pattern). Word = `{spacer[7:0], data[23:0]}`.

- `data[19:0]` = captured pixel pair for that column, `{pixB[9:0], pixA[9:0]}`,
  for words 0..959. Words 960..1023: data = 0. `data[23:20]` = 0 always.
- Spacer metadata: word 0x3FF = frame counter (same slot as histogram packets);
  word 0 = line[7:0]; word 1 = {4'b0, line[11:8]}; word 2 = 0xB6 magic
  ("image packet" marker); all other spacers 0.

## Clock-domain crossings (`clk_osc` ⇄ `clk_pixel_hs`)

- **MODE bit:** quasi-static, 2-flop sync. Capture engine samples it at frame
  boundaries only; each producer finishes any in-flight packet before yielding —
  no torn packets.
- **Target line (12 bits):** toggle req/ack handshake. Bus held stable while req
  pending; last-write-wins if the MCU writes mid-transfer.
- **Back-channel:** `fv` 2-flop synced and edge-counted in the osc domain for
  FRAME_CNT; `line_sent` returns as a toggle event; pll_lock 2-flop synced.

## Error handling

- Camera not streaming: no fv → no packet. MCU distinguishes "camera dead"
  (FRAME_CNT frozen) from "line out of range" (FRAME_CNT ticking, no packet).
- Target line ≥ frame height: never matches, no packet sent. MCU recovers by
  timeout + rewriting LINE. Documented, intentional.
- External reset (GPIO0): all new logic returns to power-on defaults
  (histogram mode, line 0).

## Testing

Icarus Verilog via `test_projects/generate_sim.bat`. New modules are pure RTL,
so testbenches `include` the real `HistoFPGAFw/` sources (only the RAM macro is
swapped for a behavioral model in sim):
- `i2c_slave_tb` — bit-banged master tasks: address match/mismatch, single +
  auto-increment writes, repeated-start reads, ID/SCRATCH round-trip,
  mid-transfer STOP recovery.
- `line_capture_tb` — `camera_data_gen` pattern source; serialized bytes equal
  the selected line's pixels with correct spacers; line-out-of-range sends
  nothing; mode gating respects frame boundaries.
- `regmap_integration_tb` — full chain, MCU-like script: read ID, set
  mode=image + line=5, verify packet, verify auto-increment to 6, rewind to 0,
  rewrite target mid-CDC-transfer.
- Histogram regression: existing `camera_pipeline_tb` stays green; histogram
  RTL diff reviewable as interface-hoist-only.

Synthesis: add new files to `HistoFPGAFw.ldf`; Diamond LSE build must fit
(+3 EBR expected) and meet timing. SDA (C3) / SCL (F3) already in the LPF.

## Bring-up and follow-ups (other repos, separate tickets)

- Day-one bring-up needs **zero firmware changes**: sensor-fw's raw I2C
  passthrough (`OW_FACTORY_I2C_WR/RD/WRRD`) can read ID=0x5A, poke SCRATCH, set
  CTRL/LINE from the host.
- Follow-ups: sensor-fw `OW_CAMERA` readout-mode command; SDK wrapper using the
  reserved `OW_IMAGE_PACKET` type; host-side frame reassembly.

## Process

GitHub issue in `OpenwaterHealth/openmotion-camera-fpga` (label `feature`),
added to Project #11 and moved through Status as work progresses. PR to `main`
(this repo has no `next` branch) with `Refs #<n>`.
