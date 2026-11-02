`timescale 1ns/1ps
// Gate-level wrapper for tb_histogram_module.sv.
//
// Same ports as the RTL histogram_module, but the DUT is the LSE
// post-synthesis netlist of the whole chip (impl1/topmod_prim.v, its own
// histogram_module renamed histogram_module_net by run_gls.sh). The D-PHY,
// byte2pixel (a black box in the netlist), PLL and oscillator are bypassed by
// forcing the nets they drive; the SPI link is observed on the real pins
// (DIFF_P = spi_clk, DIFF_N = spi_mosi; spi_en is tied 1 in top.v).
//
// Reset: LSE replicates the clk_pixel_hs reset synchronizer output, so the
// harness drives the synchronizer's asynchronous clear (ext_resetn_i_N_4,
// active high) and lets the real reset tree release two clocks later.
// Forcing reset_n_pix itself misses the replicas and leaves EBR clock enables
// low.
//
// The forced net names come from LSE and can change between builds;
// run_gls.sh checks that they exist before running.
module histogram_module (
    input clk,
    input reset,
    input [19:0] pixel_data,
    input frame_valid,
    input line_valid,
    input spi_clk_i,
    output spi_mosi_o,
    output spi_clk_o,
    input spi_en,
    output [5:0] debug,
    output [9:0] debug2
  );
  wire SDA, FSIN, CK_P, CK_N, D0_P, D0_N, D1_P, D1_N;

  topmod u_top (.SDA(SDA), .SCL(1'b0), .FSIN(FSIN), .GPIO0(1'b1), .GPIO1(1'b0),
                .CK_P(CK_P), .CK_N(CK_N), .D0_P(D0_P), .D0_N(D0_N),
                .D1_P(D1_P), .D1_N(D1_N),
                .DIFF_P(spi_clk_o), .DIFF_N(spi_mosi_o));

  initial begin
    force u_top.clk_pixel_hs                    = clk;
    force u_top.mipidphy2cmos.ext_resetn_i_N_4 = reset;
    force u_top.cmos_fv                         = frame_valid;
    force u_top.cmos_lv                         = line_valid;
    force u_top.cmos_data                       = pixel_data;
  end

  assign debug  = 6'b0;
  assign debug2 = 10'b0;
endmodule
