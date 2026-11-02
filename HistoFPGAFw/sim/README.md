# Histogram module simulation

Self-checking testbench for `histogram_module` (histogram banks, serializer,
SPI master). It decodes the SPI stream exactly as the sensor MCU does
(4100-byte packet, LSB first, sampled on rising SCLK, frame id in byte 4095)
and compares every bin with an independent count of the pixels it drove.

## Run

Needs Icarus Verilog (`iverilog`, `vvp`) on the PATH. Run from Git Bash.

```sh
FAST=1 ./sim/run.sh                     # full suite, behavioural RAM model, ~1 min
./sim/run.sh                            # full suite, Lattice DP8KE model, ~1.5 h (sign-off)
FAST=1 ./sim/run.sh +seed=42            # another random seed
FAST=1 ./sim/run.sh +frames=2 +no_overlap   # smoke test
FAST=1 ./sim/run.sh +vcd                # also write sim/out/tb_histogram_module.vcd
```

The vendor run uses the CrossLink primitive library from a Diamond install,
`/c/lscc/diamond/3.14/cae_library/simulation/verilog/lifmd` by default;
override with `LSCC_LIB=...`. The last line of the log is `PASS` or
`FAIL: <n> errors`.

## Files

| File | Purpose |
|---|---|
| `tb_histogram_module.sv` | Testbench; requirements R1-R9 are listed at the top |
| `run.sh` | Build and run with Icarus |
| `ram_dp_s_fast.v` | Fast drop-in for the IPexpress `ram_dp_s` (same timing; X on same-address read/write, like the vendor model) |
| `lattice_glbl_stub.v` | GSR/PUR stubs for the fast run |
| `gls/run_gls.sh` | Gate-level run of the same testbench against the last Diamond netlist (`impl1/topmod_prim.v`) |
| `gls/histogram_module_gls.v` | GLS wrapper: drives the netlist by forcing the byte2pixel outputs, pixel clock and reset synchronizer |
| `gls/hardmacro_stubs.v` | Port-only stubs for the D-PHY, PLL and oscillator (bypassed in GLS) |

## After every Diamond build

1. `./sim/gls/run_gls.sh` must end in `PASS` (about as long as the DP8KE run).
   It checks the synthesized logic, not the RTL.
2. Timing: `impl1/HistoFPGAFw_impl1.twr` must show `Timing errors: 0` with
   `clk_pixel_hs` constrained at **132.8 MHz** (`HistoFPGAFw.lpf`). That is the
   real PLL CLKOS rate, set by the camera link: OX02C1B, 2 lanes x 1328 Mbps
   RAW10 = 265.6 Mpixel/s = 132.8 MHz at 2 pixels/clock. Do not loosen it with
   `PAR_ADJ` or a lower frequency; the average rate over a 9 us row is already
   106.7 MHz, so there is no slower clock that still keeps up.

## What is covered

Single frames: random, pixel runs and near-repeats (the k-1 and k-2
forwarding paths of the read-modify-write pipeline), every bin,
constant black / saturated / mid, back-to-back, fv and lv falling together,
byte2pixel-like timing (35-clock porches, bus 0 while lv is low), and a
blanking bus that holds, is zero, or is random, with front porch 1/3/10.

Multi-frame: a frame starting during the previous push (ping-pong), steady
state with a third frame in the freed bank, a third frame with no free bank
(dropped, frame id gap), reset half way through a push followed by a frame
during the post-reset scrub (dropped) and a clean frame.

Not covered here: the MIPI D-PHY and byte2pixel IP (only their frame-edge
behaviour is modelled) and timing closure. GLS covers the top-level SPI pin
mapping and the synthesized reset tree.
