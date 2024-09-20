module Serializer(
    input wire fast_clk_in,       // Clock input
    input wire reset,     // Reset input
    input wire [23:0] data_in, // 32-bit input data to be serialized
    output reg serial_out, // Serial output
    output wire slow_clk_out,
    output reg done
);
    parameter BITS_PER_PACKET = 24;
    
    reg [4:0] count;      // Counter to keep track of bit position
    assign slow_clk_out = count <12;
    //assign done = count == 24;
    always @(posedge fast_clk_in or posedge reset) begin
        if (reset) begin
            count <= 24;
            serial_out <= 1'b0; // Start with a low output
            done <= 1;
        end else begin
            if (count < 24) begin
                serial_out <= data_in[23 - count]; // Output the current bit of data_in
                count <= count + 1;
                done <= 0;
            end else begin
                count <= 0; // Reset count after serializing all bits
                done <= 1;
            end
        end
    end

endmodule
