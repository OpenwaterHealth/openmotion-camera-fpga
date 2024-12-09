`timescale 1ns / 1ns

module dpram (
    input wire clk1,
    input wire clk2,
    input wire we1,
    input wire we2,
    input wire [9:0] addr1,
    input wire [9:0] addr2,
    input wire [31:0] data_in1,
    input wire [31:0] data_in2,
    output reg [31:0] data_out1,
    output reg [31:0] data_out2
);

reg [31:0] mem [0:1023]; // 2^10 = 1024 memory locations

always @(posedge clk1) begin
    if (we1)
        mem[addr1] <= data_in1;
    data_out1 <= mem[addr1];
end

always @(posedge clk2) begin
    if (we2)
        mem[addr2] <= data_in2;
    data_out2 <= mem[addr2];
end

endmodule