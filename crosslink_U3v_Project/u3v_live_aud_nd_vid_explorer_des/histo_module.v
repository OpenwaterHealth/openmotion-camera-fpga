
module histogram_module (
    input clk,
    input fast_clk,
    input reset,
    input [9:0] pixel_data,
    input frame_valid,
    input line_valid,
    input uart_clk,
    output uart,
	output [5:0] debug
);

    // Histogram generator
    wire [23:0] data; 
    reg [9:0] bin;

    // Control
    wire image_done; 
    wire histo_done;
    wire serializer_done;

    wire pixel_valid = frame_valid && line_valid;


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

    histogram2 histo_i (
        .clk(clk),          // reset - zeros the histogram
        .fast_clk(fast_clk),
        .rst(reset),          // clock
        
        .pixel (pixel_data),  // 10 bit data for each pixel
        .pixel_valid (pixel_valid),
        .data(data),       //    when writing, on every rising edge of CLK adds one to the histogram
        .bin(bin),
        
        .rw(frame_valid),           // read/write, when reading outputs histo data/bin num until done
        .image_done(~frame_valid),
        .histo_done(histo_done)
    );


	reg [23:0] data_persistent;
    Serializer seralizer_i (
        .fast_clk_in(uart_clk),
        .reset((state != SERIALIZE)),
        .data_in(data_persistent),
        .serial_out(uart),
        .slow_clk_out(),
        .done(serializer_done)
    );

	wire data_valid = (data != 0);
	always @(posedge data_valid, posedge serializer_done) begin
		if(data_valid) data_persistent <= data;
		else data_persistent <= 24'b0;
	end
	
	

	assign debug[0] = uart;
	assign debug[1] = fast_clk;
	assign debug[2] = reset;
	assign debug[3] = frame_valid;
	assign debug[4] = state[0];
	assign debug[5] = state[1];

	
endmodule