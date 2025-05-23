`timescale 1 ps / 1 ps

module mipidphy2cmos
(
	input			reset_n_i,
	inout 			rx_clk_p_i,
	inout 			rx_clk_n_i,
	inout 			rx_d0_p_i,
	inout 			rx_d0_n_i,
	inout 			rx_d1_p_i,
	inout 			rx_d1_n_i,
	output [19:0]	pd0_o,
	output 			fv_o,
	output 			lv_o,
	output 			rx_clk_byte_fr_o,
	input 			clk_pixel_i,
	input 			pll_lock_i
);

//-----------------------------------------------------------------------------
//	Parameters Declarations
//-----------------------------------------------------------------------------
parameter RX_LANE_COUNT = 2;
parameter RX_GEAR = 16;	// DPHY Rx Clock Gear

//-----------------------------------------------------------------------------
//	Wire and Register declarations
//-----------------------------------------------------------------------------

wire int_rst_n;

//Byte Clock Domain
wire [5:0] ref_dt = 6'h2b; 
wire rx_clk_byte_fr , rx_clk_byte_hs, rx_clk_lp_ctrl, rx_reset_lp_n;

wire rx_payload_en, rx_sp_en, rx_lp_en, rx_lp_av_en;
wire [RX_LANE_COUNT*RX_GEAR-1:0]	rx_payload;
wire [5:0]	rx_dt;
wire [15:0]	rx_wc;

assign rx_clk_byte_fr = rx_clk_byte_hs;
assign rx_clk_lp_ctrl = 1'b1;
assign rx_reset_lp_n = 1'b1;
 
//Pixel Clock Domain
wire clk_pixel_pll ;
//reg rx_reset_byte_fr_n_meta, rx_reset_byte_fr_n_sync;
reg reset_pixel_n_meta, reset_pixel_n_sync;
wire rx_reset_byte_fr_n_sync;

// MIPI Output debug signals
wire rx_hs_d_en, rx_hs_sync, rx_term_clk_en;
wire [1:0] rx_lp_hs_state_clk, rx_lp_hs_state_d;
wire [1:0] p_odd;

// RESET BRIDGES
//	Reset Bridge for clk_pixel_pll clock
assign int_rst_n = reset_n_i;


/*synthesis translate_off*/
GSR GSR_INST (1'b1);
/*synthesis translate_on*/

assign rx_clk_byte_fr_o = rx_clk_byte_fr;
assign clk_pixel_pll = clk_pixel_i;

//	Reset Bridge for rx_clk_byte_fr clock
reset_bridge rst_brg_mipi_clk(
  .clk_i			(rx_clk_byte_fr),// Destination clock
  .ext_resetn_i		( int_rst_n ),// Asynchronous reset signal
  .sync_resetn_out	(rx_reset_byte_fr_n_sync)// Synchronized reset signal
);

/////////////////////////////////////////////////////////////////////////////
///// RX D-PHY module instantiation                                     /////
///// Customer has to recreate a Soft-IP for own configuration settings /////
/////////////////////////////////////////////////////////////////////////////
rx_dphy_ip rx_dphy
(
// Inouts
	.csi_dphy_rx_clk_p_i			(rx_clk_p_i),
	.csi_dphy_rx_clk_n_i			(rx_clk_n_i),
	.csi_dphy_rx_d0_p_i				(rx_d0_p_i),
	.csi_dphy_rx_d0_n_i				(rx_d0_n_i),
	.csi_dphy_rx_d1_p_i				(rx_d1_p_i),
	.csi_dphy_rx_d1_n_i				(rx_d1_n_i),
// Inputs
	.csi_dphy_rx_pd_dphy_i			(~reset_n_i),
	.csi_dphy_rx_clk_byte_fr_i		(rx_clk_byte_fr),
	.csi_dphy_rx_clk_lp_ctrl_i		(rx_clk_lp_ctrl),
	.csi_dphy_rx_reset_byte_fr_n_i	(rx_reset_byte_fr_n_sync),
	.csi_dphy_rx_reset_byte_n_i		(rx_reset_byte_fr_n_sync),
	.csi_dphy_rx_reset_lp_n_i		(rx_reset_lp_n),
	.csi_dphy_rx_reset_n_i			(int_rst_n),
	.csi_dphy_rx_pll_lock_i			(1'b1),
// Outputs
	.csi_dphy_rx_clk_byte_o			(rx_clk_byte),
	.csi_dphy_rx_clk_byte_hs_o		(rx_clk_byte_hs),
	.csi_dphy_rx_cd_d0_o			(),
	.csi_dphy_rx_lp_d0_rx_p_o		(),
	.csi_dphy_rx_lp_d0_rx_n_o		(),
	.csi_dphy_rx_lp_d1_rx_p_o		(),
	.csi_dphy_rx_lp_d1_rx_n_o		(),
	.csi_dphy_rx_ref_dt_i			(ref_dt),
	.csi_dphy_rx_sp_en_o			(rx_sp_en),
	.csi_dphy_rx_lp_en_o			(rx_lp_en),
	.csi_dphy_rx_lp_av_en_o			(rx_lp_av_en),
	.csi_dphy_rx_vc_o				(),
	.csi_dphy_rx_dt_o				(rx_dt),
	.csi_dphy_rx_wc_o				(rx_wc),
	.csi_dphy_rx_ecc_o				(),
	.csi_dphy_rx_bd_o				(),
	.csi_dphy_rx_payload_o			(rx_payload),
	.csi_dphy_rx_payload_en_o		(rx_payload_en),
///// debug signals
	.csi_dphy_rx_hs_d_en_o				(rx_hs_d_en),
	.csi_dphy_rx_hs_sync_o				(rx_hs_sync),
	.csi_dphy_rx_term_clk_en_o			(rx_term_clk_en),
	.csi_dphy_rx_lp_hs_state_clk_o		(rx_lp_hs_state_clk),
	.csi_dphy_rx_lp_hs_state_d_o		(rx_lp_hs_state_d)
);

//	Reset Bridge for pixel clock rst
reset_bridge rst_pixel_clk(
  .clk_i			(clk_pixel_pll),// Destination clock
  .ext_resetn_i		( reset_n_i ),// Asynchronous reset signal
  .sync_resetn_out	(reset_pixel_n_sync_x)// Synchronized reset signal
);

/*--------- BYTE2PIXEL-----------------*/
byte_pixel byte_pixel (
	.byte2pix_clk_byte_i			(rx_clk_byte_fr),
	.byte2pix_reset_byte_n_i		(rx_reset_byte_fr_n_sync),
	
	.byte2pix_clk_pixel_i		(clk_pixel_pll),
	.byte2pix_reset_pixel_n_i	(reset_pixel_n_sync_x),
	
	.byte2pix_sp_en_i			(rx_sp_en),
	.byte2pix_lp_av_en_i		(rx_lp_av_en),
	.byte2pix_dt_i				(rx_dt),
	.byte2pix_wc_i				(rx_wc),
	.byte2pix_payload_i			(rx_payload),
	.byte2pix_payload_en_i		(rx_payload_en),
	
	.byte2pix_fv_o				(fv_o),
	.byte2pix_lv_o				(lv_o),
	.byte2pix_pd_o				(pd0_o),
	.byte2pix_p_odd_o			(p_odd)
);

endmodule 
