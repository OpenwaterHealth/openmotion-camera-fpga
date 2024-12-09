`timescale 1ns / 1ps
`include "histogram_pipeline/histogram2.v"

module histogram2_tb;

    // Parameters
    parameter WIDTH = 1920;
    parameter HEIGHT = 1280;
    parameter TOTAL_PIXELS = WIDTH * HEIGHT;

    // Clock and reset
    reg clk;
    reg fast_clk;
    reg reset;
    reg write;
    reg [9:0] pixel_data [0:TOTAL_PIXELS-1];
    reg [9:0] pixel_datum;
    reg rw; 
    wire [23:0] data;

    reg [9:0] addr;
    wire histo_read_done;
    reg [9:0] bin;
    // Histogram module instantiation
   
    histogram2 hist_module (
        .clk(clk),          // reset - zeros the histogram
        .fast_clk(fast_clk),
        .rst(reset),          // clock
        .pixel (pixel_datum),  // 10 bit data for each pixel
        .pixel_valid (1'b1),
        .rw(rw),           // read/write, when reading outputs histo data/bin num until done
        .data(data),       //    when writing, on every rising edge of CLK adds one to the histogram
        .bin(bin),
        .image_done(1'b1)
    );
    
    integer i;
    integer pixel_index;
    
    initial begin
        // Initialize clock and reset
        clk = 0;
        fast_clk = 1;
        reset = 1;
        #2000 reset = 0;
        pixel_index = 0;
        // Read pixel data from file
        $readmemh("histogram_pipeline/test_res/test_1920x1280.txt", pixel_data);
        
        rw = 1; // write the pixel data
        // Process each pixel
        /*for (pixel_index = 0; pixel_index < TOTAL_PIXELS; pixel_index = pixel_index + 1) begin
            pixel_datum = pixel_data[pixel_index];
            #10; // Delay for one time unit
        end*/
        repeat (TOTAL_PIXELS) begin // Adjust repeat count based on testing needs
            @(posedge clk);
            pixel_datum = pixel_data[pixel_index];
            pixel_index = pixel_index + 1;
        end

        rw = 0;
        bin = 0;
        $display("<< Histogram Start >>");
        for (i = 0; i < 1024; i = i + 1) begin
            bin = i;
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            $display("%d:%d", i, data);
        end
        $display("<< Histogram End >>");

        //@(posedge histo_read_done);
        // Finish simulation
        $finish;
    end
         
    // Dump file declaration
    initial begin
        $dumpfile("out/histogram2_tb.vcd");
        $dumpvars(0, histogram2_tb); // Dump all signals
    end

    // Clock generation
    always #10 clk = ~clk;
    always #5 fast_clk = ~fast_clk;

endmodule
