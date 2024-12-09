
`timescale 1ns / 1ps
`include "i2c_pipeline/timer.v"

module timer_tb;

reg Clock;
reg Enable;
reg [31:0] InputFrequency = 32'h0000_00FF;
reg [31:0] TimerTime = 32'h0000_0001;
wire Done;

Timer timer_i (
    .clk    (Clock),       // Clock input
    .enable (Enable),    // Enable input
    .clock_frequency (InputFrequency),  // Clock frequency input (in Hz)
    .time_in_seconds (TimerTime),  // Time in seconds
    .timer_done (Done)  // Output indicating timer expiration
);

initial begin
    Clock = 0;
    Enable = 0;
    #10 Enable =1;
    #100000
    $display("Memory verification completed.");
    $finish;
end
  initial begin
    $dumpfile("out/timer_tb.vcd");
    $dumpvars(0, timer_tb);  // Dump all signals
  end
always #5 Clock = ~Clock;

endmodule