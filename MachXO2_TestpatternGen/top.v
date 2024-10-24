module top (
    input stdby_in,       // Standby input
    output stdby1,        // Standby output
    output osc_clk,       // Oscillator clock output
    output led0, led1, led2, led3, led4, led5, led6, led7, // LED outputs
    output [15:0] debug
);


/*output frame_valid,   // Frame valid signal for scope
    output line_valid,        // Line valid signal for scope
    output [9:0] histo_data,  // 10-bit histogram data output
	output pixel_clk,
    output histo_valid,       // Histogram data valid signal
    output histo_clock        // Histogram clock signal
	*/
	
    wire stby_flag;
    reg [23:0] cnt;
    reg [9:0] rd_addr;         // Read address for histogram
    reg [10:0] histo_count;    // Counter for 1024 histogram readout cycles
    reg rd_en;                 // Histogram read enable
    reg histo_clear;           // Histogram clear signal
    reg histo_valid_reg;       // Register for histogram valid signal
    reg histo_clock_reg;       // Register for histogram clock
    reg histo_reading;         // Indicates if histogram is being read
	
	
	/*------------------------------------- Clock Stuff ----------------------------*/

    // Internal Oscillator
    defparam OSCH_inst.NOM_FREQ = "19.00";	// 133 MHz clock

    OSCH OSCH_inst(
        .STDBY(stdby1), 	// 0=Enabled, 1=Disabled also Disabled with Bandgap=OFF
        .OSC(osc_clk),      // Oscillator clock output
        .SEDSTDBY()         // Not required if not using SED
    );
	

	wire clk_hs;
	pll __ (.CLKI (osc_clk), .CLKOP (clk_hs));

    pwr_cntrllr pcm1 (
        .USERSTDBY(stdby_in), 
        .CLRFLAG(stby_flag), 
        .CFGSTDBY(1'b0),  
        .STDBY(stdby1), 
        .SFLAG(stby_flag)
    );
	
	/*-------------------------------------LED Blinking----------------------------*/

    // (Toggle LEDs every 1/2 second)
    always @(posedge osc_clk or posedge stdby_in)
        if (stdby_in)
            cnt <= 0;
        else	
            cnt <= cnt + 1;

	/*------------------------------------- Histogram Calculator----------------------------*/
	wire reset = 1;
	wire reset_n_HFCLKOUT;

	wire uart;
	//	Reset Bridge for clk_osc
	reset_bridge rst_brg_osc(
	  .clk_i			(clk_hs),// Destination clock
	  .ext_resetn_i		( reset ),// Asynchronous reset signal
	  .sync_resetn_out	(reset_n_HFCLKOUT)// Synchronized reset signal
	);

	wire [9:0] test_pixel;
	wire test_lv, test_fv;
	grayscale_color_bar gs_i(
		.clk        (clk_hs),            // 133.00 MHz clock
		.reset_n    (reset_n_HFCLKOUT),        // Active low reset
		.pixel_out  (test_pixel),// 10-bit grayscale pixel
		.line_valid (test_lv),     // Line valid signal
		.frame_valid(test_fv)     // Frame valid signal
	);

	wire spi_clk;

	wire [9:0] test_pixel_x;
	wire test_lv_x, test_fv_x;

	signal_buffer lv_buf(clk_hs, ~reset_n_HFCLKOUT, test_lv, test_lv_x);
	signal_buffer fv_buf(clk_hs, ~reset_n_HFCLKOUT, test_fv, test_fv_x);
	signal_buffer_10 px_buf(clk_hs, ~reset_n_HFCLKOUT, test_pixel, test_pixel_x);


	histogram_module histogram_module_i(
		.clk 		(clk_hs),
		.reset		(~reset_n_HFCLKOUT),
		.pixel_data (test_pixel_x),//test_pixel),
		.frame_valid (test_fv_x),//test_fv),
		.line_valid (test_lv_x),//test_lv),
		.spi_clk_i 	(clk_hs),
		.spi_mosi_o (uart),
		.spi_clk_o (spi_clk)
//		.debug		(debug)
	); 



	/*----------------------------------------------------------------*/
	assign debug[0] = stdby_in;
	assign debug[1] = test_lv;
	assign debug[2] = test_fv;
	assign debug[3] = clk_hs;
	assign debug[4] = uart;
	assign debug[5] = spi_clk;
	assign debug[6] = 0;
	assign debug[7] = 0;
	
	
    // Assign outputs
    assign led0 = stdby_in ? 1'b1 :  cnt[22];
    assign led1 = stdby_in ? 1'b1 : ~cnt[22];
    assign led2 = stdby_in ? 1'b1 :  cnt[22];
    assign led3 = stdby_in ? 1'b1 : ~cnt[22];
    assign led4 = stdby_in ? 1'b1 :  cnt[22];
    assign led5 = stdby_in ? 1'b1 : ~cnt[22];
    assign led6 = stdby_in ? 1'b1 :  cnt[22];
    assign led7 = stdby_in ? 1'b1 : ~cnt[22];

	assign histo_valid = histo_valid_reg;  // Histogram valid signal
    assign histo_clock = histo_clock_reg;  // Histogram clock signal
endmodule
