module topmod
  (
    //I2C Interface
    inout			SDA,
    input			SCL,

    output          FSIN,
    input			GPIO0,
    input			GPIO1,


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
  wire clk_lf;

  defparam int_osc.HFCLKDIV = 4'd1;
  OSCI int_osc
       (
         .HFOUTEN	(1'b1),
         .HFCLKOUT	(clk_osc),
         .LFCLKOUT	(clk_lf)
       );

  pll_i pll_inst (
          .CLKI	( clk_mipi  ),  // 83 MHz, from the mipi clk
          .CLKOP	(clk_pixel),    // 84 MHz, buffered
          .CLKOS  (clk_pixel_hs), // 132.8MHz
          .LOCK	(pll_lock)
        );

  wire clk_fsin;
  clk_divider_40Hz __ (
                     .clk_48MHz 	(clk_lf),
                     .reset		(~reset_n_i),
                     .clk_40Hz	(clk_fsin)
                   );

  //	Reset Bridge for clk_osc
  reset_bridge rst_brg_osc(
                 .clk_i			(clk_osc),// Destination clock
                 .ext_resetn_i		( reset_n_i ),// Asynchronous reset signal
                 .sync_resetn_out	(reset_n_HFCLKOUT)// Synchronized reset signal
               );

  /*------------------Camera Communication--------------------*/
  //	MIPI DPHY to CMOS module : It converts the MIPI camera input to Parallel video data at clock "clk_pixel"
  wire [19:0] cmos_data;
  wire cmos_fv;
  wire cmos_lv;
  mipidphy2cmos mipidphy2cmos
                (
                  .reset_n_i			(reset_n_HFCLKOUT), // Changed to test 1080p resolution
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
                  .pll_lock_i			(pll_lock)
                );

  /*------------------Histogram Module--------------------*/
  wire spi_mosi, spi_clk, spi_en;
  histogram_module histogram_module_i(
                     .clk 		(clk_pixel_hs),
                     .reset		(~reset_n_HFCLKOUT),
                     .pixel_data (cmos_data),
                     .frame_valid (cmos_fv),
                     .line_valid (cmos_lv),
                     .spi_clk_i 	(clk_pixel_hs),
                     .spi_mosi_o (spi_mosi),
                     .spi_clk_o (spi_clk),
                     .spi_en    (spi_en),
                     .debug		(),
                     .debug2	    ()
                   );

  /*------------------Output Pin Assignments--------------------*/
  assign SDA = 1'bz;
  //assign SCL = 1'bz;
  assign FSIN = 1'bz;
  assign DIFF_P = spi_en & spi_mosi;
  assign DIFF_N = spi_en & spi_clk;
  assign reset_n_i = GPIO0; 		
  assign spi_en = 1'b1;//~GPIO1;			//needs to be active low because i need to keep this one high through boot because its also cdone

endmodule
