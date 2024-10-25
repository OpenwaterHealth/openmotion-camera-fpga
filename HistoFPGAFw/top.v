module topmod
(
	//I2C Interface
	inout			SDA,
	input			SCL,

	input          FSIN,
	input			GPIO0,
	output			GPIO1,
	

	// Camera MIPI input
	inout 			CK_P,
	inout 			CK_N,
	inout 			D0_P,
	inout 			D0_N,
	inout 			D1_P,
	inout 			D1_N,

    // Diff Interface
    inout          DIFF_P,
    inout          DIFF_N
);

/*------------------Clock Stuff--------------------*/
wire clk_osc, clk_pixel, pll_lock, clk_mipi;

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


/*------------------Clock Stuff--------------------*/




assign GPIO1 = clk_osc;

endmodule