// Self-checking testbench for histogram_module (histo_module.v + histo_calc.v +
// histo_serializer.v + spi_master.v + Lattice ram_dp_s / DP8KE model).
//
// Requirements checked (from the design intent and the MCU contract in
// openmotion-sensor-fw: common.h SPI_PACKET_LENGTH=4100, camera_manager.c reads
// the frame id from byte 4095, SPI slave samples on rising SCLK, LSB first):
//   R1  One packet of exactly 4100 bytes (1025 x 32-bit words) per reported
//       frame, packets in frame order, no SPI activity otherwise.
//   R2  Word i (i = 0..1023), bits [23:0] = number of pixels with value i that
//       were presented while frame_valid && line_valid, both lanes summed.
//   R3  Word 1023 bits [31:24] = frame id = number of frame_valid falls since
//       reset (mod 256), counted or dropped; bits [31:24] of words 0..1022 = 0.
//   R4  Each frame's histogram is independent of every earlier frame.
//   R5  Pixel-bus contents outside frame_valid && line_valid are never counted.
//   R6  MOSI is stable for at least one fast clock before each rising SCLK.
//   R7  A frame that starts while the previous packet is still being sent is
//       counted completely and sent, correctly, after that packet.
//   R8  A frame that starts while both banks hold unsent data is dropped
//       whole (no packet); later frames are unaffected.
//   R9  After a reset (including one in the middle of a packet) no stale
//       counts survive; a frame that starts during the post-reset scrub is
//       dropped.
//   Word 1024 is a trailing word the MCU discards; it is logged if non-zero.
//
// Plusargs:  +seed=N    random seed (default 1729)
//            +frames=N  run only the first N single-frame tests (R7-R9 tests
//                       still run unless +no_overlap)
//            +no_overlap skip the R7-R9 scenario tests
`timescale 1ns/1ps
`default_nettype none

