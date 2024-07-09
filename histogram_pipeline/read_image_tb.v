`timescale 1ns / 1ps
`include "histogram_pipeline/histogram.v"

module tb;

    // Parameters
    parameter WIDTH = 1920;
    parameter HEIGHT = 1280;
    parameter TOTAL_PIXELS = WIDTH * HEIGHT;

    // Clock and reset
    reg clk;
    reg reset;
    reg write;
    reg [9:0] addr;

    // Pixel data
    reg [9:0] pixel_data [0:TOTAL_PIXELS-1];

    // Histogram output
    reg [31:0] hist_i;
    wire [31:0] hist_o;

    // Histogram module instantiation
    histogram hist_module (
        .clk(clk),
        .reset(reset),
        .write_i(write),
        .pixel(addr),
        .data_i(hist_i),
        .data_o(hist_o) // Remove index range
    );

    integer i;
    integer pixel_index;

    // Dump file declaration
    initial begin
        $dumpfile("out/read_image_tb.vcd");
        $dumpvars(0, tb); // Dump all signals
    end

    
    initial begin
        // Initialize clock and reset
        clk = 0;
        reset = 1;
        write = 0;
        hist_i = 0;
        #2000 reset = 0;
    
        // Read pixel data from file
        $readmemh("histogram/test_1920x1280.txt", pixel_data);
    
        // Process each pixel
        for (pixel_index = 0; pixel_index < TOTAL_PIXELS; pixel_index = pixel_index + 1) begin
            addr = pixel_data[pixel_index];
            write = 0;
            #10; // Delay for one time unit
            hist_i = hist_o + 1;
            write = 1;
            #10; // Delay for one time unit    
        end
        
        write = 0;
        // Delay for write operation to complete
        #100;

        // Read histogram bins and display
        $display("<< Histogram Start >>");
        for (i = 0; i < 1024; i = i + 1) begin
            write = 0;
            addr = i;
            #10; // Wait for one clock cycle
            $display("%d:%d", i, hist_o);
        end
        $display("<< Histogram End >>");

        // Finish simulation
        $finish;
    end
         
    // Clock generation
    always #5 clk = ~clk;

endmodule
