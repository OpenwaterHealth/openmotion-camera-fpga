`timescale 1ns / 1ps
`include "histogram_pipeline/camera_data_gen.v"

module camera_data_gen_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns

    localparam WIDTH = 640; // Example width of the image
    localparam HEIGHT = 480; // Example height of the image
    // Signals
    reg clk = 0; // Clock signal
    wire line_sync; // Line synchronization signal
    wire frame_sync; // Frame synchronization signal
    wire [9:0] pixel_data; // 16-bit bus for pixel data
    reg en =0; 

    // Instantiate image_processor module
    camera_data_gen dut (
        .clk(clk),
        .en(en),
        .line_valid(line_sync),
        .frame_valid(frame_sync),
        .pixel_data(pixel_data)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Initial stimulus
    initial begin
        // Wait for a few clock cycles to stabilize
        #100;
        // Test for a few frames
        repeat (2) begin // Adjust repeat count based on testing needs
            // Wait for frame sync assertion
            
            en =1;
            #1 en=0;
            @(negedge frame_sync);
/*
            // Test for a few lines within the frame
            repeat (5) begin // Adjust repeat count based on testing needs
                // Wait for line sync assertion
                @(posedge line_sync);

                // Check pixel data output
                // $display("Frame %0d, Line %0d, Pixel Data: %h", $time / (WIDTH * HEIGHT), $time % HEIGHT, pixel_data);
                $display("Frame %0d, Line %0d, Pixel Data: %h", $time / (WIDTH * HEIGHT), $time % HEIGHT, pixel_data);
            end*/
        end
        //@(negedge frame_sync);

        // End simulation after testing
        $finish;
    end
    initial begin
        $dumpfile("out/camera_data_gen_tb.vcd");
        $dumpvars(0, camera_data_gen_tb);  // Dump all signals
    end
endmodule