module tb_histogram_module;

  // Lattice global set/reset nets referenced hierarchically by DP8KE.
  GSR GSR_INST (.GSR(1'b1));
  PUR PUR_INST (.PUR(1'b1));

  // clk_pixel_hs = 132.8 MHz in hardware.
  localparam real CLK_PERIOD  = 7.53;
  localparam int  NBINS       = 1024;
  localparam int  PKT_BYTES   = 4100;
  localparam int  SCRUB_WAIT  = 1200;   // clocks after reset before frames are accepted (spec: ~1030)

  logic        clk = 1'b0;
  logic        reset;
  logic [19:0] pixel_data;
  logic        frame_valid;
  logic        line_valid;
  wire         spi_mosi, spi_clk;

  always #(CLK_PERIOD/2) clk = ~clk;

  histogram_module dut (
    .clk         (clk),
    .reset       (reset),
    .pixel_data  (pixel_data),
    .frame_valid (frame_valid),
    .line_valid  (line_valid),
    .spi_clk_i   (clk),
    .spi_mosi_o  (spi_mosi),
    .spi_clk_o   (spi_clk),
    .spi_en      (1'b1),
    .debug       (),
    .debug2      ()
  );

  // ------------------------------------------------------------------
  // SPI receiver: models the MCU slave (samples MOSI on rising SCLK,
  // LSB first).  Mode 0 vs the MCU's mode 3 both sample on the rising edge.
  // ------------------------------------------------------------------
  logic [7:0] rx_bytes [0:262143];
  int         rx_count = 0;
  int         bitpos   = 0;
  logic [7:0] shreg;
  realtime    last_mosi_change = 0;
  int         timing_errors = 0;

  always @(spi_mosi) last_mosi_change = $realtime;

  always @(posedge spi_clk) begin
    if ($realtime - last_mosi_change < CLK_PERIOD - 0.01) begin
      timing_errors++;
      if (timing_errors <= 5)
        $display("[%0t] R6 FAIL: MOSI changed %0.2f ns before SCLK rise",
                 $time, $realtime - last_mosi_change);
    end
    shreg[bitpos] = spi_mosi;
    if (bitpos == 7) begin
      rx_bytes[rx_count] = shreg;
      rx_count++;
      bitpos = 0;
    end else begin
      bitpos++;
    end
  end

  // ------------------------------------------------------------------
  // Reference model: plain per-bin counts of what the driver presented,
  // one table per frame "slot" so several frames can be in flight.
  // ------------------------------------------------------------------
  int expected [0:3][0:NBINS-1];
  int slot_fid [0:3];
  int seed;
  int errors = 0;
  int frames_done = 0;     // frame_valid falls since reset
  int last_pix_a, last_pix_b;
  int max_frames = 1000, frames_run = 0;

  // Pixel pattern generator state
  int run_left_a, run_left_b, run_val_a, run_val_b, ramp_idx;

  typedef enum int {PAT_RANDOM, PAT_RUNS, PAT_CONST, PAT_RAMP, PAT_ALT, PAT_NARROW} pat_t;
  typedef enum int {BUS_HOLD, BUS_ZERO, BUS_RANDOM} bus_t;

  function automatic int rnd(input int n);  // 0..n-1
    int r;
    r = $random(seed);
    if (r < 0) r = -r;
    return r % n;
  endfunction

  function automatic int next_pixel(input pat_t pat, input int lane, input int cval);
    int v;
    case (pat)
      PAT_RANDOM: v = rnd(NBINS);
      PAT_CONST:  v = cval;
      PAT_RAMP: begin v = ramp_idx % NBINS; ramp_idx++; end
      PAT_ALT:    v = (ramp_idx++ % 2) ? cval : (cval ^ 10'h2A5);
      PAT_NARROW: v = cval + rnd(3);                 // many p,q,p near-repeats
      PAT_RUNS: begin
        if (lane == 0) begin
          if (run_left_a == 0) begin run_left_a = 1 + rnd(24); run_val_a = rnd(NBINS); end
          run_left_a--; v = run_val_a;
        end else begin
          if (run_left_b == 0) begin run_left_b = 1 + rnd(24); run_val_b = rnd(NBINS); end
          run_left_b--; v = run_val_b;
        end
      end
      default: v = 0;
    endcase
    return v & 10'h3FF;
  endfunction

  // Drive one idle (not line valid) clock with the chosen bus behaviour.
  task automatic idle_clock(input bus_t bus, input logic fv);
    int ra, rb;
    ra = rnd(NBINS);
    rb = rnd(NBINS);
    @(negedge clk);
    frame_valid = fv;
    line_valid  = 1'b0;
    case (bus)
      BUS_ZERO:   pixel_data = 20'd0;
      BUS_RANDOM: pixel_data = {rb[9:0], ra[9:0]};
      default:    pixel_data = {last_pix_b[9:0], last_pix_a[9:0]};
    endcase
  endtask

  task automatic clear_slot(input int slot);
    for (int i = 0; i < NBINS; i++) expected[slot][i] = 0;
  endtask

  // Drive one frame into the reference table `slot`.
  //   front: clocks of fv high before the first lv (0 = lv rises with fv)
  //   back : clocks of fv high after the last lv  (0 = fv falls with lv)
  task automatic drive_frame(input int slot, input int lines, input int active,
                             input int hblank, input int front, input int back,
                             input pat_t pat, input int cval, input bus_t bus);
    int a, b;
    clear_slot(slot);
    run_left_a = 0; run_left_b = 0; ramp_idx = 0;
    for (int i = 0; i < front; i++) idle_clock(bus, 1'b1);
    for (int l = 0; l < lines; l++) begin
      for (int p = 0; p < active; p++) begin
        @(negedge clk);
        a = next_pixel(pat, 0, cval);
        b = next_pixel(pat, 1, cval);
        frame_valid = 1'b1;
        line_valid  = 1'b1;
        pixel_data  = {b[9:0], a[9:0]};
        last_pix_a  = a; last_pix_b = b;
        expected[slot][a]++; expected[slot][b]++;
      end
      if (l != lines-1)
        for (int h = 0; h < hblank; h++) idle_clock(bus, 1'b1);
    end
    for (int i = 0; i < back; i++) idle_clock(bus, 1'b1);
    idle_clock(bus, 1'b0);                     // frame_valid falls
    frames_done++;
    slot_fid[slot] = frames_done & 8'hFF;
  endtask

  // Wait for the packet that starts at byte `start_byte`, check it against
  // `slot`. With `quiet`, also require the link to stay silent afterwards.
  task automatic check_packet(input string name, input int start_byte,
                              input int slot, input bit quiet);
    int t, w, cnt, top, bad, cnt_err, top_err, exp_top;
    logic [31:0] word;
    t = 0;
    while (rx_count < start_byte + PKT_BYTES && t < 400_000) begin @(posedge clk); t++; end
    if (quiet) repeat (2000) @(posedge clk);
    if ((quiet && rx_count != start_byte + PKT_BYTES) || rx_count < start_byte + PKT_BYTES) begin
      $display("  R1 FAIL [%s]: received %0d bytes, expected %0d",
               name, rx_count - start_byte, PKT_BYTES);
      errors++;
    end else begin
      word = {rx_bytes[start_byte + 4*NBINS + 3], rx_bytes[start_byte + 4*NBINS + 2],
              rx_bytes[start_byte + 4*NBINS + 1], rx_bytes[start_byte + 4*NBINS + 0]};
      if (word != 0) $display("  info [%s]: trailing word 1024 = 0x%08h", name, word);
      bad = 0; cnt_err = 0; top_err = 0;
      for (w = 0; w < NBINS; w++) begin
        word = {rx_bytes[start_byte + 4*w + 3], rx_bytes[start_byte + 4*w + 2],
                rx_bytes[start_byte + 4*w + 1], rx_bytes[start_byte + 4*w + 0]};
        cnt = word[23:0];
        top = word[31:24];
        exp_top = (w == NBINS-1) ? slot_fid[slot] : 0;
        if (cnt != expected[slot][w]) begin
          cnt_err++;
          if (bad++ < 8)
            $display("  R2 FAIL [%s]: bin %0d count %0d, expected %0d", name, w, cnt, expected[slot][w]);
        end
        if (top != exp_top) begin
          top_err++;
          if (bad++ < 8)
            $display("  R3 FAIL [%s]: bin %0d top byte %0d, expected %0d", name, w, top, exp_top);
        end
      end
      errors += cnt_err + top_err;
      if (cnt_err + top_err == 0) $display("  PASS [%s]", name);
      else $display("  FAIL [%s]: %0d bad bin counts, %0d bad top bytes", name, cnt_err, top_err);
    end
    $fflush();
  endtask

  task automatic run_frame(input string name, input int lines, input int active,
                           input int hblank, input int front, input int back,
                           input pat_t pat, input int cval, input bus_t bus);
    int start;
    if (frames_run < max_frames) begin
      frames_run++;
      start = rx_count;
      repeat (50) idle_clock(bus, 1'b0);       // vertical blanking before the frame
      drive_frame(0, lines, active, hblank, front, back, pat, cval, bus);
      check_packet(name, start, 0, 1'b1);
    end
  endtask

  task automatic do_reset();
    @(negedge clk) reset = 1'b1;
    repeat (20) @(posedge clk);
    @(negedge clk) reset = 1'b0;
    bitpos = 0;                                // resynchronise the receiver
    frames_done = 0;                           // DUT frame counter restarts
  endtask

  // ------------------------------------------------------------------
  // R7: next frame starts right after the previous one (inside its push).
  task automatic test_overlap_two();
    int s;
    $display("R7 overlap: frame B starts 10 clocks after frame A ends");
    repeat (50) idle_clock(BUS_ZERO, 1'b0);
    s = rx_count;
    drive_frame(0, 8, 128, 46, 35, 35, PAT_RANDOM, 0, BUS_ZERO);
    repeat (10) idle_clock(BUS_ZERO, 1'b0);
    drive_frame(1, 8, 128, 46, 35, 35, PAT_RUNS, 0, BUS_ZERO);
    check_packet("overlap: A", s, 0, 1'b0);
    check_packet("overlap: B (counted during A's push)", s + PKT_BYTES, 1, 1'b1);
  endtask

  // R7 steady state: C starts after A's push ended but while B is being sent.
  task automatic test_overlap_steady();
    int s;
    $display("R7 steady state: A, B back to back, C during B's push");
    repeat (50) idle_clock(BUS_ZERO, 1'b0);
    s = rx_count;
    drive_frame(0, 8, 128, 46, 35, 35, PAT_RANDOM, 0, BUS_ZERO);
    repeat (10) idle_clock(BUS_ZERO, 1'b0);
    drive_frame(1, 8, 128, 46, 35, 35, PAT_NARROW, 10'h1F0, BUS_ZERO);
    repeat (165_000) idle_clock(BUS_ZERO, 1'b0);  // > one push (~152k clocks), < two
    drive_frame(2, 8, 128, 46, 35, 35, PAT_RAMP, 0, BUS_ZERO);
    check_packet("steady: A", s, 0, 1'b0);
    check_packet("steady: B", s + PKT_BYTES, 1, 1'b0);
    check_packet("steady: C (bank freed by A)", s + 2*PKT_BYTES, 2, 1'b1);
  endtask

  // R8: three frames inside one push -> the third has no free bank.
  task automatic test_overlap_drop();
    int s;
    $display("R8 drop: A, B, C back to back; C must be dropped, D after must be clean");
    repeat (50) idle_clock(BUS_ZERO, 1'b0);
    s = rx_count;
    drive_frame(0, 8, 128, 46, 35, 35, PAT_RANDOM, 0, BUS_ZERO);
    repeat (10) idle_clock(BUS_ZERO, 1'b0);
    drive_frame(1, 8, 128, 46, 35, 35, PAT_RANDOM, 0, BUS_ZERO);
    repeat (10) idle_clock(BUS_ZERO, 1'b0);
    drive_frame(3, 8, 128, 46, 35, 35, PAT_CONST, 10'h2AA, BUS_ZERO);   // dropped
    check_packet("drop: A", s, 0, 1'b0);
    check_packet("drop: B (C dropped, no third packet)", s + PKT_BYTES, 1, 1'b1);
    run_frame("drop: D after drop (frame id skips C)", 8, 128, 46, 35, 35, PAT_RANDOM, 0, BUS_ZERO);
  endtask

  // R9: reset in the middle of a push, then a frame during the scrub.
  task automatic test_reset_mid_push();
    int s;
    $display("R9 reset: reset half way through a push, frame during scrub dropped, next frame clean");
    repeat (50) idle_clock(BUS_ZERO, 1'b0);
    s = rx_count;
    drive_frame(0, 8, 128, 46, 35, 35, PAT_CONST, 10'h123, BUS_ZERO);
    while (rx_count < s + PKT_BYTES/2) @(posedge clk);
    do_reset();
    drive_frame(3, 8, 128, 46, 35, 35, PAT_RANDOM, 0, BUS_ZERO);       // during scrub: dropped
    s = rx_count;
    repeat (2000) @(posedge clk);
    if (rx_count != s) begin
      $display("  R9 FAIL: %0d bytes sent for a frame that started during the scrub", rx_count - s);
      errors++;
    end
    // Bin 0x123 was not yet read out when reset hit: it must not leak.
    run_frame("reset: first frame after reset", 8, 128, 46, 35, 35, PAT_RANDOM, 0, BUS_ZERO);
  endtask

  // ------------------------------------------------------------------
  initial begin
    if (!$value$plusargs("seed=%d", seed)) seed = 1729;
    if (!$value$plusargs("frames=%d", max_frames)) max_frames = 1000;
    if ($test$plusargs("vcd")) begin
      $dumpfile("tb_histogram_module.vcd");
      $dumpvars(1, tb_histogram_module);
    end

    reset = 1'b1; frame_valid = 1'b0; line_valid = 1'b0; pixel_data = 20'd0;
    last_pix_a = 0; last_pix_b = 0;
    repeat (20) @(posedge clk);
    @(negedge clk) reset = 1'b0;
    repeat (SCRUB_WAIT) @(posedge clk);
    if (rx_count != 0) begin $display("R1 FAIL: SPI activity before first frame"); errors++; end

    //        name                      lines act hbl  fr  bk  pattern     cval    bus
    run_frame("random",                    8, 128, 16,  5,  5, PAT_RANDOM, 0,      BUS_HOLD);
    run_frame("runs (repeat path)",        8, 128, 16,  5,  5, PAT_RUNS,   0,      BUS_HOLD);
    run_frame("alternating p,q",           8, 128, 16,  5,  5, PAT_ALT,    10'h0F0,BUS_HOLD);
    run_frame("narrow p,q,p",              8, 128, 16,  5,  5, PAT_NARROW, 10'h200,BUS_HOLD);
    run_frame("ramp, every bin hit",       8, 128, 16,  5,  5, PAT_RAMP,   0,      BUS_HOLD);
    run_frame("const 0x155 (long run)",    8, 128, 16,  5,  5, PAT_CONST,  10'h155,BUS_HOLD);
    run_frame("const 0x000 (black)",       8, 128, 16,  5,  5, PAT_CONST,  10'h000,BUS_HOLD);
    run_frame("const 0x3FF (saturated)",   8, 128, 16,  5,  5, PAT_CONST,  10'h3FF,BUS_HOLD);
    run_frame("random, back-to-back #2",   8, 128, 16,  5,  5, PAT_RANDOM, 0,      BUS_HOLD);
    run_frame("fv/lv edges coincide",      8, 128, 16,  0,  0, PAT_RANDOM, 0,      BUS_HOLD);
    run_frame("byte2pixel-like timing",    8, 128, 46, 35, 35, PAT_RANDOM, 0,      BUS_ZERO);
    run_frame("blank bus zero, fr=1",      8, 128, 16,  1,  5, PAT_RANDOM, 0,      BUS_ZERO);
    run_frame("blank bus random, fr=1",    8, 128, 16,  1,  5, PAT_RANDOM, 0,      BUS_RANDOM);
    run_frame("blank bus random, fr=3",    8, 128, 16,  3,  5, PAT_RANDOM, 0,      BUS_RANDOM);
    run_frame("blank bus random, fr=10",   8, 128, 16, 10,  5, PAT_RANDOM, 0,      BUS_RANDOM);
    run_frame("blank bus random, bk=0",    8, 128, 16,  5,  0, PAT_RANDOM, 0,      BUS_RANDOM);

    if (!$test$plusargs("no_overlap")) begin
      test_overlap_two();
      test_overlap_steady();
      test_overlap_drop();
      test_reset_mid_push();
    end

    if (timing_errors) errors += timing_errors;
    if (errors == 0) begin $display("PASS"); $finish; end
    else begin $display("FAIL: %0d errors", errors); $fatal(1); end
  end

  initial begin
    #400ms;
    $display("FAIL: timeout");
    $fatal(1);
  end

endmodule

`default_nettype wire
