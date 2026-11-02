`timescale 1ns / 1ps

// One lane x one bank: 1024-bin x 24-bit histogram in a dual-port EBR.
//
// Timing: clk is clk_pixel_hs = 132.8 MHz (7.53 ns). The EBR output is not
// registered (REGMODE NOREG, ~3.7 ns clock-to-out) and its inputs need ~0.9 ns
// setup, so the EBR is only ever read into a flip-flop and written from
// flip-flops. The add sits between two flip-flops.
//
// Count mode: a 4-stage read-modify-write pipeline. Pixel k is presented on
// `pixel` in cycle k:
//   S0  cycle k    read port addressed by pixel k (registered by the EBR)
//   S1  cycle k+1  RAM data for pixel k appears; captured into q2
//   S2  cycle k+2  count = base + 1, captured into c3
//   S3  cycle k+3  c3 written to bin pixel k at the next edge
// The RAM read for pixel k does not yet contain the counts of pixels k-1,
// k-2 and k-3 (still in the pipeline), so the newest of those with the same
// bin is forwarded:
//   base = (bin(k) == bin(k-1)) ? count(k-1)
//        : (bin(k) == bin(k-2)) ? count(k-2)
//        : (bin(k) == bin(k-3)) ? count(k-3)
//        : RAM data
// The bin comparisons are made one stage early and registered as a one-hot
// select (f1, f2, f3, f0).
// Pixel k-3 is written on the same edge that the read for pixel k is
// registered. When both are the same bin the read address is moved to the
// neighbouring bin (its data is not used; the count is forwarded), so the EBR
// never reads and writes one address on the same edge.
// Every counted pixel is written, including runs of identical pixels.
//
// Read-out (pix_sel = 0): the read port is addressed by `bin`. One clock after
// `bin` changes, that bin's count is captured into `data`. Read-out does not
// write the RAM.
//
// Clear sweep (pix_sel = 0, clr_en = 1, `bin` stepping every clock): one clock
// after `bin` changes, the previous bin is written to zero. The parent runs
// this over all 1024 bins after the bank has been sent, and after reset.
//
// The write stage is driven only by the valid flags that travel with each
// pixel, never by the bank mode, so:
//   - nothing is written while frame_valid is high but no pixel is valid
//     (front porch), whatever the pixel bus carries;
//   - the last pixels of a frame are written to their own bins after
//     line_valid and frame_valid have fallen (the pipeline drains in 3 clocks);
//   - clearing is a separate sweep, so it cannot depend on read-out timing.
module histogram3 (
    input  wire        rst,         // synchronous reset of the pipeline (RAM contents are not cleared)
    input  wire        clk,
    input  wire        pix_sel,     // registered: 1 = read port follows `pixel` (bank not being read out or cleared)
    input  wire        clr_en,      // 1 = clear sweep: zero each bin one clock after `bin` leaves it
    input  wire [9:0]  pixel,       // 10-bit pixel value
    input  wire        pixel_valid, // pixel qualifier: this bank is counting and line_valid is high
    input  wire [9:0]  bin,         // bin to read out when pix_sel = 0
    output wire [23:0] data         // captured count of the last bin read out
  );

  // S1: pixel k, RAM data arriving
  reg        v1 = 1'b0;
  reg [9:0]  a1 = 10'd0;
  // S2: pixel k, add stage
  reg        v2 = 1'b0;
  reg [9:0]  a2 = 10'd0;
  reg [23:0] q2 = 24'd0;
  reg        f0 = 1'b1, f1 = 1'b0, f2 = 1'b0, f3 = 1'b0;   // one-hot base select
  // S3: pixel k, write stage (drives the write port)
  reg        v3 = 1'b0;
  reg [9:0]  a3 = 10'd0;
  reg [23:0] c3 = 24'd0;
  // S4 / S5: counts already written, kept for forwarding
  reg        v4 = 1'b0;
  reg [9:0]  a4 = 10'd0;
  reg [23:0] c4 = 24'd0;
  reg [23:0] c5 = 24'd0;

  // Read-out / clear
  reg [9:0]  prev_bin = 10'd0;
  reg        prev_bin_incremented = 1'b0;
  reg [23:0] data_out_persistent = 24'd0;

  wire [23:0] data_out;
  wire [23:0] base;
  wire        e1, e2, e3;
  wire        collide;
  wire        clear_we;
  wire [9:0]  ram_rd_addr;
  wire [9:0]  ram_wr_addr;
  wire [23:0] ram_wr_data;
  wire        bin_incremented;

  // In cycle k+1: S1 = pixel k, S2 = k-1, S3 = k-2, S4 = k-3.
  assign e1 = v2 & (a1 == a2);
  assign e2 = v3 & (a1 == a3);
  assign e3 = v4 & (a1 == a4);

  always @(posedge clk)
  begin
    if (rst)
    begin
      v1                   <= 1'b0;
      v2                   <= 1'b0;
      v3                   <= 1'b0;
      v4                   <= 1'b0;
      f0                   <= 1'b1;
      f1                   <= 1'b0;
      f2                   <= 1'b0;
      f3                   <= 1'b0;
      prev_bin             <= 10'd0;
      prev_bin_incremented <= 1'b0;
    end
    else
    begin
      // S0 -> S1
      v1 <= pixel_valid;
      a1 <= pixel;
      // S1 -> S2
      v2 <= v1;
      a2 <= a1;
      q2 <= data_out;
      f1 <= e1;
      f2 <= ~e1 & e2;
      f3 <= ~e1 & ~e2 & e3;
      f0 <= ~e1 & ~e2 & ~e3;
      // S2 -> S3
      v3 <= v2;
      a3 <= a2;
      c3 <= base + 24'd1;
      // S3 -> S4 -> S5
      v4 <= v3;
      a4 <= a3;
      c4 <= c3;
      c5 <= c4;

      prev_bin             <= bin;
      prev_bin_incremented <= bin_incremented;
      if (prev_bin_incremented)
        data_out_persistent <= data_out;
    end
  end

  ram_dp_s ram_dp_i (
             .Reset     (rst),

             .RdClock   (clk),
             .RdClockEn (~rst),
             .RdAddress (ram_rd_addr),
             .Q         (data_out),

             .WrClock   (clk),
             .WrClockEn (~rst),
             .WrAddress (ram_wr_addr),
             .Data      (ram_wr_data),
             .WE        (v3 | clear_we)
           );

  assign base = ({24{f1}} & c3) | ({24{f2}} & c4) | ({24{f3}} & c5) | ({24{f0}} & q2);

  // Count write: pixel in S3. Clear write: the bin `bin` held on the previous
  // clock (only while no count write is pending; a bank is cleared only after
  // it has been sent, so the two do not overlap in normal operation).
  assign clear_we = clr_en & prev_bin_incremented & ~v3;

  // Same-edge read/write of one address: read the neighbouring bin instead.
  assign collide     = v3 & (pixel == a3);
  assign ram_rd_addr = pix_sel ? {pixel[9:1], pixel[0] ^ collide} : bin;
  assign ram_wr_addr = v3 ? a3 : prev_bin;
  assign ram_wr_data = v3 ? c3 : 24'd0;

  assign data            = data_out_persistent;
  assign bin_incremented = (bin != prev_bin);

endmodule
