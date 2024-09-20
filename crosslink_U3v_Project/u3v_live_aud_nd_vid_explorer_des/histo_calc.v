`timescale 1ns / 1ps

module histogram2 (
    input wire rst,             // reset - zeros the histogram
    input wire clk,             // clock
    input wire fast_clk,        // double speed clock for histogram read/write cycle
    input wire rw,              // read/write, when reading outputs histo data/bin num until done
    input wire [9:0] pixel,    // 10 bit data for each pixel
    input wire pixel_valid,     // only on when the pixel is valid
    input wire image_done,      // flip this input high when image is finished
    output reg histo_done,      // flips high when histogram calculation is done
    input wire [9:0] bin,       // bin number to read out
    output wire [23:0] data      // data output of the bin being read
    );

    // Parameters
    parameter NUM_BINS = 1024;
    parameter READ = 0, WRITE = 1;

    // Clock and reset
    wire mem_reset = rst;

    // Histogram output
    reg [23:0] mem_in;
    wire [23:0] mem_out;
    wire [9:0] mem_addr = rw ? pixel : bin;
    
    // RAM module instance
    ram_dq_s ram_inst (
        .Clock(fast_clk),
        .ClockEn(~mem_reset), // Enable clock only when not in reset
        .Reset(mem_reset),
        .WE(1'b1), // Always write-enable
        .Address(mem_addr),
        .Data(mem_in), // Data input 
        .Q(mem_out) // Output data
    );

    reg [9:0] prev_pixel;
    
    wire rpt = (prev_pixel == pixel);
    
    always @(posedge clk) begin 
        prev_pixel <= pixel;
    end
    wire [23:0] incremented_count = mem_out+1;

    assign data = rw ? 24'b0 : mem_out;

    always @(*) begin
        if(rw) begin           // if write mode, read and increment the counter
            if(pixel_valid) begin
                mem_in = incremented_count;
                //mem_addr <= pixel;
            end else begin
                mem_in = mem_out;
            end
        end else begin                  // if read mode... 
            mem_in = 0;
        end
    end
    
    
    always @(posedge fast_clk) begin
        if(image_done) begin
            histo_done <= 1;
        end else begin
            histo_done <= 0;
        end
    end
endmodule
