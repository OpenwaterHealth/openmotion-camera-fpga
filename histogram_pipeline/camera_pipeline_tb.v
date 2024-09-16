`timescale 1ns / 1ps
`include "histogram_pipeline/camera_data_gen.v"
`include "histogram_pipeline/histogram2.v"
`include "histogram_pipeline/serializer.v"

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
    wire pixel_valid = frame_valid && line_valid;
    reg cam_en = 0;
    
    // Histogram generator
    wire [23:0] data; 
    reg [9:0] bin;
    
    // Serializer
    wire uart;

    // Control
    wire image_done; 
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

    // Instantiate image_processor module
    camera_data_gen camera_gen (
        .en(cam_en),
        .clk(clk),
        .line_valid(line_valid),
        .frame_valid(frame_valid),
        .pixel_data(pixel_data),
        .done(image_done)
    );

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

    Serializer seralizer_i (
        .fast_clk_in(uart_clk),
        .reset((state != SERIALIZE)),
        .data_in(data),
        .serial_out(uart),
        .slow_clk_out(),
        .done(serializer_done)
    );
    
    // Print out data for running agaist test
    always @(posedge serializer_done ) begin
        $display(      "%d:%d", bin, data);
    end

    // Initial stimulus
    initial begin
        // Wait for a few clock cycles to stabilize
        clk <= 0;
        fast_clk <= 1;
        fsin <=0;
        cam_en <= 0;

        // Test for a few frames
        repeat (2) begin // Adjust repeat count based on testing needs
            @(posedge fsin);
            cam_en <= 1;
            #1; cam_en <= 0;
        end

        // End simulation after testing
        $finish;
    end

    initial begin
        $dumpfile("out/camera_pipeline_tb.vcd");
        $dumpvars(0, camera_pipeline_tb);  // Dump all signals
    end

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;                // 50Mhz
    always #((CLK_PERIOD)/4) fast_clk = ~fast_clk;      // 100Mhz
    always #((FSIN_CLK_PERIOD/2)) fsin = ~fsin;         // 40Hz
    always #((UART_PERIOD)/2) uart_clk = ~uart_clk;     

endmodule
