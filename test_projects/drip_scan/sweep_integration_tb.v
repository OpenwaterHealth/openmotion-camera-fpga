`timescale 1ns / 1ps
// sweep_integration_tb.v — full-chain drip-scan integration TB. Replicates
// top.v's v2 wiring EXACTLY (see HistoFPGAFw/top.v: i2c_slave + fpga_regs;
// 2FF mode sync; histogram_module(enable=~mode_pix) + line_capture(enable=
// mode_pix) racing into the SHARED Serializer with reset `pix_reset |
// ~(hm_active|lc_active)` and mux `lc_active ? lc_word : hm_word`; NEW:
// sweep_value and lc_overrun between fpga_regs and line_capture) because
// top.v cannot be simulated (Lattice OSCI/PLL primitives).
// Frame ledger (histogram3 accumulates on fv/lv regardless of enable;
// bins wipe only on a histogram SERIALIZE readout — see integration_tb.v):
//   F1 histo boot (wipes) | F2 legacy line-5 | F3 sweep paced | F4 sweep
//   overrun | F5 sweep paced (flagged) | F6 histo (accumulated F2..F6 =
//   5 frames, wipes) | F7 histo steady (1 frame) | F8 legacy line-1, its
//   4100-B envelope drain (~1.17 ms) spans the next frame | F9 sweep-armed
//   short frame INSIDE F8's drain: every completed sweep line takes the
//   state==S_SER branch of line_capture's drop guard (cross-mode corner —
//   drop + latch, envelope must finish intact) | F10 sweep paced clean
//   (start line 2 via the F8 send's auto-inc republish) | F11 histo
//   (accumulated F8..F11 = 4 frames, wipes) | F12 histo steady.
`include "../HistoFPGAFw/i2c_slave.v"
`include "../HistoFPGAFw/fpga_regs.v"
`include "../HistoFPGAFw/crc16.v"
`include "../HistoFPGAFw/raw10_pack.v"
`include "../HistoFPGAFw/image_pusher.v"
`include "../HistoFPGAFw/line_capture.v"
`include "../HistoFPGAFw/histo_module.v"
`include "../HistoFPGAFw/histo_calc.v"
`include "../HistoFPGAFw/histo_serializer.v"
`include "../HistoFPGAFw/spi_master.v"
`include "i2c_line/ram_dp_s_beh.v"

module sweep_integration_tb;
  reg clk_osc = 0;  always #21   clk_osc = ~clk_osc;   // ~24 MHz
  reg clk_pix = 0;  always #3.75 clk_pix = ~clk_pix;   // ~133 MHz
  reg reset = 1;

  // Pre-existing histogram3 defect (repo issue #6): +4 spurious counts per
  // frame (see integration_tb.v). Sum checks include the offset; when #6
  // is fixed these fail loudly — remove the offset then.
  localparam SUM_BUG_PER_FRAME = 4;
  localparam PIXELS_PER_FRAME = 256;     // 2*PAIRS*LINES
  localparam LINES = 8, PAIRS = 16;
  localparam PUSH_BYTES = 2408;

  /*------------------I2C control plane (clk_osc domain)------------------*/
  reg m_scl = 1, m_sda_drive_low = 0;
  wire sda_oe;
  wire sda_bus = (m_sda_drive_low | sda_oe) ? 1'b0 : 1'b1;
  wire [7:0] r_addr, r_wdata, r_rdata;
  wire r_wstrobe;
  wire mode_image, sweep_value;
  wire [11:0] line_value, sent_line;
  wire line_req_toggle, line_ack_toggle, line_sent_toggle;
  wire img_active, lc_overrun;

  i2c_slave #(.I2C_ADDR(7'h5A)) i2c_slave_i (
      .clk(clk_osc), .reset(reset),
      .scl_i(m_scl), .sda_i(sda_bus), .sda_oe(sda_oe),
      .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
      .rd_data(r_rdata));

  fpga_regs fpga_regs_i (
      .clk(clk_osc), .reset(reset),
      .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
      .rd_data(r_rdata),
      .pll_lock_i(1'b1), .fv_i(fv),
      .line_sent_toggle_i(line_sent_toggle), .sent_line_i(sent_line),
      .img_active_i(img_active),
      .overrun_i(lc_overrun),
      .line_ack_toggle_i(line_ack_toggle),
      .mode_image_o(mode_image), .line_value_o(line_value),
      .sweep_value_o(sweep_value),
      .line_req_toggle_o(line_req_toggle));

  /*------------------Readout producers (clk_pix domain)------------------*/
  reg [1:0] mode_sync /* synthesis syn_preserve=1 */;
  always @(posedge clk_pix) mode_sync <= {mode_sync[0], mode_image};
  wire mode_pix = mode_sync[1];
  wire pix_reset = reset;

  reg fv = 0, lv = 0;
  reg [19:0] pd = 0;
  wire ser_done;
  wire [31:0] hm_word, lc_word;
  wire hm_active, lc_active;

  histogram_module histogram_module_i (
      .clk(clk_pix), .reset(pix_reset), .enable(~mode_pix),
      .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
      .serializer_done_i(ser_done),
      .word_o(hm_word), .serialize_active_o(hm_active),
      .debug(), .debug2());

  line_capture line_capture_i (
      .clk(clk_pix), .reset(pix_reset), .enable(mode_pix),
      .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
      .line_value_i(line_value), .sweep_value_i(sweep_value),
      .line_req_toggle_i(line_req_toggle),
      .line_ack_toggle_o(line_ack_toggle),
      .line_sent_toggle_o(line_sent_toggle), .sent_line_o(sent_line),
      .img_active_o(img_active), .overrun_o(lc_overrun),
      .serializer_done(ser_done),
      .word_o(lc_word), .serialize_active_o(lc_active));

  wire spi_clk, spi_mosi;
  Serializer serializer_i (
      .fast_clk_in(clk_pix),
      .reset(pix_reset | ~(hm_active | lc_active)),
      .data_in(lc_active ? lc_word : hm_word),
      .serial_out(spi_mosi), .slow_clk_out(spi_clk),
      .done(ser_done), .debug());

  /*------------------flat SPI byte-stream monitor------------------------*/
  // Packets vary in size now (4100-B envelopes vs 2408-B pushes), so the
  // monitor records EVERY byte at its absolute stream offset; tests index
  // from a snapshotted base. Sized 128K: the 12-frame ledger totals ~75 KB
  // of stream (2 sweep frames at 6 pushes + 6 envelopes + singles).
  reg [7:0] cur_byte; integer nbits = 0;
  integer bytes_lifetime = 0;
  reg [7:0] wire_bytes [0:131071];
  always @(posedge spi_clk) begin
    cur_byte = {spi_mosi, cur_byte[7:1]};   // LSB first
    nbits = nbits + 1;
    if (nbits == 8) begin
      wire_bytes[bytes_lifetime] = cur_byte;
      bytes_lifetime = bytes_lifetime + 1;
      nbits = 0;
    end
  end
  function [31:0] env_word(input integer base, input integer idx);
    env_word = {wire_bytes[base+4*idx+3], wire_bytes[base+4*idx+2],
                wire_bytes[base+4*idx+1], wire_bytes[base+4*idx]};
  endfunction

  /*------------------whole-sim white-box monitors-------------------------*/
  integer errors = 0;
  // Task-3 handoff contract: start_i must never pulse while the pusher is
  // mid-push (its internal busy reg; busy_o includes start_i itself).
  always @(posedge clk_pix)
    if (!reset && line_capture_i.push_start && line_capture_i.pusher_i.busy) begin
      errors = errors + 1;
      $display("FAIL: image_pusher start_i pulsed while busy");
    end
  // Count sweep-line drops taken specifically via the state==S_SER branch
  // of line_capture's drop guard (legacy envelope drain still in flight).
  // Only the F8/F9 cross-mode scenario may hit it; F4/F5's drops go through
  // the pusher_busy term with state==S_IDLE. Same-edge sampling as the DUT
  // (NBA stimulus), so the replicated condition sees identical values.
  integer sser_drops = 0;
  always @(posedge clk_pix)
    if (!reset && line_capture_i.sweep_hit_q && !line_capture_i.sweep_hit &&
        !(lv && fv) && !line_capture_i.pusher_busy &&
        line_capture_i.state === 1'b1)
      sser_drops = sser_drops + 1;

  /*------------------camera stimulus--------------------------------------*/
  integer L, C;
  task send_frame;
    begin
      fv <= 1; #400;
      for (L = 0; L < LINES; L = L + 1) begin
        @(posedge clk_pix); lv <= 1;
        for (C = 0; C < PAIRS; C = C + 1) begin
          pd <= ((((2*C + 1 + L) & 20'h3FF) << 10) | ((2*C + L) & 20'h3FF));
          @(posedge clk_pix);
        end
        lv <= 0; pd <= 0;
        repeat (40) @(posedge clk_pix);   // horizontal blanking
      end
      fv <= 0;
    end
  endtask
  integer tp;
  task send_frame_paced;                  // sweep timing: wait out drains
    begin
      fv <= 1; #400;
      for (L = 0; L < LINES; L = L + 1) begin
        @(posedge clk_pix); lv <= 1;
        for (C = 0; C < PAIRS; C = C + 1) begin
          pd <= ((((2*C + 1 + L) & 20'h3FF) << 10) | ((2*C + L) & 20'h3FF));
          @(posedge clk_pix);
        end
        lv <= 0; pd <= 0;
        repeat (40) @(posedge clk_pix);
        tp = $time;
        while (lc_active && ($time - tp) < 1_500_000) #5000;
        #10000;
      end
      fv <= 0;
    end
  endtask

  /*------------------I2C master + wr_reg/rd_reg---------------------------*/
  `include "i2c_line/i2c_master_tasks.vh"
  reg ack;
  task wr_reg(input [7:0] r, input [7:0] v);
    begin
      i2c_start; i2c_write_byte({7'h5A,1'b0}, ack);
      i2c_write_byte(r, ack); i2c_write_byte(v, ack); i2c_stop; #2000;
    end
  endtask
  task rd_reg(input [7:0] r, output [7:0] v);
    begin
      i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); i2c_write_byte(r, ack);
      i2c_start; i2c_write_byte({7'h5A,1'b1}, ack);
      i2c_read_byte(1'b0, v); i2c_stop; #2000;
    end
  endtask

  /*------------------checks + reference models----------------------------*/
  // All comparisons use ===/!== so a check can never pass on X (an X-laden
  // == comparison yields X, and `if (!X)` silently skips the FAIL branch).
  task check(input cond, input [1023:0] msg);
    if (cond !== 1'b1) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask
  integer t0;
  task wait_total_bytes(input integer target, input integer max_ns);
    begin
      t0 = $time;
      while (bytes_lifetime < target && ($time - t0) < max_ns) #10000;
      #50000;
    end
  endtask
  integer sum_i; reg [31:0] sum_acc;
  function [31:0] env_sum(input integer base);
    begin
      sum_acc = 0;
      for (sum_i = 0; sum_i < 1024; sum_i = sum_i + 1)
        sum_acc = sum_acc + (env_word(base, sum_i) & 24'hFFFFFF);
      env_sum = sum_acc;
    end
  endfunction
  task check_env_sum(input integer base, input [31:0] expected,
                     input [1023:0] label);
    begin
      $display("INFO: %0s: observed sum=%0d expected=%0d",
               label, env_sum(base), expected);
      check(env_sum(base) === expected, label);
    end
  endtask

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
  // Byte-exact legacy 4100-B envelope: words 0..1023 of the 1025-word packet
  // ({spacer, 24-bit data}; line tags at 0/1, magic at 2, frame counter at
  // 1023, pairs 0..15, zeros elsewhere). Word 1024 — the post-wrap staging
  // word emitted after word_idx wraps 0x3FF->0x000 — is not part of the
  // packet contract and was never pinned by feature/5; it is skipped (the
  // byte-exact count check still proves it exists).
  reg [31:0] exp_w;
  integer ew, env_mism;
  task check_envelope(input integer base, input [11:0] eline,
                      input [7:0] eframe_spacer, input [1023:0] label);
    begin
      env_mism = 0;
      for (ew = 0; ew < 1024; ew = ew + 1) begin
        exp_w = 32'd0;
        if (ew < 16)         exp_w[19:0]  = tb_pair(eline, ew);
        if (ew == 0)         exp_w[31:24] = eline[7:0];
        else if (ew == 1)    exp_w[31:24] = {4'b0, eline[11:8]};
        else if (ew == 2)    exp_w[31:24] = 8'hB6;
        else if (ew == 1023) exp_w[31:24] = eframe_spacer;
        if (env_word(base, ew) !== exp_w) begin
          if (env_mism == 0)
            $display("  first envelope mismatch at word %0d: got %08x want %08x",
                     ew, env_word(base, ew), exp_w);
          env_mism = env_mism + 1;
        end
      end
      check(env_mism === 0, label);
    end
  endtask

  integer base, k, w;
  reg [31:0] wv;
  reg [7:0] rb;
  initial begin
    $dumpfile("out/sweep_integration_tb.vcd");
    $dumpvars(0, sweep_integration_tb);
    reset = 1;
    #300 reset = 0;

    // ===== F1: BOOT HISTOGRAM — envelope bit-identical to feature/5 =====
    base = bytes_lifetime;
    send_frame;
    wait_total_bytes(base + 4100, 1_700_000);
    check(bytes_lifetime === base + 4100, "F1: exactly one 4100-B envelope");
    check(env_word(base, 2) >> 24 === 8'h00, "F1: word2 spacer 0x00 (no magic)");
    check(env_word(base, 1023) >> 24 === 8'h01, "F1: frame counter spacer == 1");
    check_env_sum(base, PIXELS_PER_FRAME + SUM_BUG_PER_FRAME, "F1: histogram sum");

    // ===== I2C sanity =====
    rd_reg(8'h00, rb); check(rb === 8'h5A, "I2C: ID 0x5A");
    rd_reg(8'h01, rb); check(rb === 8'h02, "I2C: VERSION 0x02");

    // ===== F2: LEGACY single-line image mode (regression) =====
    wr_reg(8'h04, 8'h05); wr_reg(8'h05, 8'h00);   // LINE = 5
    wr_reg(8'h03, 8'h01);                          // image mode, no sweep
    #50_000;
    base = bytes_lifetime;
    send_frame;
    wait_total_bytes(base + 4100, 1_700_000);
    check(bytes_lifetime === base + 4100, "F2: one legacy 4100-B image packet");
    check(env_word(base, 2) >> 24 === 8'hB6, "F2: magic 0xB6");
    check(env_word(base, 0) >> 24 === 8'h05, "F2: line tag 5");
    check(env_word(base, 1023) >> 24 === 8'h02, "F2: frame counter spacer == 2");
    for (w = 0; w < PAIRS; w = w + 1) begin
      wv = env_word(base, w);
      check((wv & 20'hFFFFF) === tb_pair(12'd5, w), "F2: line-5 pixel word");
    end

    // ===== F3: SWEEP, start line 2 — byte-exact pushes ====
    // (F2's legacy send auto-incremented LINE to 6; rewrite it first.)
    wr_reg(8'h04, 8'h02); wr_reg(8'h05, 8'h00);   // start line = 2
    wr_reg(8'h03, 8'h03);                          // image + SWEEP
    #50_000;
    base = bytes_lifetime;
    send_frame_paced;                              // frame_cnt = 3
    wait_total_bytes(base + 6*PUSH_BYTES, 12_000_000);
    check(bytes_lifetime === base + 6*PUSH_BYTES, "F3: exactly 6 pushes");
    for (k = 0; k < 6; k = k + 1)
      check_push(base + k*PUSH_BYTES, 2+k, 8'd3, 4'h0, "F3: byte-exact push (frame const)");
    rd_reg(8'h09, rb);
    check(rb === 8'h03, "F3: STATUS lock+active, overrun clear");

    // ===== F4: OVERRUN — production-rate frame, drain >> row time =====
    base = bytes_lifetime;
    send_frame;                                    // frame_cnt = 4
    wait_total_bytes(base + PUSH_BYTES, 3_000_000);
    #200000;
    check(bytes_lifetime === base + PUSH_BYTES, "F4: exactly ONE push (rest dropped)");
    check_push(base, 12'd2, 8'd4, 4'h0, "F4: push line 2, flags still 0");
    rd_reg(8'h09, rb);
    check(rb === 8'h07, "F4: STATUS bit2 overrun set (via I2C)");

    // ===== F5: latch -> header flag bit0 on subsequent pushes ====
    base = bytes_lifetime;
    send_frame_paced;                              // frame_cnt = 5
    wait_total_bytes(base + 6*PUSH_BYTES, 12_000_000);
    check(bytes_lifetime === base + 6*PUSH_BYTES, "F5: 6 pushes while latched");
    for (k = 0; k < 6; k = k + 1)
      check_push(base + k*PUSH_BYTES, 2+k, 8'd5, 4'h1, "F5: flagged byte-exact push");

    // ===== F6/F7: EXIT — histogram streaming intact ====
    // F6 is the documented discard-first packet: bins accumulated F2..F6
    // (5 frames; no histogram readout ran during image mode) then wipe.
    wr_reg(8'h03, 8'h00);
    #50_000;
    base = bytes_lifetime;
    send_frame;                                    // frame_cnt = 6
    wait_total_bytes(base + 4100, 1_700_000);
    check(bytes_lifetime === base + 4100, "F6: one 4100-B envelope");
    check(env_word(base, 2) >> 24 === 8'h00, "F6: no magic (histogram)");
    check_env_sum(base, 5*(PIXELS_PER_FRAME + SUM_BUG_PER_FRAME),
                  "F6: first-after-exit sum (5 accumulated frames)");
    base = bytes_lifetime;
    send_frame;                                    // frame_cnt = 7
    wait_total_bytes(base + 4100, 1_700_000);
    check(bytes_lifetime === base + 4100, "F7: one 4100-B envelope");
    check(env_word(base, 2) >> 24 === 8'h00, "F7: no magic");
    check_env_sum(base, PIXELS_PER_FRAME + SUM_BUG_PER_FRAME,
                  "F7: steady-state histogram sum");

    // ===== F8/F9: CROSS-MODE — sweep line completes during a legacy =====
    // ===== S_SER envelope drain (state==S_SER branch of the drop guard) ==
    // F8: legacy line-1 capture; its envelope drain (~1.17 ms) starts at fv
    // fall. The CTRL=0x03 arm write below takes ~144 us of I2C time, which
    // delivers {sweep=1, line=1} well before F9. The envelope stays
    // byte-exact end to end: wr_sel enters F9 at 1 (13 pushes across
    // F3/F4/F5), so the dropped sweep hits write buffer 1 and never touch
    // the legacy buffer 0 mid-drain; even at the other parity the 144-us
    // I2C spacing means words 0..15 (~20 us) drain before any overwrite.
    // F9 (short blanking, entirely inside the drain): lines 1..7 complete
    // with state==S_SER and pusher idle -> 7 drops via the S_SER guard
    // term, latch set (the arm publish's pended clear consumed at F9's
    // fv_rise wipes F4's stale latch first, so the post-F9 latch is
    // attributable to these drops), zero pushes, envelope intact. At drain
    // end the envelope's line_sent toggle auto-increments LINE 1->2 in
    // fpga_regs, republishing {sweep=1, line=2}: F10's fv_rise consumes
    // the new pended clear (b3be364 re-arm semantics) -> clean flags-0
    // pushes for lines 2..7.
    wr_reg(8'h04, 8'h01); wr_reg(8'h05, 8'h00);   // LINE = 1
    wr_reg(8'h03, 8'h01);                          // legacy image mode
    #50_000;
    check(sser_drops === 0, "F8: no S_SER-branch drops anywhere before F9");
    base = bytes_lifetime;
    send_frame;                                    // frame_cnt = 8; drain starts
    wr_reg(8'h03, 8'h03);                          // arm SWEEP mid-drain (~144 us)
    #20_000;                                       // CDC settle
    check(line_capture_i.state === 1'b1, "F9 precondition: legacy drain in flight");
    send_frame;                                    // frame_cnt = 9, inside drain
    check(line_capture_i.state === 1'b1, "F9: drain STILL in flight after frame");
    check(lc_overrun === 1'b1, "F9: overrun latch set by cross-mode drops");
    check(sser_drops === 7, "F9: lines 1..7 all dropped via the S_SER guard");
    wait_total_bytes(base + 4100, 2_500_000);
    #200000;
    check(bytes_lifetime === base + 4100, "F8: envelope only — ZERO pushes leaked");
    // frame spacer == 9: the 0x3FF spacer word stages at drain END, after
    // F9's fv_rise bumped frame_cnt — proof the drain crossed a whole frame.
    check_envelope(base, 12'd1, 8'd9, "F8: legacy envelope byte-exact (intact)");
    rd_reg(8'h09, rb);
    check(rb === 8'h07, "F9: STATUS bit2 overrun set (via I2C)");

    // ===== F10: next sweep frame after the cross-mode drop is clean ====
    base = bytes_lifetime;
    send_frame_paced;                              // frame_cnt = 10
    wait_total_bytes(base + 6*PUSH_BYTES, 12_000_000);
    check(bytes_lifetime === base + 6*PUSH_BYTES, "F10: exactly 6 pushes");
    for (k = 0; k < 6; k = k + 1)
      check_push(base + k*PUSH_BYTES, 2+k, 8'd10, 4'h0,
                 "F10: byte-exact clean push after cross-mode drop");
    rd_reg(8'h09, rb);
    check(rb === 8'h03, "F10: overrun cleared (auto-inc republish + frame boundary)");

    // ===== F11/F12: EXIT again — histogram streaming still intact ====
    wr_reg(8'h03, 8'h00);
    #50_000;
    base = bytes_lifetime;
    send_frame;                                    // frame_cnt = 11
    wait_total_bytes(base + 4100, 1_700_000);
    check(bytes_lifetime === base + 4100, "F11: one 4100-B envelope");
    check(env_word(base, 2) >> 24 === 8'h00, "F11: no magic (histogram)");
    check(env_word(base, 1023) >> 24 === 8'h0B, "F11: frame counter spacer == 11");
    check_env_sum(base, 4*(PIXELS_PER_FRAME + SUM_BUG_PER_FRAME),
                  "F11: first-after-exit sum (4 accumulated frames F8..F11)");
    base = bytes_lifetime;
    send_frame;                                    // frame_cnt = 12
    wait_total_bytes(base + 4100, 1_700_000);
    check(bytes_lifetime === base + 4100, "F12: one 4100-B envelope");
    check(env_word(base, 2) >> 24 === 8'h00, "F12: no magic");
    check(env_word(base, 1023) >> 24 === 8'h0C, "F12: frame counter spacer == 12");
    check_env_sum(base, PIXELS_PER_FRAME + SUM_BUG_PER_FRAME,
                  "F12: steady-state histogram sum");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end

  // ~24 ms of simulated time (19 push drains + 6 envelopes); generous cap
  initial begin
    #200_000_000;
    $display("FAIL: watchdog timeout -- sim did not finish");
    $finish;
  end
endmodule
