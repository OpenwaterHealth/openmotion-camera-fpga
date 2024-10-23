module signal_buffer_10 (
    input wire clk,         // Clock signal
    input wire rst,         // Asynchronous reset signal
    input wire [9:0] in_signal,   // Input signal to be buffered
    output reg [9:0] out_signal   // Buffered output signal
);

    // Register to hold the buffered signal
    reg [9:0] buffer_reg;

    always @(posedge clk) begin
        if (rst) begin
            // Reset the buffer
            buffer_reg <= 1'b0;
            out_signal <= 1'b0;
        end else begin
            // Buffer the input signal by one clock cycle
            buffer_reg <= in_signal;
            out_signal <= buffer_reg;
        end
    end

endmodule
