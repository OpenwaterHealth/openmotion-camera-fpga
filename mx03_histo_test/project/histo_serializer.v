module Serializer(
    input wire fast_clk_in,       // Clock input
    input wire reset,     // Reset input
    input wire [31:0] data_in, // 32-bit input data to be serialized
    output wire serial_out, // Serial output
    output wire slow_clk_out,
    output wire done,
	output wire [9:0] debug
);

	// Break down data into its four segments	
	reg [1:0] select = 2'b0;
	reg [7:0] data_out;
	
	always @(*) begin
		case (select)
			2'b00: data_out = data_in[7:0];    // Select the least significant 8 bits
			2'b01: data_out = data_in[15:8];   // Select the next 8 bits
			2'b10: data_out = data_in[23:16];  // Select the third 8 bits
			2'b11: data_out = data_in[31:24];  // Select the most significant 8 bits
			default: data_out = 8'b0;          // Default case (optional, for completeness)
		endcase
	end
	assign debug[7:0] = data_out;
    assign debug[9:8] = select;
	
	// signal when done with the 4 byte packet, 
	wire m_tready;
	reg prev_m_tready;
	reg m_tvalid;

	always @(posedge fast_clk_in) begin
		if(reset)
			prev_m_tready <= 0;
		else 
			prev_m_tready <= m_tready;
	end
	
	always @(posedge fast_clk_in) begin
		if (reset) begin
			select <= 2'b11;
			m_tvalid <= 1'b0;
		end else begin
			if ( m_tready && !prev_m_tready) begin
				m_tvalid <= 1'b1;
				select <= select + 2'b01; // Increment on the positive edge of serializer_done
			end else begin
				m_tvalid <= 1'b0; // ensure that tvalid goes down right after it pops up
			end
		end
	end
	
	assign done = (select == 2'b11) & m_tready & ~prev_m_tready;	// move to the next bin when the last section goes out and m_tready pops up
	
	
    // SPI Master Instantiation
    SPI_Master #(
        .SPI_MODE(0),                    // SPI Mode 0 (CPOL = 0, CPHA = 0)
        .CLKS_PER_HALF_BIT(4)            // Clock divider: 2 (20.46 MHz / 2 = 10.23 MHz SCLK)
    ) spi_inst (
        .i_Rst_L(~reset),             // SPI Master active low reset
        .i_Clk(fast_clk_in),                 // System Clock
        .i_TX_Byte(data_out),           // Byte to be transmitted
        .i_TX_DV(m_tvalid),           // Data valid signal
        .o_TX_Ready(m_tready),       // Indicates ready for the next byte
        .o_RX_DV(),            // Data valid signal for received byte
        .o_RX_Byte(),       // Received byte
        .o_SPI_Clk(slow_clk_out),      // SPI Clock Output
        .i_SPI_MISO(),    // SPI MISO Input
        .o_SPI_MOSI(serial_out)     // SPI MOSI Output
    );
	

endmodule
