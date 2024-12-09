
`timescale 1ns / 1ps
`include "i2c_pipeline/timer.v"
`include "i2c_pipeline/state_machine.v"

module tb;

  reg Clock = 0;
  reg Enable = 0;
  reg In = 0;
  wire Reset = 0;
  wire Out;

  simple_fsm simple_fsm_i (
      .clk  (Clock),
      .start(Enable),
      //.in (In),
      .reset(Reset),
      .out  (Out)
  );
  // Dump file declaration
  initial begin
    $dumpfile("out/state_machine_tb.vcd");
    $dumpvars(0, tb);  // Dump all signals
  end
  initial begin
    Enable = 0;
    #100 Enable = 1;
    #100 In = 1;
    #100 In = 0;
    $display("Memory verification completed.");
    #10000;
    $finish;

  end

  always #5 Clock = ~Clock;

endmodule
