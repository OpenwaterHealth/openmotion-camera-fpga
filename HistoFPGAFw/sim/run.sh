#!/usr/bin/env bash
# Run the histogram_module testbench with Icarus Verilog.
#   ./sim/run.sh                 full regression, Lattice DP8KE model (sign-off, ~1.5 h)
#   FAST=1 ./sim/run.sh          same tests, behavioural RAM model (iteration)
#   ./sim/run.sh +frames=2 +no_overlap   quick smoke test
#   ./sim/run.sh +seed=42        different random seed
# The vendor model comes from a Diamond install (override with LSCC_LIB).
set -euo pipefail
cd "$(dirname "$0")/.."
LSCC_LIB="${LSCC_LIB:-/c/lscc/diamond/3.14/cae_library/simulation/verilog/lifmd}"
mkdir -p sim/out
if [[ "${FAST:-0}" == "1" ]]; then
  RAM=(sim/ram_dp_s_fast.v)
  LIB=(sim/lattice_glbl_stub.v)
else
  RAM=(ram_dp/ram_dp_s/ram_dp_s.v)
  LIB=(-y "$LSCC_LIB")
fi
iverilog -g2012 -Wall -Wno-timescale -Wno-implicit-dimensions -o sim/out/tb_histogram_module.vvp \
  "${LIB[@]}" \
  sim/tb_histogram_module.sv histo_module.v histo_calc.v histo_serializer.v spi_master.v \
  "${RAM[@]}"
cd sim/out
vvp -n tb_histogram_module.vvp "$@"
