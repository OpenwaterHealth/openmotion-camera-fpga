
`timescale 1ns / 1ps
`include "i2c_pipeline/top.v"

module top_tb;

  reg  Clock;
  reg Reset;
  reg i2c_done;
  wire sda;
  wire scl;
  wire q;
  wire clock_out;
  wire serial_out;
  output CMOS_IO_2;
  
  top top_i (
      .clk_osc       (Clock),       // Clock input
      .reset (Reset),
      .i2c_done (i2c_done),
      .sda       (sda),
      .scl       (scl),
      .q         (q),
      .clock_out (clock_out),
      .serial_out(serial_out),
      .CMOS_IO_2 (CMOS_IO_2)
  );

  initial begin
    Clock = 0;
    i2c_done = 0;
    #100 Reset = 1;
    #100 Reset = 0;
    #100 Reset = 1;

    #10000000 $display("Memory verification completed.");
    $finish;
  end
  initial begin
    $dumpfile("out/top_tb.vcd");
    $dumpvars(0, top_tb);  // Dump all signals
  end

  always #5 Clock = ~Clock;
  always #23 i2c_done = ~i2c_done;

endmodule
