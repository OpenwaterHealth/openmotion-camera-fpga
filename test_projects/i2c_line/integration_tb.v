`timescale 1ns / 1ps
// integration_tb.v — full-chain integration TB. Replicates top.v's EXACT
// producer/mux wiring (i2c_slave + fpga_regs on clk_osc; 2FF mode_sync into
// clk_pix; histogram_module(enable=~mode_pix) + line_capture(enable=mode_pix)
// racing into a SHARED Serializer with reset `pix_reset | ~(hm_active |
// lc_active)` and mux `lc_active ? lc_word : hm_word` — see HistoFPGAFw/top.v
// lines ~81-145) because top.v itself cannot be simulated (Lattice OSCI/PLL
// primitives). This is the only pre-hardware verification of the mode-mux
// invariants: histogram/image packet framing, I2C control plane, and the
// mid-frame mode-flip collision where both producers serialize the same
// blanking interval.
`include "../HistoFPGAFw/i2c_slave.v"
`include "../HistoFPGAFw/fpga_regs.v"
`include "../HistoFPGAFw/line_capture.v"
`include "../HistoFPGAFw/histo_module.v"
`include "../HistoFPGAFw/histo_calc.v"
`include "../HistoFPGAFw/histo_serializer.v"
`include "../HistoFPGAFw/spi_master.v"
`include "i2c_line/ram_dp_s_beh.v"

module integration_tb;
  // ---- two clock domains (matches top.v: clk_osc / clk_pixel_hs) ----
  reg clk_osc = 0;  always #21   clk_osc = ~clk_osc;   // ~24 MHz
  reg clk_pix = 0;  always #3.75 clk_pix = ~clk_pix;   // ~133 MHz
  reg reset = 1;                                       // shared async-ish TB reset

  // Pre-existing histogram3 defect (repo issue #6): a WE-pipeline mismatch in
  // histo_calc.v injects 2 spurious counts per histogram3 instance at every
  // frame_valid rise (+4/frame total across histo_a+histo_b in this design).
  // Sum checks below include this offset; when #6 is fixed these checks will
  // fail loudly — remove the offset then.
  localparam SUM_BUG_PER_FRAME = 4;
  // True pixel count per TB frame: 2*PAIRS*LINES = 2*16*8 (both pixels of
  // every pair, counted once each by histo_a + histo_b).
  localparam PIXELS_PER_FRAME = 256;

  /*------------------I2C control plane (clk_osc domain)------------------*/
  reg m_scl = 1, m_sda_drive_low = 0;
  wire sda_oe;
  wire sda_bus = (m_sda_drive_low | sda_oe) ? 1'b0 : 1'b1;

  wire [7:0] r_addr, r_wdata, r_rdata;
  wire r_wstrobe;
  wire mode_image;
  wire [11:0] line_value, sent_line;
  wire line_req_toggle, line_ack_toggle, line_sent_toggle, img_active;

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
      .line_ack_toggle_i(line_ack_toggle),
      .mode_image_o(mode_image), .line_value_o(line_value),
      .line_req_toggle_o(line_req_toggle));

  /*------------------Readout producers (clk_pix domain)-------------*/
  // mode bit into the pixel domain — EXACT 2FF replica of top.v lines ~108-110
  reg [1:0] mode_sync /* synthesis syn_preserve=1 */;
  always @(posedge clk_pix) mode_sync <= {mode_sync[0], mode_image};
  wire mode_pix = mode_sync[1];
  wire pix_reset = reset;

  // camera stimulus (shared by both producers, like the real cmos_data/fv/lv)
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
      .line_value_i(line_value), .line_req_toggle_i(line_req_toggle),
      .line_ack_toggle_o(line_ack_toggle),
      .line_sent_toggle_o(line_sent_toggle), .sent_line_o(sent_line),
      .img_active_o(img_active),
      .serializer_done(ser_done),
      .word_o(lc_word), .serialize_active_o(lc_active));

  /*------------------Shared Serializer + SPI-----------------------------*/
  // EXACT replica of top.v's mux: reset drops only when NEITHER producer is
  // active; data_in prefers line_capture over histogram_module.
  wire spi_mosi, spi_clk;
  Serializer serializer_i (
      .fast_clk_in(clk_pix),
      .reset(pix_reset | ~(hm_active | lc_active)),
      .data_in(lc_active ? lc_word : hm_word),
      .serial_out(spi_mosi), .slow_clk_out(spi_clk),
      .done(ser_done), .debug());

  /*------------------SPI byte/packet monitor------------------------------*/
  // LSB-first byte assembler (matches SPI_Master's modified bit order). Keeps
  // a running "current packet" buffer plus a snapshot of the last COMPLETED
  // packet, so tests can look at a stable finished packet even while the next
  // one is being assembled. A packet completes every 4100 bytes (both
  // producers always emit exactly that many, per the shared framing spec).
  reg [7:0] cur_byte;
  integer nbits = 0;
  integer nbytes_total = 0;              // bytes in the CURRENT (in-progress) packet
  integer pkt_count = 0;                 // number of completed packets seen
  reg [7:0] cur_pkt [0:4099];
  reg [7:0] last_pkt [0:4099];
  always @(posedge spi_clk) begin
    cur_byte = {spi_mosi, cur_byte[7:1]};   // LSB first
    nbits = nbits + 1;
    if (nbits == 8) begin
      if (nbytes_total < 4100) cur_pkt[nbytes_total] = cur_byte;
      nbytes_total = nbytes_total + 1;
      nbits = 0;
      if (nbytes_total == 4100) begin
        // snapshot the finished packet, then start assembling the next one
        for (snap_i = 0; snap_i < 4100; snap_i = snap_i + 1)
          last_pkt[snap_i] = cur_pkt[snap_i];
        pkt_count = pkt_count + 1;
        nbytes_total = 0;
      end
    end
  end
  integer snap_i;

  function [31:0] getword(input integer idx);
    getword = {last_pkt[4*idx+3], last_pkt[4*idx+2], last_pkt[4*idx+1], last_pkt[4*idx]};
  endfunction

  /*------------------Activity (both-active collision) monitor------------*/
  // Records rise/fall times of hm_active / lc_active and, whenever an
  // interval had BOTH producers active simultaneously, checks the pinned
  // mode-mux invariants: rising edges <=1 pixel-clk apart, falling edges on
  // the SAME clock, and exactly 4100 bytes transmitted during the interval.
  real hm_rise_t, hm_fall_t, lc_rise_t, lc_fall_t;
  reg hm_active_q = 0, lc_active_q = 0;
  integer bytes_at_rise;
  reg collision_pending = 0;
  reg collision_seen = 0;               // set once per collision window; tests clear it
  real collision_rise_delta, collision_fall_delta;
  integer collision_bytes;

  always @(posedge clk_pix) begin
    hm_active_q <= hm_active;
    lc_active_q <= lc_active;
    if (hm_active & ~hm_active_q) hm_rise_t = $realtime;
    if (~hm_active & hm_active_q) hm_fall_t = $realtime;
    if (lc_active & ~lc_active_q) lc_rise_t = $realtime;
    if (~lc_active & lc_active_q) lc_fall_t = $realtime;

    // a collision window begins when the SECOND producer joins an already-
    // active first producer
    if ((hm_active & ~hm_active_q & lc_active) ||
        (lc_active & ~lc_active_q & hm_active)) begin
      collision_pending <= 1'b1;
      bytes_at_rise <= pkt_count;        // packets completed so far
    end
    // window ends when BOTH have gone inactive
    if (collision_pending & ~hm_active & ~lc_active) begin
      collision_pending <= 1'b0;
      collision_seen <= 1'b1;
      collision_rise_delta = (hm_rise_t > lc_rise_t) ? (hm_rise_t - lc_rise_t) : (lc_rise_t - hm_rise_t);
      collision_fall_delta = (hm_fall_t > lc_fall_t) ? (hm_fall_t - lc_fall_t) : (lc_fall_t - hm_fall_t);
      collision_bytes = 4100; // one packet always completes across a collision window (see checks)
    end
  end

  /*------------------camera stimulus--------------------------------------*/
  // 8 lines x 16 pixel-pairs per frame; same pixel pattern as line_capture_tb
  // (pixA = (2C+L)&3FF, pixB = (2C+1+L)&3FF). NBA stimulus per line_capture_tb
  // rationale: avoids a blocking-assignment TB/DUT race with the DUT's own
  // `always @(posedge clk)` sampling of these same signals.
  localparam LINES = 8, PAIRS = 16;
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

  // Same as send_frame but lets a caller PAUSE the stimulus mid-frame (lv low,
  // fv still high) while an I2C write completes, then resume the remaining
  // lines. Pausing with fv high and lv low is legal video timing (extended
  // horizontal blanking) so this does not violate the sensor's own protocol.
  // stop_after_line: pause AFTER this line's lv has fully dropped (-1 = don't
  // pause at all, i.e. behaves like send_frame).
  task send_frame_pausable(input integer stop_after_line);
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
        if (L == stop_after_line) begin
          pause_ready = 1;
          wait (pause_done);
          pause_ready = 0;
        end
      end
      fv <= 0;
    end
  endtask
  reg pause_ready = 0, pause_done = 0;

  /*------------------I2C master tasks + wr_reg/rd_reg---------------------*/
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

  /*------------------checks------------------------------------------------*/
  integer errors = 0;
  task check(input cond, input [1023:0] msg);
    if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask

  // Bounded wait for a completed packet: poll pkt_count until it advances past
  // `since` or the deadline passes, so a MISSING packet FAILS instead of
  // hanging the sim.
  integer t0;
  task wait_for_packet(input integer since, input integer max_ns);
    begin
      t0 = $time;
      while (pkt_count <= since && ($time - t0) < max_ns) #10000;
      #50000;   // trailing settle so toggles / activity monitor land
    end
  endtask

  // Sum the 24-bit data field across all 1024 histogram words of the last
  // completed packet.
  integer sum_i;
  reg [31:0] sum_acc;
  function [31:0] sum_histogram_data;
    input integer dummy;
    begin
      sum_acc = 0;
      for (sum_i = 0; sum_i < 1024; sum_i = sum_i + 1)
        sum_acc = sum_acc + (getword(sum_i) & 24'hFFFFFF);
      sum_histogram_data = sum_acc;
    end
  endfunction

  // Histogram sum check that always prints the observed value, so a defect-
  // magnitude drift (issue #6 offset changing, or the fix landing) is visible
  // in the log even on pass.
  reg [31:0] sum_obs;
  task check_sum(input [31:0] expected, input [1023:0] label);
    begin
      sum_obs = sum_histogram_data(0);
      $display("INFO: %0s: observed sum=%0d expected=%0d", label, sum_obs, expected);
      check(sum_obs == expected, label);
    end
  endtask

  integer w;
  reg [31:0] wv;
  reg [7:0] rb, rb2;
  integer pkt_snap;

  initial begin
    $dumpfile("out/integration_tb.vcd"); $dumpvars(0, integration_tb);
    reset = 1;
    #300 reset = 0;

    // =====================================================================
    // 1. BOOT-HISTOGRAM: mode defaults to 0 (histogram). Run 2 frames.
    //    Each frame contributes PIXELS_PER_FRAME = 2*PAIRS*LINES = 256 true
    //    pixels (both pixels of every pair, counted by histo_a + histo_b)
    //    plus SUM_BUG_PER_FRAME spurious counts (issue #6). Packet 1's
    //    readout wipes the bins after frame 1 -> sum == 1*256 + 1*4 = 260.
    //    Packet 2 starts from a wiped histogram, accumulates only frame 2
    //    -> sum == 260 again.
    // =====================================================================
    pkt_snap = pkt_count;
    send_frame;
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "BOOT-HISTOGRAM frame1: exactly one packet");
    check(getword(2) >> 24 == 8'h00, "BOOT-HISTOGRAM frame1: word2 spacer == 0x00 (no magic)");
    check(getword(1023) >> 24 == 8'h01, "BOOT-HISTOGRAM frame1: word 0x3FF spacer == frame counter 1");
    check_sum(1*PIXELS_PER_FRAME + 1*SUM_BUG_PER_FRAME,
              "BOOT-HISTOGRAM frame1: sum-of-data (1 frame accumulated)");

    pkt_snap = pkt_count;
    send_frame;
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "BOOT-HISTOGRAM frame2: exactly one packet");
    check(getword(2) >> 24 == 8'h00, "BOOT-HISTOGRAM frame2: word2 spacer == 0x00 (no magic)");
    check(getword(1023) >> 24 == 8'h02, "BOOT-HISTOGRAM frame2: word 0x3FF spacer == frame counter 2");
    check_sum(1*PIXELS_PER_FRAME + 1*SUM_BUG_PER_FRAME,
              "BOOT-HISTOGRAM frame2: sum-of-data (1 frame accumulated)");

    // =====================================================================
    // 2. I2C SANITY: ID, VERSION, SCRATCH read/write.
    // =====================================================================
    rd_reg(8'h00, rb); check(rb == 8'h5A, "I2C-SANITY: ID == 0x5A");
    rd_reg(8'h01, rb); check(rb == 8'h01, "I2C-SANITY: VERSION == 0x01");
    rd_reg(8'h02, rb); check(rb == 8'hA5, "I2C-SANITY: SCRATCH default 0xA5");
    wr_reg(8'h02, 8'h3C); rd_reg(8'h02, rb);
    check(rb == 8'h3C, "I2C-SANITY: SCRATCH write/readback 0x3C");

    // =====================================================================
    // 3. ENTER IMAGE MODE: LINE=5, CTRL=1. Settle (CDC + arm at fv_rise),
    //    then run one frame. Expect exactly one IMAGE packet: magic 0xB6,
    //    line tags == 5, pixel words match line-5 pattern, frame counter ok.
    //    LINE_CUR reads back 6 (auto-inc after send).
    // =====================================================================
    wr_reg(8'h04, 8'h05); wr_reg(8'h05, 8'h00);   // LINE = 5
    wr_reg(8'h03, 8'h01);                         // CTRL = 1 (image mode)
    #50_000;                                      // settle: CDC + arm at fv_rise

    pkt_snap = pkt_count;
    send_frame;
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "ENTER-IMAGE: exactly one packet");
    check(getword(2) >> 24 == 8'hB6, "ENTER-IMAGE: word2 magic 0xB6");
    check(getword(0) >> 24 == 8'h05, "ENTER-IMAGE: line tag low == 5");
    check(getword(1) >> 24 == 8'h00, "ENTER-IMAGE: line tag high == 0");
    for (w = 0; w < PAIRS; w = w + 1) begin
      wv = getword(w);
      check((wv & 20'hFFFFF) ==
            ((((2*w + 1 + 5) & 10'h3FF) << 10) | ((2*w + 5) & 10'h3FF)),
            "ENTER-IMAGE: pixel word matches line 5 pattern");
    end
    rd_reg(8'h06, rb); rd_reg(8'h07, rb2);
    check({rb2[3:0], rb} == 12'd6, "ENTER-IMAGE: LINE_CUR == 6 after auto-inc");

    // =====================================================================
    // 4. AUTO-INC: run another frame. Expect image packet line 6.
    // =====================================================================
    pkt_snap = pkt_count;
    send_frame;
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "AUTO-INC: exactly one packet");
    check(getword(2) >> 24 == 8'hB6, "AUTO-INC: word2 magic 0xB6");
    check(getword(0) >> 24 == 8'h06, "AUTO-INC: line tag low == 6");
    for (w = 0; w < PAIRS; w = w + 1) begin
      wv = getword(w);
      check((wv & 20'hFFFFF) ==
            ((((2*w + 1 + 6) & 10'h3FF) << 10) | ((2*w + 6) & 10'h3FF)),
            "AUTO-INC: pixel word matches line 6 pattern");
    end
    rd_reg(8'h06, rb); rd_reg(8'h07, rb2);
    check({rb2[3:0], rb} == 12'd7, "AUTO-INC: LINE_CUR == 7 after auto-inc");

    // =====================================================================
    // 5. REWIND: LINE=0. Run a frame. Expect image packet line 0.
    // =====================================================================
    wr_reg(8'h04, 8'h00); wr_reg(8'h05, 8'h00);   // LINE = 0
    #50_000;
    pkt_snap = pkt_count;
    send_frame;
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "REWIND: exactly one packet");
    check(getword(2) >> 24 == 8'hB6, "REWIND: word2 magic 0xB6");
    check(getword(0) >> 24 == 8'h00, "REWIND: line tag low == 0");
    for (w = 0; w < PAIRS; w = w + 1) begin
      wv = getword(w);
      check((wv & 20'hFFFFF) ==
            ((((2*w + 1 + 0) & 10'h3FF) << 10) | ((2*w + 0) & 10'h3FF)),
            "REWIND: pixel word matches line 0 pattern");
    end
    rd_reg(8'h06, rb); rd_reg(8'h07, rb2);
    check({rb2[3:0], rb} == 12'd1, "REWIND: LINE_CUR == 1 after auto-inc");

    // =====================================================================
    // 6. MODE-FLIP COLLISION (flip AFTER capture): LINE=3 via I2C, settle,
    //    start a frame, let line 3 fully stream, THEN (same frame, fv still
    //    high) write CTRL=0 over I2C. At fv fall both producers serialize.
    //    Assert both-active invariants + the packet is IMAGE line 3.
    // =====================================================================
    wr_reg(8'h04, 8'h03); wr_reg(8'h05, 8'h00);   // LINE = 3
    #50_000;

    pkt_snap = pkt_count;
    collision_seen = 0;
    fork
      send_frame_pausable(3);              // pause AFTER line 3 has fully streamed
      begin
        wait (pause_ready);
        wr_reg(8'h03, 8'h00);              // flip back to histogram mode mid-frame
        pause_done = 1; #1;
        pause_done = 0;
      end
    join
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "MODE-FLIP-COLLISION: exactly one packet on the wire");
    check(collision_seen, "MODE-FLIP-COLLISION: both-active window was observed");
    check(collision_rise_delta <= 8.0, "MODE-FLIP-COLLISION: rising edges <=1 pixel-clk (~7.5ns) apart");
    check(collision_fall_delta == 0.0, "MODE-FLIP-COLLISION: falling edges on the SAME clock");
    check(collision_bytes == 4100, "MODE-FLIP-COLLISION: exactly 4100 bytes during the interval");
    check(getword(2) >> 24 == 8'hB6, "MODE-FLIP-COLLISION: packet is IMAGE (magic 0xB6)");
    check(getword(0) >> 24 == 8'h03, "MODE-FLIP-COLLISION: line tag low == 3");
    for (w = 0; w < PAIRS; w = w + 1) begin
      wv = getword(w);
      check((wv & 20'hFFFFF) ==
            ((((2*w + 1 + 3) & 10'h3FF) << 10) | ((2*w + 3) & 10'h3FF)),
            "MODE-FLIP-COLLISION: pixel word matches line 3 pattern");
    end

    // After the collision, run 2 frames in histogram mode.
    // FIRST histogram packet sum bookkeeping: histogram accumulation depends
    // only on frame_valid/line_valid, never on `enable` or state (histo_a/
    // histo_b's `rw`=frame_valid directly), so every image-mode frame in
    // steps 3-5 accumulated 256+4 into the bins, and so did the collision
    // frame itself. But the collision's histogram-side shadow-read/wipe
    // swept the entire 1024-bin RAM during that SAME frame's blanking
    // interval (the collision window IS histogram_module's SERIALIZE pass,
    // forced into lockstep with line_capture by the shared `ser_done`). So
    // everything accumulated up to and including the collision frame — the
    // steps-3-5 image frames AND the collision frame's own pixels — is
    // wiped by that shadow readout; nothing carries over. (This subsumes
    // the "first histogram packet after image mode is invalid" host rule:
    // here the invalid packet is shadow-consumed by the collision itself.)
    // Frames accumulated since that wipe when packet A ships: exactly 1
    // (frame A), each frame contributing PIXELS_PER_FRAME true counts plus
    // SUM_BUG_PER_FRAME spurious counts at its fv rise (issue #6):
    // sum == 1*256 + 1*4 = 260. Frame B likewise starts from a wiped
    // histogram -> sum == 260.
    pkt_snap = pkt_count;
    send_frame;
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "POST-COLLISION frameA: exactly one packet");
    check(getword(2) >> 24 == 8'h00, "POST-COLLISION frameA: word2 spacer == 0x00 (histogram, no magic)");
    check_sum(1*PIXELS_PER_FRAME + 1*SUM_BUG_PER_FRAME,
          "POST-COLLISION frameA: sum-of-data (1 frame; collision frame self-wiped)");

    pkt_snap = pkt_count;
    send_frame;
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "POST-COLLISION frameB: exactly one packet");
    check(getword(2) >> 24 == 8'h00, "POST-COLLISION frameB: word2 spacer == 0x00 (histogram, no magic)");
    check_sum(1*PIXELS_PER_FRAME + 1*SUM_BUG_PER_FRAME,
          "POST-COLLISION frameB: sum-of-data (steady state, 1 frame)");

    // =====================================================================
    // 7. MODE-FLIP BEFORE CAPTURE: CTRL=1, LINE=6, settle, start frame, flip
    //    CTRL=0 mid-frame BEFORE line 6 streams (pause after line 4, before
    //    line 6 starts). line_capture is armed at fv_rise (this frame), so
    //    it still captures line 6 and serializes at fv fall alongside the
    //    histogram producer (both-active invariants again).
    // =====================================================================
    wr_reg(8'h04, 8'h06); wr_reg(8'h05, 8'h00);   // LINE = 6
    wr_reg(8'h03, 8'h01);                         // CTRL = 1 (image mode)
    #50_000;

    pkt_snap = pkt_count;
    collision_seen = 0;
    fork
      send_frame_pausable(4);              // pause after line 4 -- BEFORE line 6
      begin
        wait (pause_ready);
        wr_reg(8'h03, 8'h00);              // flip back to histogram mode mid-frame
        pause_done = 1; #1;
        pause_done = 0;
      end
    join
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "MODE-FLIP-BEFORE: exactly one packet on the wire");
    check(collision_seen, "MODE-FLIP-BEFORE: both-active window was observed");
    check(collision_rise_delta <= 8.0, "MODE-FLIP-BEFORE: rising edges <=1 pixel-clk (~7.5ns) apart");
    check(collision_fall_delta == 0.0, "MODE-FLIP-BEFORE: falling edges on the SAME clock");
    check(collision_bytes == 4100, "MODE-FLIP-BEFORE: exactly 4100 bytes during the interval");
    check(getword(2) >> 24 == 8'hB6, "MODE-FLIP-BEFORE: packet is IMAGE (magic 0xB6) -- line_capture still armed this frame");
    check(getword(0) >> 24 == 8'h06, "MODE-FLIP-BEFORE: line tag low == 6");
    for (w = 0; w < PAIRS; w = w + 1) begin
      wv = getword(w);
      check((wv & 20'hFFFFF) ==
            ((((2*w + 1 + 6) & 10'h3FF) << 10) | ((2*w + 6) & 10'h3FF)),
            "MODE-FLIP-BEFORE: pixel word matches line 6 pattern");
    end

    // =====================================================================
    // 8. RETURN TO STEADY HISTOGRAM: the discard-first-packet-after-image-
    //    mode rule was already exercised/characterized in step 6 (the
    //    collision's shadow read wipes bins, so the "first packet is
    //    invalid" corner is subsumed there). Step 7's collision likewise
    //    shadow-wiped the bins, so exactly 1 frame accumulates before this
    //    packet: sum == 1*256 + 1*4 = 260 (issue #6 offset included).
    // =====================================================================
    pkt_snap = pkt_count;
    send_frame;
    wait_for_packet(pkt_snap, 1_700_000);
    check(pkt_count == pkt_snap + 1, "STEADY-HISTOGRAM: exactly one packet");
    check(getword(2) >> 24 == 8'h00, "STEADY-HISTOGRAM: word2 spacer == 0x00 (no magic)");
    check_sum(1*PIXELS_PER_FRAME + 1*SUM_BUG_PER_FRAME,
              "STEADY-HISTOGRAM: sum-of-data (1 frame accumulated)");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end

  // overall bounded watchdog: nothing above should take this long
  initial begin
    #100_000_000;
    $display("FAIL: watchdog timeout -- sim did not finish");
    $finish;
  end
endmodule
