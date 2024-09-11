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


//-----------------------------------------------------------------------------
//	Wire and Register declarations
//-----------------------------------------------------------------------------
wire clk_osc;
wire rx_clk_byte_fr;
wire clk_pixel;
wire clk_pixel_hs;
wire pll_lock;

wire reset_n_HFCLKOUT;
reg mipi_reset_n_o;

wire [9:0] cmos_data;
wire cmos_fv;
wire cmos_lv;


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
	.CLKOP	(clk_pixel),    // 84 MHz
	//.CLKOS	(clk_pixel),  // 84 MHz
	.CLKOS2 (clk_pixel_hs),
	.LOCK	(pll_lock)
);

//	Reset Bridge for clk_osc
reset_bridge rst_brg_osc(
  .clk_i			(clk_osc),// Destination clock
  .ext_resetn_i		( reset_n_i ),// Asynchronous reset signal
  .sync_resetn_out	(reset_n_HFCLKOUT)// Synchronized reset signal
);

// Reset synchronizer for mipi module
always @ ( posedge clk_osc or negedge reset_n_HFCLKOUT )
begin
  if ( ~reset_n_HFCLKOUT )
	begin
	  mipi_reset_n_o <= 1'b0;
	end
  else begin mipi_reset_n_o <= 1'b1; end
end

// Clock generator for 250MHz pixel clock
reg clk_pixel3;
always @(posedge clk_pixel_hs or negedge mipi_reset_n_o) begin
	if (~mipi_reset_n_o) begin
		clk_pixel3 <= 0;
	end
	else begin
		clk_pixel3 <= ~clk_pixel3;
	end
end

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
 	.clk_pixel_i		(clk_pixel3),
 	.pll_lock_i			(pll_lock),
	//.test_out           (mic_clk_o),
	.debug				(debug)
 );
 
// assign the outputs from the camera to the GPIOS
assign  mic_clk_o = clk_pixel3;
assign sldata_o = cmos_data;
assign slrd_o =  cmos_lv;
assign sloe_o =  cmos_fv;

/*---------------------HISTOGRAM-----------------------------------*/

wire line_valid = cmos_lv;            // Line synchronization signal
wire frame_valid = cmos_fv;           // Frame synchronization signal
wire [9:0] pixel_data = cmos_data;      // 16-bit bus for pixel data
wire pixel_valid = frame_valid && line_valid;


// Control
wire histo_done;
wire serializer_done;

parameter IDLE = 0, IMAGE = 1, HISTO = 2, SERIALIZE = 3;
reg [1:0] state = 0;

always @(posedge frame_valid, posedge histo_done, posedge serializer_done) begin
	if(frame_valid && state == IDLE) begin
		state <= HISTO;
	end else if (histo_done && state == HISTO) begin
		state <= SERIALIZE;
		bin <= 0;
	end else if (serializer_done && state == SERIALIZE) begin
		if(bin == 1023) begin
			state <= IDLE;
		end else begin
			bin <= bin + 1;
		end
	end
end

// Histogram generator
wire [23:0] data; 
reg [9:0] bin;

histogram2 histo_i (
	.clk(clk),          // reset - zeros the histogram
	.fast_clk(fast_clk),
	.rst(cam_en),          // clock
	
	.pixel (pixel_data),  // 10 bit data for each pixel
	.pixel_valid (pixel_valid),
	.data(data),       //    when writing, on every rising edge of CLK adds one to the histogram
	.bin(bin),
	
	.rw(frame_valid),           // read/write, when reading outputs histo data/bin num until done
	.image_done(~frame_valid),
	.histo_done(histo_done)
);

// Serializer
wire uart;
Serializer seralizer_i (
	.fast_clk_in(uart_clk),
	.reset((state != SERIALIZE)),
	.data_in(data),
	.serial_out(uart),
	.slow_clk_out(),
	.done(serializer_done)
);
    






















/* in theory everything below this is superflous and should be deleted */
// UVC_FV_LV / U3V/ UVC_SlaveFIFO  Standard 
localparam U3V=0;
localparam UVC_FL=1;

