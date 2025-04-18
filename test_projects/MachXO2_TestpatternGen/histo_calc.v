`timescale 1ns / 1ps

module histogram3 (
    input wire rst,             // reset - zeros the histogram
    input wire clk,             // clock
    input wire rw,              // read/write, when reading outputs histo data/bin num until done
    input wire [9:0] pixel,    // 10 bit data for each pixel
    input wire pixel_valid,     // only on when the pixel is valid
    input wire image_done,      // flip this input high when image is finished
    output reg histo_done,      // flips high when histogram calculation is done
    input wire [9:0] bin,       // bin number to read out
    output wire [23:0] data,      // data output of the bin being read
    output wire debug_line
	);
    
	reg prev_pixel_valid;
	reg prev_rpt;
	reg prev_rw;
	reg prev_prev_rw;
	reg prev_prev_prev_rw;
	reg prev_prev_prev_prev_rw;
	
	reg [9:0] prev_bin;
	reg [9:0] prev_pixel = 10'b0;
    reg [23:0] rpt_inc  = 24'b0;
	reg [23:0] data_out_persistent;
	reg prev_bin_incremented; 
	
	wire [23:0] ram_wr_data;
	wire [23:0] data_to_write;
    wire [23:0] data_out;
	wire [23:0] incremented_count;
	wire rpt;
    wire [9:0] ram_rd_addr;
    wire [9:0] ram_wr_addr;
	wire bin_incremented;
	
	always @(posedge clk) begin
		if(rst) begin
            if (~pixel_valid) prev_pixel <= 10'b0;
        
			prev_pixel_valid <= 0;
			prev_rpt <= 0;
			rpt_inc <= 0;
			histo_done <= 0;
			prev_bin <= 0;
			prev_bin_incremented <= 0;
		end else begin
            prev_pixel <= pixel;
			prev_pixel_valid <= pixel_valid;
			prev_rpt <= rpt;
			prev_bin_incremented <= bin_incremented;
			prev_bin <= bin;
			
			if(rpt & prev_rpt) 					// second through last repeat
				rpt_inc <= rpt_inc + 23'b1;
			else if(rpt) 							// just the first repeat
				rpt_inc <= incremented_count;

			// Histo done signal
		   if(image_done) begin
				histo_done <= 1;
			end else begin
				histo_done <= 0;
			end
			
			if(prev_bin_incremented)
				data_out_persistent <= data_out;
		end
		prev_rw <= rw;
		prev_prev_rw <= prev_rw;
		prev_prev_prev_rw <= prev_prev_rw;
		prev_prev_prev_prev_rw <= prev_prev_prev_rw;
	end
	
	dp_ram ram_dp_i (
        .Reset(rst), 
        
		.RdClock(clk), 
        .RdClockEn(~rst), 
        .RdAddress(ram_rd_addr), 
        .Q(data_out),
		
		.WrClock(clk), 
        .WrClockEn(~rst), 
        .WrAddress(ram_wr_addr), 
        .Data(ram_wr_data), 
        .WE(~prev_prev_prev_prev_rw | (~rpt & prev_pixel_valid)) // write when in "READ" mode, aka wipe everything out as you read it, and only write when the pixel before was valid and is not being repeated
	);
    
	assign debug_line = (ram_wr_data == 0);
	assign rpt = (prev_pixel == pixel) & pixel_valid & prev_pixel_valid; // repeat detector
    assign incremented_count = data_out + 23'b1;
	assign data_to_write = prev_rpt ? rpt_inc  + 24'b1: incremented_count;		
    assign ram_wr_data = prev_rw ? data_to_write : 24'b0;
	assign ram_rd_addr = rw ? pixel : bin;       // While in write mode, port 1 is always for reading
    assign ram_wr_addr = rw ? prev_pixel : prev_bin;  			 // while in write mode, port 2 is always for writing (if not repeat)
	assign data = rw ?  10'b0 : data_out_persistent;
	assign bin_incremented = (bin != prev_bin);
	
endmodule