////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	(c) 2020-2021, Cypress Semiconductor Corporation (an Infineon company) or an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
//
//	This software, including source code, documentation and related materials ("Software") is owned by Cypress Semiconductor Corporation or one of its affiliates
//	("Cypress") and is protected by and subject to worldwide patent protection (United States and foreign), United States copyright laws and international treaty
//	provisions.  Therefore, you may use this Software only as provided in the license agreement accompanying the software package from which you obtained this
//	Software ("EULA").
//	If no EULA applies, Cypress hereby grants you a personal, non-exclusive, non-transferable license to copy, modify, and compile the Software source code solely
//	for use in connection with Cypress's integrated circuit products.  Any reproduction, modification, translation, compilation, or representation of this Software
//	except as specified above is prohibited without the express written permission of Cypress.
//
//	Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress reserves the right to make changes to the Software without notice. Cypress does
//	not assume any liability arising out of the application or use of the Software or any product or circuit described in the Software. Cypress does not authorize
//	its products for use in any products where a malfunction or failure of the Cypress product may reasonably be expected to result in significant property damage,
//	injury or death ("High Risk Product"). By including Cypress's product in a High Risk Product, the manufacturer of such system or application assumes all risk of
//	such use and in doing so agrees to indemnify Cypress against all liability.
//
//	Design Name:
//	Module Name:	topmod
//	Target Devices:	LIF-MD6000
//	Description:	This project recevies the MIPI video data from the image sensor and converts it into parallel data.
// 					The parallel video data is then buffered and sent to SX3 via a SlaveFIFO interface in sockets 0,1 at 83.75 MHz.
//					It also provides a I2C Slave with internal registers to communicate with SX3.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//`include "parameters.v"

