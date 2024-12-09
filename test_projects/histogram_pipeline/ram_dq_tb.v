`timescale 1ns / 1ps
`include "histogram_pipeline/ram_dq.v"
module ram_dq_tb;

// Parameters
parameter MEM_DEPTH = 10; // 1024;
parameter DATA_WIDTH = 32;

// Clock and reset
reg Clock;
reg ClockEn;
reg Reset;
reg WE;
reg [9:0] Address;
reg [31:0] Data;
wire [31:0] Q;

// RAM module instantiation
ram_dq ram_inst (
    .Clock(Clock),
    .ClockEn(ClockEn),
    .Reset(Reset),
    .WE(WE),
    .Address(Address),
    .Data(Data),
    .Q(Q)
);

// Dump file declaration
initial begin
    $dumpfile("out/ram_dq_tb.vcd");
    $dumpvars(0, ram_dq_tb); // Dump all signals
end

// Test data
integer i;
reg [31:0] test_data[MEM_DEPTH];
reg [31:0] read_data[MEM_DEPTH];

// Initialize clock and reset
initial begin
    Clock = 0;
    ClockEn = 1;
    Reset = 1;
    WE = 0;
    Address = 0;
    Data = 0;
    // Initialize test data
    for (i = 0; i < MEM_DEPTH; i = i + 1) begin
        test_data[i] = $random;
    end
    #10 Reset = 0;
end

// Write test data to memory
initial begin
    #20; // Wait for some time after reset
    for (i = 0; i < MEM_DEPTH; i = i + 1) begin
        Address = i;
        #5; // Wait for one clock cycle
        Data = test_data[i];
        WE = 1;
        #5; // Wait for one clock cycle
    end
    
    #300; // Wait for some time after writing
    for (i = 0; i < MEM_DEPTH; i = i + 1) begin
        Address = i;
        #5; // Wait for one clock cycle
        WE = 0;
        #5; // Wait for one clock cycle
        read_data[i] = Q;
        #5; // Wait for one clock cycle
    end

    // Compare written and read data
    for (i = 0; i < MEM_DEPTH; i = i + 1) begin
        if (read_data[i] !== test_data[i]) begin
            $display("Mismatch at address %d. Expected: %h, Read: %h", i, test_data[i], read_data[i]);
        end
    end
    $display("Memory verification completed.");
    $finish;
end

// Clock generation
always #5 Clock = ~Clock;

endmodule

