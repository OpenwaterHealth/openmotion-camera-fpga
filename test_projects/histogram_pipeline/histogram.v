`timescale 1ns / 1ps
`include "histogram_pipeline/ram_dq.v"
module histogram (
    input wire clk,
    input wire reset,
    input wire write_i,
    input wire [9:0] pixel,
    input wire [31:0] data_i,
    output wire [31:0] data_o
);
    // RAM module instance
    ram_dq ram_inst (
        .Clock(clk),
        .ClockEn(~reset), // Enable clock only when not in reset
        .Reset(reset),
        .WE(write_i), // Always write-enable
        .Address(pixel),
        .Data(data_i), // Data input 
        .Q(data_o) // Output data
    );

endmodule