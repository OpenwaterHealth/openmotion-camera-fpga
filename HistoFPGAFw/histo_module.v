
module histogram_module (
    input clk,
    input reset,
    input [9:0] pixel_data,
    input frame_valid,
    input line_valid,
    input spi_clk_i,
    output spi_mosi_o,
	output spi_clk_o,
	output [5:0] debug,
	output [9:0] debug2
);

    // Histogram generator
    wire [23:0] data; 
    reg [9:0] bin;

    // Control
    wire image_done; 
    wire histo_done;
    wire serializer_done;
	reg prev_serializer_done;
	reg serializer_total_done =0;
	reg flag = 0;
    wire pixel_valid = frame_valid && line_valid;

	parameter IDLE = 2'b00, HISTO = 2'b01, SERIALIZE = 2'b11;
	reg [1:0] state = IDLE;

	always @(posedge clk) begin
		if (reset) begin
			state <= IDLE;
		end else begin
			case (state)
				IDLE: begin
					if (frame_valid) 
						state <= HISTO;
				end
				HISTO: begin
					if (!frame_valid) 
						state <= SERIALIZE;
				end
				SERIALIZE: begin
					if (serializer_done && bin == 10'h0 && flag == 1)
						state <= IDLE;
				end
			endcase
		end
	end
	
	always @(posedge clk) begin
		if (reset | state !=SERIALIZE) begin
			bin <= 10'h3ff;
			prev_serializer_done <= 1'b0;
			flag <= 0; // set the flag low to show that a serialization has ended
		end else begin
			prev_serializer_done <= serializer_done; // Store the previous state of serializer_done
			if (state == SERIALIZE && !prev_serializer_done && serializer_done) begin
				bin <= bin + 10'b0000000001; // Increment on the positive edge of serializer_done
			end
			
			if(bin == 1) flag <= 1; // set the flag high to show that a serialization has started
		end
	end			

    histogram3 histo_i (
        .clk(clk),          // reset - zeros the histogram
        .rst(reset),          // clock
        .rw(frame_valid),           // read/write, when reading outputs histo data/bin num until done
        
        .pixel (pixel_data),  // 10 bit data for each pixel
        .pixel_valid (pixel_valid),
        
		.data(data),       //    when writing, on every rising edge of CLK adds one to the histogram
        .bin(bin),
        
        .image_done(~frame_valid),
        .histo_done(histo_done),
		.debug_line (debug_line)
    );

	
	Serializer seralizer_i (
        .fast_clk_in(spi_clk_i),
        .reset(reset | (state != SERIALIZE)),
        .data_in({8'b0,data}),
        .serial_out(spi_mosi_o),
        .slow_clk_out(spi_clk_o),
        .done(serializer_done),
		.debug ()
    );
	assign debug2 = frame_valid ? pixel_data : bin;
	//assign debug2 = data[9:0];
	
	
	assign debug[0] = spi_clk_o;
	assign debug[1] = spi_mosi_o;
	assign debug[2] = line_valid;
	assign debug[3] = frame_valid;
	assign debug[4] = pixel_data[0];
	assign debug[5] = debug_line;
	
	
endmodule