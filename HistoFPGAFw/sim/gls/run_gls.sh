#!/usr/bin/env bash
# Gate-level simulation: run tb_histogram_module.sv against the netlist LSE
# produced in the last Diamond build (impl1/topmod_prim.v).
#   ./sim/gls/run_gls.sh                       full suite
#   ./sim/gls/run_gls.sh +frames=1 +no_overlap smoke test
# Run it after every Diamond build; it checks the build, not the RTL.
# Zero-delay functional simulation: it proves the synthesized logic, not timing
# (timing is the trce report at the real clock, see sim/README.md).
set -euo pipefail
cd "$(dirname "$0")/../.."
LSCC_LIB="${LSCC_LIB:-/c/lscc/diamond/3.14/cae_library/simulation/verilog/lifmd}"
NET=impl1/topmod_prim.v
OUT=sim/gls/out
mkdir -p "$OUT"
[[ -f "$NET" ]] || { echo "no $NET: build in Diamond first"; exit 1; }

# The netlist's histogram_module would clash with the wrapper of the same name.
sed -E 's/^module histogram_module /module histogram_module_net /;
        s/^(\s*)histogram_module histogram_module_i/\1histogram_module_net histogram_module_i/' \
    "$NET" > "$OUT/topmod_prim_gls.v"

# The wrapper forces LSE-generated net names; fail loudly if a rebuild renamed them.
for n in "wire clk_pixel_hs" "cmos_fv" "cmos_lv" "cmos_data" "ext_resetn_i_N_4"; do
  grep -q "$n" "$OUT/topmod_prim_gls.v" || { echo "net '$n' not in netlist: update sim/gls/histogram_module_gls.v"; exit 1; }
done
echo "netlist: $NET ($(date -r "$NET" '+%F %T'))"

iverilog -g2012 -Wno-timescale -Wno-implicit-dimensions -o "$OUT/gls.vvp" -y "$LSCC_LIB" \
  sim/tb_histogram_module.sv sim/gls/histogram_module_gls.v "$OUT/topmod_prim_gls.v" \
  sim/gls/hardmacro_stubs.v 2>&1 | grep -vE "warning: Port|coerced to inout" || true
cd "$OUT"
vvp -n gls.vvp "$@"
