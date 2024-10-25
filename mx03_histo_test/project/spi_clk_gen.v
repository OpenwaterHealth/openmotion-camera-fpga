module spi_clock_divider (
    input wire clk_in,        // 249 MHz input clock
    input wire rst,           // Synchronous reset
    output reg clk_out        // 40 MHz (approx.) output clock
);

    // Parameters for division ratio
    parameter DIV_RATIO1 = 2;    // Division by 6

    reg [3:0] counter = 0;       // 4-bit counter (values up to 7)

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            // Reset logic
            counter <= 0;
            clk_out <= 0;
        end else begin
			if (counter == DIV_RATIO1 - 1) begin
				counter <= 0;
				clk_out <= ~clk_out;  // Toggle the output clock
			end else begin
				counter <= counter + 1;
			end
		end
    end
endmodule