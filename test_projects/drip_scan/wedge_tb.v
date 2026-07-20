`timescale 1ns / 1ps
// wedge_tb.v — image_pusher SERIALIZE watchdog: a wedged SPI push (the
// serializer/SPI handshake stops delivering `done` rises mid-push) must
// self-heal instead of sticking busy forever and silently killing the
// remaining ~1300 pushes of a sweep. Ports commit 992dc41's histo_module
// guard-counter pattern (2^21 clk ~= 15.8 ms at 132.8 MHz) into the
// pusher: on overflow the push aborts (serialize_active_o dropped, busy
// cleared, FSM to S_IDLE), the sticky wedge_o flag rises, and line_capture
// latches the wedge into BOTH its overrun latch (STATUS bit2 / header
// flag bit0) and its dedicated wedge latch (STATUS bit3 / header flag
// bit1, via wedge_latch_o) — the host can tell a wedge from a plain
// overrun. Both latches clear on the same re-arm publish semantics.
//
// Scenario: target line 7 -> one push per frame. F1 clean push (byte-exact
// baseline). F2 push is wedged by forcing serializer_done low mid-push;
// the TB verifies escape within the timeout window, wedge_o sticky, both
// latches set, then releases the force and verifies the F3 push is
// byte-exact (flags bits 1:0 = 11: both latches held, no re-arm publish)
// and that the new start cleared wedge_o. F4: a re-arm publish clears
// both latches at the next frame boundary -> clean flags-0 push.
`include "../HistoFPGAFw/crc16.v"
`include "../HistoFPGAFw/raw10_pack.v"
`include "../HistoFPGAFw/image_pusher.v"
`include "../HistoFPGAFw/line_capture.v"
`include "../HistoFPGAFw/histo_serializer.v"
`include "../HistoFPGAFw/spi_master.v"
`include "i2c_line/ram_dp_s_beh.v"