`timescale 1 ps / 1 ps

module topmod
(
	input			reset_n_i,

	// Camera MIPI input
	inout 			rx_clk_p_i,
	inout 			rx_clk_n_i,
	inout 			rx_d0_p_i,
	inout 			rx_d0_n_i,
	inout 			rx_d1_p_i,
	inout 			rx_d1_n_i,

	//	SX3 I2C Interface
	inout			sx3_i2c_sda_io,
	input			sx3_i2c_scl_io,

    // Mic Interface
    input           mic_pdm_data_i,
    output          mic_clk_o,

	//	SX3 SlaveFIFO Interface
	input			flaga_i,
	input			flagb_i,

	output [1:0]	sl_addr_o,
	output [9:0]	sldata_o,
	
	//output pll_lock,
	output			slwr_o,
	 output			slrd_o,
	output 			sloe_o,
	output 			slcs_o,
	output 			pktend_o,
	output 			slclk_o,
	
	output 	cam_fifo_overflow,
	
	output buf_done_o,
	output cam_clk,
	output [5:0] debug
);


// sx3

wire [1:0]cur_gpif_st_o;
wire buf_done_o;
wire app_stop;


localparam IMG_SZ_BUS_WDT = 'd32;

// Internal Oscillator
// 1 -> 48MHz, 2 -> 24MHz, 4 -> 12MHz, 8 -> 6MHz
// Possible Values: 1, 2, 4 and 8.
localparam INT_OSC_CLK_DIVIDER = 4'd1;

// Internal Oscillator Clock Value
localparam INT_OSC_CLK_VALUE = ( 32'd48_000_000 / INT_OSC_CLK_DIVIDER );

// PCLK Value
// It must be changed when PLL configuration is changed.
localparam PCLK_VALUE = 32'd84_000_000;

// Revision of SX3 Board
localparam REV2		=	0;
localparam REV3 	=	1;

// UVC_FV_LV / U3V/ UVC_SlaveFIFO  Standard 
localparam U3V=0;
localparam UVC_FL=1;

//-----------------------------------------------------------------------------
//	Wire and Register declarations
//-----------------------------------------------------------------------------
wire [2:0] current_stream_in_state;

wire clk_pixel;
wire reset_n_pixclk;
wire reset_n_aud_pixclk;
wire reset_n_vid_pixclk;
wire sync_bclk_reset_n;
wire clk_osc;
wire reset_n_HFCLKOUT;

wire cam_app_en;
wire aud_app_en;
wire slfifo_st_vidrst;
wire slfifo_st_audrst;
wire [9:0] cmos_data;
wire [15:0] vid_buf_dout;
wire [31:0] img_size;
wire [15:0] img_wt;
wire [15:0] img_ht;
wire vid_buf_dvld;
wire cam_fv_pe_pl;
wire cam_fv_ne_pl;

wire cmos_fv;
wire cmos_lv;
wire cam_fifo_overflow;
wire rx_clk_byte_fr;

wire pll_lock;

wire vid_pktend_st;
wire vid_fifo_rd_req;
wire vid_fifo_almost_empty;
wire vid_fifo_almost_full;

wire slfifo_st_vidrst_osc;
wire slfifo_st_audrst_osc;
wire cam_app_en_osc;
wire aud_app_en_osc;
wire still_cap_en_osc;
wire [15:0]img_wt_osc;
wire [15:0]img_ht_osc;
wire [31:0]img_size_osc;
wire [15:0]img_width;
wire [15:0]img_height;

wire [15:0] aud_fifo_rd_data;
wire [11:0] aud_fifo_rd_count;
wire aud_fifo_data_vld;
wire aud_fifo_almost_empty;
wire aud_fifo_empty;
wire aud_fifo_rd_req;
wire aud_pktend;
wire still_cap_en_osc;
wire still_cap_en;
wire vid_pktend;

wire [ 1:0] gpif_buf_wdt;
wire [15:0] tp_data;

reg [31:0] clk_in_value;
reg [15:0] img_ht_osc;
reg [31:0] data_i;
reg        still_cap_done;
reg        vid_tp_en_r;
reg vid_fifo_rst_1;
reg vid_fifo_rst_2;
reg data_vld_i;
reg vsync_r;
reg vsync_r1;
reg vsync_r2;
reg tp_busy_r;
reg [23:0]vsync_rr;
reg [31:0] data_cnt;
wire [15:0]sldata_r;
wire slrd_r;
wire  sloe_r;
reg uvc_fl=1'd0;
reg u3v =1'd0;

/******** flag_a and flag_b registers ********/
reg flag_a;
reg flag_b;

wire [ 7:0] vid_fps_osc;
wire [ 7:0] vid_fps;
wire [15:0] line_blanking_osc;
wire [15:0] line_blanking;
//wire mic_clk_o;
// Internal Oscillator
// 1 -> 48MHz, 2 -> 24MHz, 4 -> 12MHz, 8 -> 6MHz
defparam int_osc.HFCLKDIV = INT_OSC_CLK_DIVIDER;
OSCI int_osc
(
	.HFOUTEN	(1'b1),
	.HFCLKOUT	(clk_osc),
	.LFCLKOUT	()
);

//	PLL Instance for 720p and 1080p resolution.
pll_ip pll_inst (
	.CLKI	( rx_clk_byte_fr /* clk_osc*/ ),
	.CLKOP	(clk_pixel1),    // 84 MHz
	.CLKOS	(clk_pixel),  // 84 MHz
	.LOCK	(pll_lock)
);


//	Reset Bridge for clk_pixel
reset_bridge vid_mod_reset(
  .clk_i			(clk_pixel),// Destination clock
  .ext_resetn_i		(cam_app_en_osc &  reset_n_i &  pll_lock),// Asynchronous reset signal
  .sync_resetn_out	(reset_n_vid_pixclk)// Synchronized reset signal
);

//	Reset Bridge for clk_pixel
reset_bridge gpif_mod_reset(
  .clk_i			(clk_pixel),// Destination clock
  .ext_resetn_i		( reset_n_i &  pll_lock),// Asynchronous reset signal
  .sync_resetn_out	(reset_n_pixclk)// Synchronized reset signal
);

//	Reset Bridge for clk_audio
reset_bridge aud_mod_reset(
  .clk_i			(clk_pixel),// Destination clock
  .ext_resetn_i		(aud_app_en_osc &  reset_n_i &  pll_lock), // Asynchronous reset signal
  .sync_resetn_out	(reset_n_aud_pixclk)// Synchronized reset signal
);

//	Reset Bridge for clk_osc
reset_bridge rst_brg_osc(
  .clk_i			(clk_osc),// Destination clock
  .ext_resetn_i		( reset_n_i ),// Asynchronous reset signal
  .sync_resetn_out	(reset_n_HFCLKOUT)// Synchronized reset signal
);

// Generate Block for selecting SX3 Revision
generate 
always @(*) begin
	if(REV2) begin		 flag_a <= flagb_i;
		 flag_b <= flaga_i;
	end
	else if(REV3) begin
		 flag_a <= flaga_i;
		 flag_b <= flagb_i;
	end
end
endgenerate

// --------------------------------
//
// MIPI IP Reset Manager
//
// --------------------------------

 mipi_ip_reset_manager
   #
   (
    .REF_CLOCK_VALUE_I              ( INT_OSC_CLK_VALUE ),
    .MIPI_IP_RESET_LOW_TIME_IN_MS_I ( 32'd300 )
   )
   mirm
   (
    .clk                      ( clk_osc ),
    .reset_n                  ( reset_n_HFCLKOUT ),
    .cam_app_en_i             ( cam_app_en_osc ),
    .aud_app_en_i             ( aud_app_en_osc ),
    .mipi_reset_n_o           ( mipi_reset_n_o ),
    .reset_counter_is_low_o   ( reset_counter_is_low_o ),
    .reset_counter_is_high_o  ( reset_counter_is_high_o )
   );


// ODDR to drive GPIF Clock out
ODDRX1F SX3_CLOCK ( .D0(1'b1), .D1(1'b0), .SCLK(clk_pixel), .RST(1'b0), .Q(slclk_o) );


//	MIPI DPHY to CMOS module : It converts the MIPI camera input to Parallel video data at clock "clk_pixel"
 mipidphy2cmos mipidphy2cmos
 (
 	.reset_n_i			(mipi_reset_n_o), // Changed to test 1080p resolution
 	.rx_clk_p_i			(rx_clk_p_i),
 	.rx_clk_n_i			(rx_clk_n_i),
 	.rx_d0_p_i			(rx_d0_p_i),
 	.rx_d0_n_i			(rx_d0_n_i),
 	.rx_d1_p_i			(rx_d1_p_i),
 	.rx_d1_n_i			(rx_d1_n_i),
 	.pd0_o				( cmos_data ),
 	.fv_o				(  cmos_fv ),
 	.lv_o				(  cmos_lv ),
 	.rx_clk_byte_fr_o	(rx_clk_byte_fr),
 	.clk_pixel_i		(clk_pixel1),
 	.pll_lock_i			(pll_lock),
	//.test_out           (mic_clk_o),
	.debug				(debug)
 );
 
assign  mic_clk_o = cmos_fv;
 
assign sldata_o= 10'b1010101010;//UVC_FL ?  cmos_data : sldata_r;
assign slrd_o =  UVC_FL ?  cmos_lv : slrd_r;
assign sloe_o =  UVC_FL ?  cmos_fv : sloe_r;

//	Video Buffer Module : Buffers the video data whne the Slave FIFO interface is busy
vid_buf_mod vid_buf_mod
(
	.clk_i					  (clk_pixel),
	.rstn_i					  (reset_n_vid_pixclk),

	.cam_app_en_i			  (cam_app_en),
	// .gpif_fifo_almostfull_i	(gpif_fifo_almostfull),
	.vid_fifo_rd_req_i   	  (vid_fifo_rd_req),
	.cam_fv_i				  (cmos_fv),
	.cam_lv_i				  (cmos_lv),
	.cam_data_i				  ({16'd0,cmos_data} /*tp_data*/),  // 32 bit data
    .pktend_st_i              (vid_pktend_st),
	.vid_fifo_rd_data_o		  (vid_buf_dout),
	.vid_fifo_data_vld_o	  (vid_buf_dvld),
	.vid_fifo_almost_empty_o  (vid_fifo_almost_empty),
	.vid_fifo_almost_full_o   (vid_fifo_almost_full),
	.cam_fifo_overflow_o	  (cam_fifo_overflow),
	.cam_fv_pe_pl_o	          (cam_fv_pe_pl),
	.cam_fv_ne_pl_o	          (cam_fv_ne_pl)
);

//	GPIF Interface Topmod : This controls the GPIF interface between FPGA and SX3
gpif_interface_top#
(
	.IS_U3V							(U3V)
)
gpif_interface_top
(
	//	Global Inputs
	.clk_i				      (clk_pixel),
	.rstn_i				      (reset_n_pixclk),

	.cam_app_en_i		      (cam_app_en),
	.aud_app_en_i		      (aud_app_en),
	.vid_skt_rst_i		      (slfifo_st_vidrst),
	.aud_skt_rst_i		      (slfifo_st_audrst),
	.flaga_i			      (flag_a), 
	.flagb_i			      (flag_b), 
	.frame_size_i		      (img_size),
	.vid_fifo_rd_data_i		  (vid_buf_dout),
	.vid_fifo_data_vld_i	  (vid_buf_dvld),
	.vid_fifo_almost_empty_i  (vid_fifo_almost_empty),
	.cam_fifo_overflow_i      (cam_fifo_overflow),
	.cam_fv_i			      (cmos_fv),
	.cam_fv_pe_pl_i		      (cam_fv_pe_pl),
	.cam_fv_ne_pl_i		      (cam_fv_ne_pl),
	.cam_lv_i				  (cmos_lv),
    .vid_frame_width_i        (img_width),  // Video frame width
    .vid_fifo_rd_req_o        (vid_fifo_rd_req),
    .vid_pktend_st_o          (vid_pktend_st),
    .vid_pktend_o             (vid_pktend),
    .aud_fifo_rd_count_i      (aud_fifo_rd_count     ),
    .aud_fifo_rd_data_i       (aud_fifo_rd_data     ),
    .aud_fifo_data_vld_i      (aud_fifo_data_vld    ),
    .aud_fifo_almost_empty_i  (aud_fifo_almost_empty),
    .aud_fifo_empty_i         (aud_fifo_empty       ),
    .aud_fifo_rd_req_o        (aud_fifo_rd_req      ),
    .aud_pktend_o             (aud_pktend           ),
	// SlaveFIFO Interface outputs
	.sl_addr_o			      (sl_addr_o),
	.sldata_o			      (	sldata_r),
	.slrd_o				      ( slrd_r ),
	.sloe_o				      (sloe_r),
	
	.slwr_o				      (slwr_o),
	.slcs_o				      (slcs_o),
	.pktend_o			      (pktend_o),
	.aud_fifo_rd_count_o      (aud_fifo_rd_count_o),
	.cur_gpif_st              (cur_gpif_st_o),
	.buf_done_o	              (buf_done_o),
	.current_stream_in_state_o	  (current_stream_in_state_o),
	.vid_fifo_rd_counter_check_o  (vid_fifo_rd_counter_check_o),
	.watermark_count_o            (watermark_count_o),
	.fifo_ae                      (fifo_ae),
	.fifo_rden_rw                 (fifo_rden_rw),
	.vid_frame_end                (vid_frame_end),
	.send_traling_zlp             (send_traling_zlp),
	.send_leading_zlp             (send_leading_zlp),
	.full_fx3_bufr_rd_o           (full_fx3_bufr_rd_o),
	.full_fx3_bufr_wr_o           (full_fx3_bufr_wr_o),
	.vid_frame_word_counter_max_value_o           (vid_frame_word_counter_max_value_o),
	.app_stop_i 					(app_stop)
	
//	.pktend_frc_r				(pktend_frc_r),

);

reg [15:0] img_height = 16'd1280;
assign img_ht_osc = img_height;
reg [15:0] img_width = 16'd1920;
assign img_wt_osc = img_width;
reg [31:0] img_size = 16'd2457600;
assign img_size_osc = img_size;


reg HIGH = 1'b1;
assign cam_app_en_osc = HIGH;
assign cam_app_en = HIGH;
//	I2C Slave module
i2c_slave
fx3_i2c_slave_if
(
	//	Interface Inouts
	.sl_sda_io			(sx3_i2c_sda_io),// I2C SDA input
	.sl_scl_io			(sx3_i2c_scl_io),	// I2C SCL input

	//	Global Inputs
	.reset_n_i			(reset_n_HFCLKOUT),
	.clock_i			(clk_osc),

	//	Control Signals
	.slfifo_st_vidrst_o	(slfifo_st_vidrst_osc),	// video channel reset
	.slfifo_st_audrst_o	(slfifo_st_audrst_osc),	// audio channel reset
	.img_wt_o			(),	// Number of pixels in a line
	.img_ht_o			(),	// Number of lines ina  frame
	.img_size_o			(),	// Number of pixels in a frame
	.cam_app_en_o		(),	// Video Streaming Applicaton enable
	.aud_app_en_o		(aud_app_en_osc),	// Audio Applicaton enable
	.still_cap_en_o		(still_cap_en_osc),// Still capture pin
	.gpif_buf_wdt_o		(gpif_buf_wdt),
	.vid_fps_o          (vid_fps_osc),
	.h_blanking_o		(line_blanking_osc),
	.app_stop			(app_stop)

);

//	I2C Control Signals Clock Domain Crossing between the clk_osc and clk_pixel
bus_sync_mod
#( .BUS_WDT(IMG_SZ_BUS_WDT))
sync_img_size
(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .en_sync_i	(cam_app_en),	// Synchronizing clock enable
  .data_src_i	(img_size_osc),	// Input signal
  .data_sync_o	(img_size)	// Synchronized data out
);
bus_sync_mod
#( .BUS_WDT(IMG_SZ_BUS_WDT))
sync_img_width
(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .en_sync_i	(cam_app_en),	// Synchronizing clock enable
  .data_src_i	({16'h0, img_wt_osc}),	// Input signal
  .data_sync_o	(img_width)	// Synchronized data out
);

bus_sync_mod
#( .BUS_WDT(IMG_SZ_BUS_WDT))
sync_img_height
(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .en_sync_i	(cam_app_en),	// Synchronizing clock enable
  .data_src_i	({16'h0, img_ht_osc}),	// Input signal
  .data_sync_o	(img_height)	// Synchronized data out
);
/*
bit_synchronizer sync_cam_en(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .data_src_i	(cam_app_en_osc),	// Input signal
  .data_sync_o	(cam_app_en)	// Synchronized data out
);*/

/*bit_synchronizer sync_aud_en(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .data_src_i	(aud_app_en_osc),	// Input signal
  .data_sync_o	(aud_app_en)	// Synchronized data out
);*/
assign aud_app_en = HIGH;

bit_synchronizer sync_vidrst(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .data_src_i	(slfifo_st_vidrst_osc),	// Input signal
  .data_sync_o	(slfifo_st_vidrst)	// Synchronized data out
);

bit_synchronizer sync_audrst(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .data_src_i	(slfifo_st_audrst_osc),	// Input signal
  .data_sync_o	(slfifo_st_audrst)	// Synchronized data out
);

bit_synchronizer sync_still_cap(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .data_src_i	(still_cap_en_osc),	// Input signal
  .data_sync_o	(still_cap_en)	// Synchronized data out
);

bus_sync_mod
#( .BUS_WDT(IMG_SZ_BUS_WDT))
sync_vid_fps
(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .en_sync_i	(cam_app_en),	// Synchronizing clock enable
  .data_src_i	(vid_fps_osc),	// Input signal
  .data_sync_o	(vid_fps)	// Synchronized data out
);

bus_sync_mod
#( .BUS_WDT(IMG_SZ_BUS_WDT))
sync_line_blanking
(
  .clk_src_i	(clk_osc),	// Source clock
  .clk_sync_i	(clk_pixel),	// Synchronizing clock
  .en_sync_i	(cam_app_en),	// Synchronizing clock enable
  .data_src_i	(line_blanking_osc),	// Input signal
  .data_sync_o	(line_blanking)	// Synchronized data out
);

reg cam_clk = 1'b0;
always @(posedge clk_osc) begin
	cam_clk <= ~cam_clk;
end

endmodule
