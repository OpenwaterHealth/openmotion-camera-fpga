`timescale 1ns / 1ps

module camera_pipeline_tb;

    // Parameters
    parameter HISTO_BUCKET_SIZE = 24;
    parameter NUM_BINS = 1024;
    parameter CLK_PERIOD = 8;              // Clock period in ns,          8ns = 125Mhz
                                            // fast clk is at double the above, so 250Mhz
    parameter FSIN_CLK_PERIOD = 25000000;   // 25,000,000ns =               25ms = 40Hz
    parameter UART_PERIOD = 80;            //                              80ns = 12.5MHz
    parameter SLOW_CLK_PERIOD = HISTO_BUCKET_SIZE*UART_PERIOD; // 
    
    // Clocks
    reg clk = 0;                // Clock signal
    reg fast_clk = 1;
    reg fsin = 0;
    reg uart_clk =0;

    // Image generator
    wire line_valid;            // Line synchronization signal
    wire frame_valid;           // Frame synchronization signal
    wire [9:0] pixel_data;      // 16-bit bus for pixel data
    reg cam_en = 0;

    // Instantiate image_processor module
    camera_data_gen camera_gen (
        .en(cam_en),
        .clk(clk),
        .line_valid(line_valid),
        .frame_valid(frame_valid),
        .pixel_data(pixel_data),
        .done(image_done)
    );

    wire uart;
    histogram_module histogram_module_i(
        .clk (clk),
        .fast_clk (fast_clk),
        .reset(cam_en),
        .pixel_data (pixel_data),
        .frame_valid (frame_valid),
        .line_valid (line_valid),
        .uart_clk (uart_clk),
        .uart (uart),
		.debug ()
    );

    // Initial stimulus
    initial begin
        // Wait for a few clock cycles to stabilize
        clk = 0;
        fast_clk = 1;
        fsin =0;
        cam_en = 0;

        // Test for a few frames
        repeat (2) begin // Adjust repeat count based on testing needs
            @(posedge fsin);
            cam_en = 1;
            #1; cam_en = 0;
        end

        // End simulation after testing
        $finish;
    end

   PUR PUR_INST(.PUR(1'b1));
   GSR GSR_INST(.GSR(1'b1));

/*    initial begin
        $dumpfile("out/histogram_module_tb.vcd");
        $dumpvars(0, camera_pipeline_tb);  // Dump all signals
    end
*/

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;                // 50Mhz
    always #((CLK_PERIOD)/4) fast_clk = ~fast_clk;      // 100Mhz
    always #((FSIN_CLK_PERIOD/2)) fsin = ~fsin;         // 40Hz
    always #((UART_PERIOD)/2) uart_clk = ~uart_clk;     

endmodule
