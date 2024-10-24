module top (
    input stdby_in,       // Standby input
    output stdby1,        // Standby output
    output osc_clk,       // Oscillator clock output
    output led0, led1, led2, led3, led4, led5, led6, led7, // LED outputs
    output frame_valid,   // Frame valid signal for scope
    output line_valid,        // Line valid signal for scope
    output [9:0] histo_data,  // 10-bit histogram data output
	output pixel_clk,
    output histo_valid,       // Histogram data valid signal
    output histo_clock        // Histogram clock signal
);

    wire stby_flag;
    reg [23:0] cnt;
    reg [9:0] rd_addr;         // Read address for histogram
    reg [10:0] histo_count;    // Counter for 1024 histogram readout cycles
    reg rd_en;                 // Histogram read enable
    reg histo_clear;           // Histogram clear signal
    reg histo_valid_reg;       // Register for histogram valid signal
    reg histo_clock_reg;       // Register for histogram clock
    reg histo_reading;         // Indicates if histogram is being read

    // Internal Oscillator
    defparam OSCH_inst.NOM_FREQ = "19.00";	// 133 MHz clock

    OSCH OSCH_inst(
        .STDBY(stdby1), 	// 0=Enabled, 1=Disabled also Disabled with Bandgap=OFF
        .OSC(osc_clk),      // Oscillator clock output
        .SEDSTDBY()         // Not required if not using SED
    );

    pwr_cntrllr pcm1 (
        .USERSTDBY(stdby_in), 
        .CLRFLAG(stby_flag), 
        .CFGSTDBY(1'b0),  
        .STDBY(stdby1), 
        .SFLAG(stby_flag)
    );

    // LED Blinking test (Toggle LEDs every 1/2 second)
    always @(posedge osc_clk or posedge stdby_in)
        if (stdby_in)
            cnt <= 0;
        else	
            cnt <= cnt + 1;

    // Grayscale Color Bar Generator
    wire [9:0] pixel_out;  // 10-bit pixel output
	
	camera_emulator cam_inst (
		.clk_19mhz(osc_clk),
		.reset_n(~stdby_in), 
		.pixel_data(histo_data),
		.hsync(line_valid),       // Horizontal sync
		.vsync(frame_valid),       // Vertical sync
		.pclk(pixel_clk)         // Pixel clock
	);
/*
    grayscale_color_bar grayscale_gen (
        .clk(osc_clk),         // 133 MHz clock input
        .reset_n(~stdby_in),   // Active low reset input
        .pixel_out(histo_data), // Grayscale pixel output
        .line_valid(line_valid),  // Line valid output signal
        .frame_valid(frame_valid) // Frame valid output signal
    );
*/

    // Grayscale Histogram Generator
    wire [15:0] rd_data;   // Data from histogram (number of occurrences)

    grayscale_histogram histogram_gen (
        .clk(osc_clk),               // Clock input
        .reset_n(~stdby_in),         // Active low reset
        .frame_valid(frame_valid),   // Frame valid signal
        .line_valid(line_valid),     // Line valid signal
        .pixel_out(pixel_out),       // 10-bit pixel output from grayscale generator
        .rd_en(rd_en),               // Read enable during blanking period
        .rd_addr(rd_addr),           // Read address for histogram bins
        .rd_data(rd_data),           // Read data from histogram bins
        .clear(histo_clear)          // Clear histogram after readout
    );


    // Histogram readout logic
    always @(posedge osc_clk or posedge stdby_in) begin
        if (stdby_in) begin
            rd_addr <= 10'b0;
            histo_count <= 11'b0;
            histo_valid_reg <= 1'b0;
            histo_clock_reg <= 1'b0;
            histo_reading <= 1'b0;
            rd_en <= 1'b0;
            histo_clear <= 1'b0;
        end else begin
            if (!frame_valid && !histo_reading) begin
                // Start reading when frame is invalid (blanking period)
                histo_reading <= 1'b1;
                histo_valid_reg <= 1'b1;
                histo_count <= 11'b0;
                rd_addr <= 10'b0;
                rd_en <= 1'b1;
                histo_clear <= 1'b0;  // Ensure clear is low during readout
            end else if (histo_reading && histo_count < 11'd1024) begin
                // Continue reading the histogram
                histo_count <= histo_count + 1;
                rd_addr <= rd_addr + 1;
                histo_clock_reg <= ~histo_clock_reg;  // Toggle histo_clock
            end else if (histo_count >= 11'd1024) begin
                // End reading after 1024 bins
                histo_reading <= 1'b0;
                histo_valid_reg <= 1'b0;
                rd_en <= 1'b0;
                histo_clear <= 1'b1;  // Set clear after reading all bins
            end
        end
    end

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
