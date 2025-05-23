//===========================================================================
// Verilog file generated by Clarity Designer    10/25/2024    19:48:13  
// Filename  : csi_dphy_rx_soft_dphy_rx.v                                                
// IP package: CSI-2/DSI D-PHY Receiver 1.5                           
// Copyright(c) 2016 Lattice Semiconductor Corporation. All rights reserved. 
//===========================================================================

module csi_dphy_rx_soft_dphy_rx (
    input wire                reset_n_i,
    inout wire                clk_p_i,
    inout wire                clk_n_i,
    inout wire                d0_p_io,	
    inout wire                d0_n_io,	
    inout wire                d1_p_i,	
    inout wire                d1_n_i,
    input wire                hs_clk_en_i,
    input wire                hs_d0_en_i,
    input wire                hs_d1_en_i,
    input wire                hs_d2_en_i,
    input wire                hs_d3_en_i,
    input wire                lp_d0_tx_en_i,
    input wire                lp_d0_tx_p_i,
    input wire                lp_d0_tx_n_i,

    output wire               clk_byte_o,
    output wire [16-1:0] bd0_o,
    output wire [16-1:0] bd1_o,
    output wire [16-1:0] bd2_o,
    output wire [16-1:0] bd3_o,

    output wire               lp_clk_rx_p_o,
    output wire               lp_clk_rx_n_o,
    output wire               lp_d0_rx_p_o,
    output wire               lp_d0_rx_n_o,
    output wire               lp_d1_rx_p_o,
    output wire               lp_d1_rx_n_o,
    output wire               lp_d2_rx_p_o,
    output wire               lp_d2_rx_n_o,
    output wire               lp_d3_rx_p_o,
    output wire               lp_d3_rx_n_o,
    output wire               cd_clk_o,
    output wire               cd_d0_o
);

soft_dphy_rx # (
  .NUM_RX_LANE    (2),
  .RX_GEAR        (16)
)
u_soft_dphy_rx (
  .reset_n_i      (reset_n_i),
  .clk_p_i        (clk_p_i),
  .clk_n_i        (clk_n_i),
  .d0_p_io        (d0_p_io),	
  .d0_n_io        (d0_n_io),	
  .d1_p_i         (d1_p_i),	
  .d1_n_i         (d1_n_i),	
  .d2_p_i         (d2_p_i),	
  .d2_n_i         (d2_n_i),	
  .d3_p_i         (d3_p_i),	
  .d3_n_i         (d3_n_i),
  .hs_clk_en_i    (hs_clk_en_i),
  .hs_d0_en_i     (hs_d0_en_i),
  .hs_d1_en_i     (hs_d1_en_i),
  .hs_d2_en_i     (hs_d2_en_i),
  .hs_d3_en_i     (hs_d3_en_i),
  .lp_d0_tx_en_i  (lp_d0_tx_en_i),
  .lp_d0_tx_p_i   (lp_d0_tx_p_i),
  .lp_d0_tx_n_i   (lp_d0_tx_n_i),
  .clk_byte_o     (clk_byte_o),
  .bd0_o          (bd0_o),
  .bd1_o          (bd1_o),
  .bd2_o          (bd2_o),
  .bd3_o          (bd3_o),
  .lp_clk_rx_p_o  (lp_clk_rx_p_o),
  .lp_clk_rx_n_o  (lp_clk_rx_n_o),
  .lp_d0_rx_p_o   (lp_d0_rx_p_o),
  .lp_d0_rx_n_o   (lp_d0_rx_n_o),
  .lp_d1_rx_p_o   (lp_d1_rx_p_o),
  .lp_d1_rx_n_o   (lp_d1_rx_n_o),
  .lp_d2_rx_p_o   (lp_d2_rx_p_o),
  .lp_d2_rx_n_o   (lp_d2_rx_n_o),
  .lp_d3_rx_p_o   (lp_d3_rx_p_o),
  .lp_d3_rx_n_o   (lp_d3_rx_n_o),
  .cd_clk_o       (cd_clk_o),
  .cd_d0_o        (cd_d0_o)
);

endmodule


