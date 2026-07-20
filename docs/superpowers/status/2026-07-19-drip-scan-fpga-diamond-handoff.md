# Drip-scan FPGA RTL — wrap-up + Diamond handoff checklist

**Branch:** `feature/8-drip-scan-single-frame` · **HEAD:** `d339790` · **Issue:** [OpenwaterHealth/openmotion-camera-fpga#8](https://github.com/OpenwaterHealth/openmotion-camera-fpga/issues/8) · **Date:** 2026-07-19

RTL implementation of drip-scan (spec [`2026-07-19-drip-scan-single-frame-design.md`](../specs/2026-07-19-drip-scan-single-frame-design.md)) is complete and fully regression-tested in simulation. This doc is the final wrap-up for Task 7 of the [implementation plan](../plans/2026-07-19-drip-scan-fpga.md): full suite results, the reconciliation against the plan (the suite grew during review), the Diamond bitstream build checklist, and documented-but-not-implemented follow-ups.

## Reality check vs. the plan

The plan (written before implementation) scoped **6 testbenches** (5 new in `test_projects/drip_scan/` + regression checks folded into the existing 4 in `test_projects/i2c_line/`) and a register map with only STATUS bit2 (overrun). Review-driven hardening added scope beyond that baseline:

- **`wedge_tb.v`** (new, 6th TB in `drip_scan/`) — proves the `image_pusher` SERIALIZE watchdog (commit `974660a`) escapes a wedged sweep push after 2²¹ clk (~15.8 ms) rather than hanging forever.
- **STATUS bit3 / header flags bit1** (commit `d339790`) — a dedicated **wedge** latch alongside the existing **overrun** latch (bit2/flag bit0), so the host can distinguish a watchdog-triggered abort (electrical/SEU event mid-push) from a plain overrun (misprogrammed sensor timing). Register map is still VERSION `0x02` — this is an additive bit, not a version bump.
- `sweep_integration_tb.v` grew additional coverage for the wedge/overrun interaction and re-arm latch-clear semantics beyond the plan's original scope.

Net result: **10 testbenches**, not 6/9. Every reference to "six testbenches," "9 Icarus TBs," or "all six testbenches" in the plan document (`docs/superpowers/plans/2026-07-19-drip-scan-fpga.md`) describes the pre-review scope and is superseded by this document; the plan file itself is left as a historical record and is not edited.

## Step 1: full suite results (fresh run, both runners)

All 10 testbenches run clean from a fresh `git status`-clean tree at `d339790`. Command form: `.\test_projects\<project>\run.bat <tb_name>` (iverilog `-g2005` + vvp, per `run.bat`).

### `test_projects/drip_scan/` (6 TBs)

| TB | Result | Proves |
|---|---|---|
| `crc16_tb` | **ALL TESTS PASSED** | RTL CRC == sensor-fw `util_crc16` (poly 0x1021 / init 0xFFFF / MSB-first / no XOR-out) via vectors computed from the actual `utils.c` table |
| `raw10_pack_tb` | **ALL TESTS PASSED** | Pinned RAW10 bit layout for a hand-computed 8-px vector; simultaneous push+pop; clear |
| `image_pusher_tb` | **ALL TESTS PASSED** | Byte-exact 2408-B push through real Serializer/SPI incl. pinned payload + CRC `0x3C22`; overrun header flag; re-push cleanliness |
| `sweep_tb` | **ALL TESTS PASSED** | Start-line gating, push accounting, overrun tripwire drop+latch, flag propagation, latch clear on arm |
| `sweep_integration_tb` | **ALL TESTS PASSED** | Full chain from I2C to SPI bytes: byte-exact CRC'd pushes, constant `frame_cnt`, STATUS bit2 over I2C, histogram envelope bit-identical, clean exit |
| `wedge_tb` | **ALL TESTS PASSED** | `image_pusher` SERIALIZE watchdog escapes a wedged push after 2²¹ clk (observed: 15,800,000 ns vs. guard 15,728,640 ns); sticky wedge latch sets STATUS bit3 / header flag bit1 distinct from overrun |

### `test_projects/i2c_line/` (4 TBs — feature/5 regressions)

| TB | Result | Proves |
|---|---|---|
| `fpga_regs_tb` | **ALL TESTS PASSED** | v2 register map: VERSION 0x02, CTRL bit1 SWEEP publishes atomically with the line over the req/ack handshake, STATUS bit2 mirrors the pixel-domain overrun latch |
| `i2c_slave_tb` | **ALL TESTS PASSED** | I2C slave protocol unchanged by v2 register additions |
| `line_capture_tb` | **ALL TESTS PASSED** | Single-line mode (feature/5 path) unchanged; v2 ping/pong sweep additions don't disturb it |
| `integration_tb` | **ALL TESTS PASSED** | Histogram envelope bit-identical end-to-end; boot/collision/steady-state frame sums all match expected |

**10/10 pass.** `git status` after the run: clean tree (`test_projects/out/` is gitignored and was not staged).

## Step 4 (of task-7.md): Diamond build checklist

Present verbatim to Ethan — the bitstream is **not** built by the agent.

1. Open `HistoFPGAFw/HistoFPGAFw.ldf` in Lattice Diamond; in File List, add the three new sources to impl1: `HistoFPGAFw/crc16.v`, `HistoFPGAFw/raw10_pack.v`, `HistoFPGAFw/image_pusher.v`. Also check `HistoFPGAFw/synth.tcl` — if it enumerates sources explicitly, add the same three files there.
2. **Build from `d339790` or later.** Intermediate commits between Tasks 4–6 (register-map and line_capture rework landing before `top.v` was rewired) have dangling ports in `top.v` and will not elaborate cleanly. `d339790` (current HEAD) is fully wired — verified: `top.v` connects `overrun_i`/`wedge_i` on `fpga_regs`, and `overrun_o`/`wedge_latch_o` on `line_capture`, with no floating ports.
3. No new IP generation needed: the second line buffer reuses the existing `ram_dp_s` SCUBA netlist (`HistoFPGAFw/ram_dp/ram_dp_s/ram_dp_s.v`).
4. Synthesize → Map → PAR. In the map report verify EBR usage is **15/20** (9 histogram + 3 + 3 line RAMs) — unchanged from the original plan estimate; no RTL added since Tasks 5/6 introduces new RAM instances (the watchdog and STATUS bit3 work in Tasks 6/7 are pure logic, no new EBR). Verify timing closure on `clk_pixel_hs` (132.8 MHz) — the new critical candidates are the `crc16` 8-stage unroll and the `raw10_pack` 32-bit shifts; both are far shallower than the histogram adders, but confirm.
5. Generate the bitstream and export the `.bin`.
6. **Bitstream-size gotcha (sensor-fw CLAUDE.md):** `openmotion-sensor-fw/Core/Src/crosslink.c` hardcodes the bitstream size as **`163489`** bytes, and the flash-region math in that file is derived from the same constant. CrossLink SRAM configuration images are fixed-size for a given device, so it should not change — but verify: `(Get-Item .\openmotion-camera-fpga.bin).Length` must equal `163489`. If it differs, **both** the constant and the flash-region math in `crosslink.c` need updating — file a sensor-fw issue and fix it there **before anyone flashes**, or programming will misalign and corrupt adjacent flash.
7. **Register map is v2** (`VERSION` 0x02, unchanged by this task — the STATUS bit3/wedge addition is a new bit within the existing v2 map, not a version bump). `tools/full_frame_capture/smoke_test.py` already asserts `VERSION == 0x02` (commit `c62929e`) — no further smoke-test changes needed for the wedge bit; it's not yet exercised by the smoke test (bench-only, see below).
8. Publishing: sensor-fw pulls the **latest GitHub release** asset `openmotion-camera-fpga.bin` at CMake configure time. Do **not** publish this bitstream as a full release until hardware validation — use a pre-release tag (e.g. `X.Y.Z-rc.1`) per the qms-release process, and pin sensor-fw's `FPGA_BITSTREAM_URL` to that tag for bench testing.
9. Hardware validation (spec §5 acceptance: MIPI-clock scope check, test-pattern bit-exact sweep, dark-decay measurement, link-speed matrix) belongs to the sensor-fw/SDK companion work — file those issues per spec §7 when starting them, linked back to #8.
10. Board: the ticket moves to **In review** when the PR opens; it stays In review through any `rc`/`dev` pre-release validation, and reaches **Done** only on a full release or explicit validation sign-off. (Issue #8 is currently **In progress** on Project #11 — this task pushes the branch but does not open a PR; the status move happens when the PR is opened.)

## Smoke-test instructions summary

`tools/full_frame_capture/smoke_test.py <bitstream.bit> [--side left|right] [--cam N] [--skip-program]` — bring-up smoke test against real hardware, run after force-loading the new bitstream:

1. Power on the target camera.
2. Force-load the FPGA from the flash-resident bitstream (`update_bitstream.py` handles flashing separately; this script force-loads SRAM from flash since the cameras are NVCM-programmed).
3. I2C control plane: ID == 0x5A, **VERSION == 0x02**, SCRATCH write/read round-trip.
4. Histogram mode still streams (regression check — drip-scan must not disturb the default mode).
5. Image mode round-trip: single-line mode (`set_image_mode(start_line=0)`), confirms the line counter advances. **Note:** this does not yet exercise SWEEP mode (CTRL bit1) or the overrun/wedge latches — that HIL coverage belongs to the sensor-fw/SDK companion work per spec §4.4/§4.5, since sweep mode needs the sensor retiming (HTS/VTS) those repos own.

## Follow-up candidates (documented only — not implemented in this task)

Out of scope for feature/8; recorded here so they aren't lost.

1. **Consolidate the wedge/watchdog guard pattern.** `image_pusher`'s SERIALIZE watchdog (commit `974660a`) ports the guard-counter pattern from commit `992dc41` on the separate, **unmerged** branch `feature/68-serialize-timeout-selfheal` (that branch adds the same watchdog to `histo_module`'s SERIALIZE state for the histogram push path). Neither the legacy `line_capture` `S_SER` state (single-line replay, feature/5) nor `histo_module`'s SERIALIZE currently share a watchdog with the sweep path added here — each push path (histogram, single-line, sweep) has its own bespoke or absent guard. When `feature/68` merges, consider consolidating so all three Serializer-driving paths use one guarded pattern instead of parallel copies.
2. **Shared TB include to dedupe `tb_pair`/`crc16_ref`/`check_push`.** Four testbenches carry independent copies of the same reference-model helpers: `image_pusher_tb.v`, `sweep_tb.v`, `sweep_integration_tb.v`, and `wedge_tb.v` (the first three also duplicate `tb_pair`). An optional shared include (e.g. `test_projects/drip_scan/push_check_tasks.vh`) could dedupe this — not done here to avoid touching passing tests with no functional change.
3. **Host-sequencing note for single↔sweep mode transitions (arm ordering) — carry into the SDK work.** `line_capture.v` guards both cross-mode corners defensively (a sweep line completing while a legacy single-line drain (`S_SER`) is still in flight, and the reverse — sweep still draining while single-line tries to enter `S_SER`): both take the standard drop+tripwire path rather than contending for the shared Serializer, so it's safe by construction regardless of host behavior. But per the RTL comment (`line_capture.v` line ~175), it's "host sequencing avoids it, the guard makes it safe regardless" — i.e., normal operation shouldn't rely on the tripwire. The SDK capture orchestrator (spec §4.5) should sequence mode-transition writes (exit sweep and confirm drain before re-arming single-line, and vice versa) so the cross-mode guard is a safety net, not the normal path.

## Commits on this branch (Tasks 1–7)

```
88a84d6 feat: crc16 module - CRC-16/CCITT-FALSE matching sensor-fw util_crc16
7bf2847 docs: crc16 review polish - note undefined-until-init and T2 state coupling
a30c554 feat: raw10_pack - 20-bit pair to RAW10 byte gearbox
e82273d docs: raw10_pack review polish - shifter/deadlock notes, mirror take-edge comment
0337048 feat: image_pusher - 2408-B header+RAW10+CRC16 line push
1a03366 feat: fpga_regs v2 - VERSION 0x02, CTRL SWEEP bit, STATUS overrun, atomic publish
c62929e fix: smoke_test expects register-map VERSION 0x02
fe62b42 test: fpga_regs_tb - torn-publish coverage for {sweep,line} atomicity
4ff5204 feat: line_capture sweep mode - ping/pong double buffer, overrun tripwire
b3be364 fix: line_capture - clear overrun latch on re-arm publish, guard S_SER cross-mode push
9b99f86 feat: top-level sweep wiring + full-chain sweep integration TB
974660a feat: image_pusher SERIALIZE watchdog - escape a wedged sweep push
d339790 feat: STATUS bit3 + header flags bit1 distinguish wedge from overrun
```