// ODDR to drive GPIF Clock out
ODDRX1F SX3_CLOCK ( .D0(1'b1), .D1(1'b0), .SCLK(clk_pixel), .RST(1'b0), .Q(slclk_o) );


// sx3
wire [1:0]cur_gpif_st_o;
wire buf_done_o;


wire [15:0] vid_buf_dout;
wire [15:0] img_wt;
wire [15:0] img_ht;
wire vid_buf_dvld;
wire cam_fv_pe_pl;
wire cam_fv_ne_pl;

wire vid_pktend_st;
wire vid_fifo_rd_req;
wire vid_fifo_almost_empty;
wire vid_fifo_almost_full;

wire slfifo_st_vidrst_osc;
wire slfifo_st_audrst_osc;
wire cam_app_en_osc;
wire aud_app_en_osc;
wire still_cap_en_osc;
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
wire cam_app_en;
wire aud_app_en;
wire slfifo_st_vidrst;
wire slfifo_st_audrst;

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

wire [2:0] current_stream_in_state;
wire [ 1:0] gpif_buf_wdt;



wire [15:0]img_wt_osc;
wire [ 7:0] vid_fps_osc;
wire [ 7:0] vid_fps;
wire [15:0] line_blanking_osc;
wire [15:0] line_blanking;

wire cam_fifo_overflow;

wire reset_n_vid_pixclk;
//	Reset Bridge for clk_pixel
reset_bridge vid_mod_reset(
  .clk_i			(clk_pixel),// Destination clock
  .ext_resetn_i		(cam_app_en_osc &  reset_n_i &  pll_lock),// Asynchronous reset signal
  .sync_resetn_out	(reset_n_vid_pixclk)// Synchronized reset signal
);

wire reset_n_pixclk;
//	Reset Bridge for clk_pixel
reset_bridge gpif_mod_reset(
  .clk_i			(clk_pixel),// Destination clock
  .ext_resetn_i		( reset_n_i &  pll_lock),// Asynchronous reset signal
  .sync_resetn_out	(reset_n_pixclk)// Synchronized reset signal
);



//	Video Buffer Module : Buffers the video data whne the Slave FIFO interface is busy
vid_buf_mod vid_buf_mod
(
	.clk_i					  (clk_pixel),
	.rstn_i					  (reset_n_vid_pixclk),

	.cam_app_en_i			  (cam_app_en),
	// .gpif_fifo_almostfull_i	(gpif_fifo_almostfull),
	.vid_fifo_rd_req_i   	  (vid_fifo_rd_req),
	.cam_fv_i				  (1),////??????????
	.cam_lv_i				  (1),
	.cam_data_i				  (32'd0 ),  // 32 bit data
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
	.flaga_i			      (0), 
	.flagb_i			      (0), 
	.frame_size_i		      (img_size),
	.vid_fifo_rd_data_i		  (vid_buf_dout),
	.vid_fifo_data_vld_i	  (vid_buf_dvld),
	.vid_fifo_almost_empty_i  (0),
	.cam_fifo_overflow_i      (0),
	.cam_fv_i			      (1),
	.cam_fv_pe_pl_i		      (cam_fv_pe_pl),
	.cam_fv_ne_pl_i		      (cam_fv_ne_pl),
	.cam_lv_i				  (1),
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
	.app_stop_i 					(0)
);

reg [31:0] img_size = 16'd2457600;

reg [15:0] img_height = 16'd1280;
assign img_ht_osc = img_height;
reg [15:0] img_width = 16'd1920;
assign img_wt_osc = img_width;


reg HIGH = 1'b1;
assign cam_app_en_osc = HIGH;
assign cam_app_en = HIGH;
assign img_width = {16'h0, img_wt_osc};
assign img_height = {16'h0, img_ht_osc};
assign aud_app_en = HIGH;
assign slfifo_st_vidrst =slfifo_st_vidrst_osc;
assign slfifo_st_audrst = slfifo_st_audrst_osc;
assign still_cap_en = still_cap_en_osc;
assign vid_fps = vid_fps_osc;
assign line_blanking = line_blanking_osc;

reg cam_clk = 1'b0;
always @(posedge clk_osc) begin
	cam_clk <= ~cam_clk;
end

endmodule
