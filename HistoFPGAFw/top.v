module topmod
(
	//I2C Interface
	inout			SDA,
	output			SCL,

	input          FSIN,
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
reg reset_n_i = 1; // replace this!
wire clk_osc, clk_pixel, pll_lock, clk_mipi;

defparam int_osc.HFCLKDIV = 4'd1;
OSCI int_osc
(
	.HFOUTEN	(1'b1),
	.HFCLKOUT	(clk_osc),
	.LFCLKOUT	()
);
/*
pll pll_inst (
	.CLKI	( clk_mipi  ),
	.CLKOP	(clk_pixel),    // 84 MHz
	.LOCK	(pll_lock)
);*/

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

/*------------------Cammera Communication--------------------*/
//	MIPI DPHY to CMOS module : It converts the MIPI camera input to Parallel video data at clock "clk_pixel"



/*mipidphy2cmos mipidphy2cmos
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
 	.rx_clk_byte_fr_o	(rx_clk_byte_fr),
 	.clk_pixel_i		(clk_pixel_hs),
 	.pll_lock_i			(pll_lock)
 );
*/


assign DIFF_P = clk_osc;

endmodule