module wedge_tb;
  reg clk = 0; always #3.75 clk = ~clk;
  reg reset = 1;

  localparam LINES = 8, PAIRS = 16;
  localparam PUSH_BYTES = 2408;
  // 992dc41 guard: escape after 2^21 clk = 2^21 * 7.5 ns = 15,728,640 ns.
  localparam GUARD_NS = 15_728_640;

  reg fv = 0, lv = 0;
  reg [19:0] pd = 0;
  integer L, C;

  // CDC: TB plays the fpga_regs side ({line=7, sweep=1} delivered together)
  reg [11:0] line_value = 12'd7;
  reg sweep_value = 1'b1;
  reg line_req = 0;
  reg enable = 1'b1;
  wire line_ack, line_sent;
  wire [11:0] sent_line;
  wire img_active, overrun, wedge_latch;
  wire ser_done, ser_active;
  wire [31:0] word;

  line_capture dut (
    .clk(clk), .reset(reset), .enable(enable),
    .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
    .line_value_i(line_value), .sweep_value_i(sweep_value),
    .line_req_toggle_i(line_req),
    .line_ack_toggle_o(line_ack), .line_sent_toggle_o(line_sent),
    .sent_line_o(sent_line), .img_active_o(img_active),
    .overrun_o(overrun), .wedge_latch_o(wedge_latch),
    .serializer_done(ser_done), .word_o(word),
    .serialize_active_o(ser_active));

  wire spi_clk, spi_mosi;
  Serializer ser (
    .fast_clk_in(clk), .reset(reset | ~ser_active), .data_in(word),
    .serial_out(spi_mosi), .slow_clk_out(spi_clk), .done(ser_done), .debug());

  // flat byte-stream monitor (LSB-first). Sized 256K: while wedged, the
  // free-running Serializer keeps clocking garbage bytes onto the wire for
  // ~15.7 ms (~55K bytes); tests snapshot base after recovery.
  reg [7:0] cur; integer nbits = 0;
  integer bytes_lifetime = 0;
  reg [7:0] wire_bytes [0:262143];
  always @(posedge spi_clk) begin
    cur = {spi_mosi, cur[7:1]};
    nbits = nbits + 1;
    if (nbits == 8) begin
      wire_bytes[bytes_lifetime] = cur;
      bytes_lifetime = bytes_lifetime + 1;
      nbits = 0;
    end
  end

  integer errors = 0;
  task check(input cond, input [1023:0] msg);
    if (cond !== 1'b1) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask

  // white-box: Task-3 handoff contract — start_i must never pulse while the
  // pusher is mid-push (its internal busy reg; busy_o includes start_i itself)
  always @(posedge clk)
    if (!reset && dut.push_start && dut.pusher_i.busy) begin
      errors = errors + 1;
      $display("FAIL: image_pusher start_i pulsed while busy");
    end

  integer t0;
  task wait_total_bytes(input integer target, input integer max_ns);
    begin
      t0 = $time;
      while (bytes_lifetime < target && ($time - t0) < max_ns) #10000;
      #50000;
    end
  endtask

  // stimulus (sweep_tb pattern): 8 lines x 16 pairs, pixA=(2C+L)&3FF
  // pixB=(2C+1+L)&3FF. Only line 7 >= target, so exactly one push/frame.
  integer tp;
  task send_frame_paced;
    begin
      fv <= 1; #400;
      for (L = 0; L < LINES; L = L + 1) begin
        @(posedge clk); lv <= 1;
        for (C = 0; C < PAIRS; C = C + 1) begin
          pd <= ((((2*C + 1 + L) & 20'h3FF) << 10) | ((2*C + L) & 20'h3FF));
          @(posedge clk);
        end
        lv <= 0; pd <= 0;
        repeat (40) @(posedge clk);
        tp = $time;
        while (ser_active && ($time - tp) < 1_500_000) #5000;
        #10000;
      end
      fv <= 0;
    end
  endtask

  // ---- reference model (byte-exact, image_pusher_tb/check_push style) ----
  function [19:0] tb_pair(input [11:0] fline, input integer idx);
    tb_pair = (idx < 16)
      ? ((((2*idx + 1 + fline) & 10'h3FF) << 10) | ((2*idx + fline) & 10'h3FF))
      : 20'd0;
  endfunction
  function [15:0] crc16_ref(input [15:0] c, input [7:0] b);
    integer k; reg [15:0] t; reg fb;
    begin
      t = c;
      for (k = 7; k >= 0; k = k - 1) begin
        fb = t[15] ^ b[k];
        t = {t[14:0], 1'b0} ^ (fb ? 16'h1021 : 16'h0000);
      end
      crc16_ref = t;
    end
  endfunction
  reg [7:0] exp_push [0:2407];
  reg [39:0] gval; reg [15:0] ecrc;
  integer ep, eb, ci, mism;
  task check_push(input integer base, input [11:0] eline,
                  input [7:0] eframe, input [3:0] eflags,
                  input [1023:0] label);
    begin
      exp_push[0] = 8'hB6; exp_push[1] = 8'h01;
      exp_push[2] = eline[7:0];
      exp_push[3] = {eflags, eline[11:8]};
      exp_push[4] = eframe; exp_push[5] = 8'h00;
      for (ep = 0; ep < 480; ep = ep + 1) begin
        gval = {tb_pair(eline, 2*ep + 1), tb_pair(eline, 2*ep)};
        for (eb = 0; eb < 5; eb = eb + 1)
          exp_push[6 + 5*ep + eb] = gval >> (8*eb);
      end
      ecrc = 16'hFFFF;
      for (eb = 0; eb < 2406; eb = eb + 1)
        ecrc = crc16_ref(ecrc, exp_push[eb]);
      exp_push[2406] = ecrc[15:8];
      exp_push[2407] = ecrc[7:0];
      mism = 0;
      for (ci = 0; ci < 2408; ci = ci + 1)
        if (wire_bytes[base+ci] !== exp_push[ci]) begin
          if (mism == 0)
            $display("  first mismatch at byte %0d: got %02x want %02x",
                     ci, wire_bytes[base+ci], exp_push[ci]);
          mism = mism + 1;
        end
      check(mism === 0, label);
    end
  endtask

  integer base, t_stall, esc_d;
  initial begin
    $dumpfile("out/wedge_tb.vcd"); $dumpvars(0, wedge_tb);
    #100 reset = 0; #100;
    line_req = ~line_req; #500;          // deliver {line=7, sweep=1}
    check(line_ack === line_req, "CDC ack for {line=7, sweep=1}");

    // ===== F1: clean baseline — one byte-exact push =====
    base = bytes_lifetime;
    send_frame_paced;                    // frame_cnt = 1
    wait_total_bytes(base + PUSH_BYTES, 2_000_000);
    check(bytes_lifetime === base + PUSH_BYTES, "F1: exactly one push");
    check_push(base, 12'd7, 8'd1, 4'h0, "F1: clean byte-exact push");
    check(overrun === 1'b0, "F1: no overrun");

    // ===== F2: wedge the push mid-flight =====
    // Line 7 completes at frame end; the push drains past frame end. Once
    // bytes are flowing, gate serializer_done off: no more word_done rises
    // reach the pusher, parking its FSM in S_HAND.
    base = bytes_lifetime;
    fv <= 1; #400;
    for (L = 0; L < LINES; L = L + 1) begin
      @(posedge clk); lv <= 1;
      for (C = 0; C < PAIRS; C = C + 1) begin
        pd <= ((((2*C + 1 + L) & 20'h3FF) << 10) | ((2*C + L) & 20'h3FF));
        @(posedge clk);
      end
      lv <= 0; pd <= 0;
      repeat (40) @(posedge clk);
    end
    fv <= 0;
    t0 = $time;
    while (bytes_lifetime < base + 64 && ($time - t0) < 500_000) #5000;
    check(bytes_lifetime >= base + 64, "F2: push under way before the wedge");
    check(dut.pusher_i.busy === 1'b1, "F2: pusher busy before the wedge");
    force ser_done = 1'b0;               // the wedge
    t_stall = $time;

    // ===== escape within the watchdog window =====
    t0 = $time;
    while (dut.pusher_i.busy !== 1'b0 && ($time - t0) < 20_000_000) #100_000;
    esc_d = $time - t_stall;
    check(dut.pusher_i.busy === 1'b0, "WD: pusher escaped the wedged push");
    $display("INFO: WD escape %0d ns after wedge (guard 2^21 clk = %0d ns)",
             esc_d, GUARD_NS);
    check((esc_d > 15_000_000) && (esc_d < 16_500_000),
          "WD: escape ~15.7 ms after the last word_done (2^21 clk guard)");
    check(dut.pusher_i.wedge_o === 1'b1, "WD: sticky wedge_o set");
    check(ser_active === 1'b0, "WD: line_capture serialize_active released");
    check(overrun === 1'b1, "WD: wedge folded into the overrun latch");
    check(wedge_latch === 1'b1, "WD: wedge_latch_o set (STATUS bit3 source)");

    // ===== recovery: next push must be byte-exact =====
    release ser_done;                    // Serializer is now held in reset
    #10_000;                             //  (ser_active low) -> done idles 0
    nbits = 0;                           // resync monitor: the abort cut the
                                         // wire mid-byte (hosts resync via
                                         // framing; the TB monitor has none)
    base = bytes_lifetime;
    send_frame_paced;                    // frame_cnt = 3
    wait_total_bytes(base + PUSH_BYTES, 2_000_000);
    check(bytes_lifetime === base + PUSH_BYTES, "F3: exactly one push after recovery");
    check_push(base, 12'd7, 8'd3, 4'h3,
               "F3: byte-exact push, flags bits1:0 = 11 (latches held, no re-arm)");
    check(overrun === 1'b1, "F3: overrun latch sticky until a re-arm publish");
    check(wedge_latch === 1'b1, "F3: wedge latch sticky until a re-arm publish");
    check(dut.pusher_i.wedge_o === 1'b0, "F3: wedge_o cleared by the new start");

    // ===== F4: re-arm publish clears BOTH latches at next fv_rise =====
    line_req = ~line_req; #500;          // re-deliver {line=7, sweep=1}
    check(line_ack === line_req, "F4: CDC ack for re-arm publish");
    check(wedge_latch === 1'b1, "F4: wedge latch holds until the frame boundary");
    base = bytes_lifetime;
    send_frame_paced;                    // frame_cnt = 4
    wait_total_bytes(base + PUSH_BYTES, 2_000_000);
    check(bytes_lifetime === base + PUSH_BYTES, "F4: one push after re-arm");
    check_push(base, 12'd7, 8'd4, 4'h0, "F4: flags clear after re-arm publish");
    check(overrun === 1'b0, "F4: overrun latch cleared at frame boundary");
    check(wedge_latch === 1'b0, "F4: wedge latch cleared at frame boundary");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end

  initial begin
    #60_000_000;
    $display("FAIL: watchdog timeout -- sim did not finish");
    $finish;
  end
endmodule
