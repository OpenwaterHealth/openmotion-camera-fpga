`timescale 1ns / 1ps
// raw10_pack_tb.v — pinned bit-layout test. px0..7 = 3FF,000,155,2AA,
// 0AB,30C,11E,25D packs to FF 03 50 95 AA AB 30 EC 51 97 (hand-computed
// per spec §4.1: pixel k of a 4-px group at group bits [10k+9:10k],
// low byte first; equivalently pair n at payload bits [20n+19:20n]).
`include "../HistoFPGAFw/raw10_pack.v"

module raw10_pack_tb;
  reg clk = 0; always #3.75 clk = ~clk;
  reg clear = 0, pair_en = 0, byte_take = 0;
  reg [19:0] pair_in = 20'd0;
  wire [7:0] byte_out;
  wire byte_avail, pair_room;

  raw10_pack dut (
    .clk(clk), .clear(clear),
    .pair_en(pair_en), .pair_in(pair_in),
    .byte_take(byte_take), .byte_out(byte_out),
    .byte_avail(byte_avail), .pair_room(pair_room));

  integer errors = 0;
  task check(input cond, input [511:0] msg);
    if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask

  reg [19:0] pairs [0:3];
  reg [7:0]  exp [0:9];
  reg [7:0]  got [0:9];
  initial begin
    pairs[0] = 20'h003FF; pairs[1] = 20'hAA955;
    pairs[2] = 20'hC30AB; pairs[3] = 20'h9751E;
    exp[0]=8'hFF; exp[1]=8'h03; exp[2]=8'h50; exp[3]=8'h95; exp[4]=8'hAA;
    exp[5]=8'hAB; exp[6]=8'h30; exp[7]=8'hEC; exp[8]=8'h51; exp[9]=8'h97;
  end

  task do_clear;
    begin @(posedge clk); clear <= 1; @(posedge clk); clear <= 0; @(posedge clk); end
  endtask
  task do_push(input [19:0] p);
    begin
      while (!pair_room) @(posedge clk);
      pair_in <= p; pair_en <= 1;
      @(posedge clk);
      pair_en <= 0; @(posedge clk);
    end
  endtask
  task do_pop(output [7:0] b);
    begin
      while (!byte_avail) @(posedge clk);
      b = byte_out;                 // value presented BEFORE the take edge
      byte_take <= 1;
      @(posedge clk);
      byte_take <= 0; @(posedge clk);
    end
  endtask
  task do_push_pop(input [19:0] p, output [7:0] b);
    begin
      b = byte_out;
      pair_in <= p; pair_en <= 1; byte_take <= 1;
      @(posedge clk);
      pair_en <= 0; byte_take <= 0; @(posedge clk);
    end
  endtask

  integer pi, bi, both;
  initial begin
    $dumpfile("out/raw10_pack_tb.vcd"); $dumpvars(0, raw10_pack_tb);
    #100;
    do_clear;

    // A: sequential stream — push whenever dry, pop 10 bytes
    pi = 0;
    for (bi = 0; bi < 10; bi = bi + 1) begin
      while (!byte_avail) begin do_push(pairs[pi]); pi = pi + 1; end
      do_pop(got[bi]);
    end
    for (bi = 0; bi < 10; bi = bi + 1)
      check(got[bi] == exp[bi], "A: packed byte value");
    check(!byte_avail, "A: drained empty");
    check(pi == 4, "A: consumed exactly 4 pairs");

    // B: same stream with simultaneous push+pop cycles interleaved —
    // proves the combined-update arm of the accumulator is correct
    do_clear;
    do_push(pairs[0]);
    pi = 1; bi = 0; both = 0;
    while (bi < 10) begin
      if (pi < 4 && pair_room && byte_avail) begin
        do_push_pop(pairs[pi], got[bi]); pi = pi + 1; bi = bi + 1; both = both + 1;
      end else if (byte_avail) begin
        do_pop(got[bi]); bi = bi + 1;
      end else begin
        do_push(pairs[pi]); pi = pi + 1;
      end
    end
    for (bi = 0; bi < 10; bi = bi + 1)
      check(got[bi] == exp[bi], "B: packed byte value (simultaneous path)");
    check(both >= 1, "B: at least one simultaneous push+pop exercised");
    check(!byte_avail, "B: drained empty");

    // C: clear discards buffered bits
    do_clear;
    do_push(20'hFFFFF);
    do_clear;
    check(!byte_avail, "C: cleared empty");
    pi = 0;
    for (bi = 0; bi < 10; bi = bi + 1) begin
      while (!byte_avail) begin do_push(pairs[pi]); pi = pi + 1; end
      do_pop(got[bi]);
    end
    for (bi = 0; bi < 10; bi = bi + 1)
      check(got[bi] == exp[bi], "C: clean stream after clear");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end

  initial begin
    #2_000_000;
    $display("FAIL: watchdog timeout");
    $finish;
  end
endmodule
