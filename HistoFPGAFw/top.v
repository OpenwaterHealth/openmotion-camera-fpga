module topmod
(
	//I2C Interface
	inout			SDA,
	output			SCL,

	output          FSIN,
	output			GPIO0,
	output			GPIO1,
	

	// Camera MIPI input
	inout 			CK_P,
	inout 			CK_N,
	inout 			D0_P,
	inout 			D0_N,
	inout 			D1_P,
	inout 			D1_N,

    // Diff Interface
    output          DIFF_P,
    output          DIFF_N
);

/*------------------Clocks and Resets--------------------*/
wire reset_n_i; // pull gpio0 low when you want to do a reset
wire clk_osc, clk_pixel, clk_pixel_hs, pll_lock, clk_mipi;

defparam int_osc.HFCLKDIV = 4'd1;
OSCI int_osc
(
	.HFOUTEN	(1'b1),
	.HFCLKOUT	(clk_osc),
	.LFCLKOUT	()
);

pll_i pll_inst (
	.CLKI	( clk_mipi  ),  // 83 MHz, from the mipi clk
	.CLKOP	(clk_pixel),    // 84 MHz, buffered
	.CLKOS  (clk_pixel_hs), // 132.8MHz
	.LOCK	(pll_lock)
);

wire clk_fsin;
clk_divider_40Hz __ (
	.clk_48MHz 	(clk_osc),
	.reset		(~reset_n_i),
	.clk_40Hz	(clk_fsin)
	);

//	Reset Bridge for clk_osc
reset_bridge rst_brg_osc(
  .clk_i			(clk_osc),// Destination clock
  .ext_resetn_i		( reset_n_i ),// Asynchronous reset signal
  .sync_resetn_out	(reset_n_HFCLKOUT)// Synchronized reset signal
);
reset_bridge rst_brg_mipi(
  .clk_i			(clk_osc),// Destination clock
  .ext_resetn_i		( reset_n_HFCLKOUT ),// Asynchronous reset signal
  .sync_resetn_out	(mipi_reset_n_o)// Synchronized reset signal
);

/*------------------Camera Communication--------------------*/
//	MIPI DPHY to CMOS module : It converts the MIPI camera input to Parallel video data at clock "clk_pixel"
wire [9:0] cmos_data;
wire cmos_fv;
wire cmos_lv;
mipidphy2cmos mipidphy2cmos
 (
 	.reset_n_i			(mipi_reset_n_o), // Changed to test 1080p resolution
 	.rx_clk_p_i			(CK_P),
 	.rx_clk_n_i			(CK_N),
 	.rx_d0_p_i			(D0_P),
 	.rx_d0_n_i			(D0_N),
 	.rx_d1_p_i			(D1_P),
 	.rx_d1_n_i			(D1_N),
 	.pd0_o				( cmos_data ),
 	.fv_o				(  cmos_fv ),
 	.lv_o				(  cmos_lv ),
 	.rx_clk_byte_fr_o	(clk_mipi),
 	.clk_pixel_i		(clk_pixel_hs),
 	.pll_lock_i			(pll_lock),
	.rx_payload_en 		(dbg)
 );

/*------------------Output Pin Assignments--------------------*/
//assign SDA;
//assign SCL;
assign FSIN = clk_fsin;
assign DIFF_P = dbg;//clk_pixel_hs;
assign DIFF_N = clk_osc;
//assign GPIO0 = reset_n_i;
assign reset_n_i = 1;
assign GPIO1 = 0;//cmos_data[0];

endmodule