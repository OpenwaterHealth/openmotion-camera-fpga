// Simulation-only stand-in for the IPexpress ram_dp_s (1024 x 24 pseudo dual
// port, 3 x DP8KE, REGMODE NOREG, WRITEMODE NORMAL, ASYNC output reset).
// Same port list and cycle timing; about 10x faster than the Lattice DP8KE
// model. Like the vendor model, a read of the address being written on the
// same clock returns X, so read/write collisions stay visible.
// Use with  FAST=1 ./sim/run.sh ; sign off with the vendor model (default).
`timescale 1 ns / 1 ps
`default_nettype none
module ram_dp_s (
    input  wire [9:0]  WrAddress,
    input  wire [9:0]  RdAddress,
    input  wire [23:0] Data,
    input  wire        WE,
    input  wire        RdClock,
    input  wire        RdClockEn,
    input  wire        Reset,
    input  wire        WrClock,
    input  wire        WrClockEn,
    output reg  [23:0] Q
  );
  reg [23:0] mem [0:1023];
  integer i;
  initial for (i = 0; i < 1024; i = i + 1) mem[i] = 24'd0;   // EBR INIT_DATA = 0

  always @(posedge WrClock)
    if (WrClockEn && WE) mem[WrAddress] <= Data;

  always @(posedge RdClock or posedge Reset)
    if (Reset)
      Q <= 24'd0;
    else if (RdClockEn)
      Q <= (WrClockEn && WE && (WrAddress == RdAddress)) ? 24'bx : mem[RdAddress];
endmodule
`default_nettype wire
