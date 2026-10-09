// ram_dp_s_beh.v — behavioral stand-in for the SCUBA-generated Lattice
// netlist HistoFPGAFw/ram_dp/ram_dp_s/ram_dp_s.v (DP8KE, REGMODE=NOREG on
// both ports -> synchronous read: Q updates one RdClock edge after
// RdAddress/RdClockEn are presented). Port-compatible; simulation only.
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
  initial for (i = 0; i < 1024; i = i + 1) mem[i] = 24'd0;  // INIT_ALL_0s
  always @(posedge WrClock) if (WrClockEn && WE) mem[WrAddress] <= Data;
  always @(posedge RdClock) if (RdClockEn) Q <= mem[RdAddress];
endmodule
