// Simulation-only stubs for the Lattice GSR/PUR cells the testbench
// instantiates, used with the fast RAM model (no Diamond library needed).
`timescale 1 ns / 1 ps
module GSR (input GSR); wire GSRNET = GSR; endmodule
module PUR (input PUR); wire PURNET = PUR; endmodule
