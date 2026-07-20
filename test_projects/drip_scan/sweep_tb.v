`timescale 1ns / 1ps
// sweep_tb.v — line_capture sweep mode: start-line gating, ping/pong
// handoff, overrun tripwire (drop + sticky latch + header flag), latch
// clear on a retry-style re-arm publish (no disarmed frame) and on the
// disarmed->armed arm edge. Byte-exact payloads are image_pusher_tb's and
// the sweep integration TB's job; here headers + CRC self-consistency +
// push accounting are asserted.
`include "../HistoFPGAFw/crc16.v"
`include "../HistoFPGAFw/raw10_pack.v"
`include "../HistoFPGAFw/image_pusher.v"
`include "../HistoFPGAFw/line_capture.v"
`include "../HistoFPGAFw/histo_serializer.v"
`include "../HistoFPGAFw/spi_master.v"
`include "i2c_line/ram_dp_s_beh.v"

module sweep_tb;
  reg clk = 0; always #3.75 clk = ~clk;
  reg reset = 1;

  localparam LINES = 8, PAIRS = 16;
  localparam PUSH_BYTES = 2408;

  reg fv = 0, lv = 0;
  reg [19:0] pd = 0;
  integer L, C;

  // CDC: TB plays the fpga_regs side (line=2, sweep=1 delivered together)
  reg [11:0] line_value = 12'd2;
  reg sweep_value = 1'b1;
  reg line_req = 0;
  reg enable = 1'b1;
  wire line_ack, line_sent;
  wire [11:0] sent_line;
  wire img_active, overrun;
  wire ser_done, ser_active;
  wire [31:0] word;

  line_capture dut (
    .clk(clk), .reset(reset), .enable(enable),
    .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
    .line_value_i(line_value), .sweep_value_i(sweep_value),
    .line_req_toggle_i(line_req),
    .line_ack_toggle_o(line_ack), .line_sent_toggle_o(line_sent),
    .sent_line_o(sent_line), .img_active_o(img_active),
    .overrun_o(overrun),
    .serializer_done(ser_done), .word_o(word),
    .serialize_active_o(ser_active));

  wire spi_clk, spi_mosi;
  Serializer ser (
    .fast_clk_in(clk), .reset(reset | ~ser_active), .data_in(word),
    .serial_out(spi_mosi), .slow_clk_out(spi_clk), .done(ser_done), .debug());

  // flat byte-stream monitor (LSB-first)
  reg [7:0] cur; integer nbits = 0;
  integer bytes_lifetime = 0;
  reg [7:0] wire_bytes [0:65535];
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
    if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
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

  // stimulus: 8 lines x 16 pairs, pixA=(2C+L)&3FF pixB=(2C+1+L)&3FF (NBA
  // per line_capture_tb rationale). send_frame = realistic short blanking
  // (overrun by construction: drain ~687us >> line ~1us). send_frame_paced
  // waits out any drain after each line = the stretched-HTS sweep timing.
  task send_frame;
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
      end
      fv <= 0;
    end
  endtask
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
        repeat (40) @(posedge clk);       // push starts well inside this
        tp = $time;
        while (ser_active && ($time - tp) < 1_500_000) #5000;
        #10000;
      end
      fv <= 0;
    end
  endtask

  // header + CRC-self-consistency check for one push
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
  reg [15:0] ecrc; integer eb; reg hok;
  task check_push_hdr(input integer base, input [11:0] eline,
                      input [7:0] eframe, input [3:0] eflags,
                      input [1023:0] label);
    begin
      hok = (wire_bytes[base+0] === 8'hB6) && (wire_bytes[base+1] === 8'h01) &&
            (wire_bytes[base+2] === eline[7:0]) &&
            (wire_bytes[base+3] === {eflags, eline[11:8]}) &&
            (wire_bytes[base+4] === eframe) && (wire_bytes[base+5] === 8'h00);
      if (!hok)
        $display("  header got %02x %02x %02x %02x %02x %02x (want line=%0d frame=%0d flags=%h)",
                 wire_bytes[base+0], wire_bytes[base+1], wire_bytes[base+2],
                 wire_bytes[base+3], wire_bytes[base+4], wire_bytes[base+5],
                 eline, eframe, eflags);
      check(hok, label);
      ecrc = 16'hFFFF;
      for (eb = 0; eb < 2406; eb = eb + 1)
        ecrc = crc16_ref(ecrc, wire_bytes[base+eb]);
      check({wire_bytes[base+2406], wire_bytes[base+2407]} === ecrc, label);
    end
  endtask

  // payload head spot-check: first 5 RAW10 bytes (= first 2 pixel pairs) of
  // a push must be the line's actual pixels. Full byte-exactness stays
  // image_pusher_tb's / the sweep integration TB's job; this narrow check
  // exists because the pusher fetches pair 0 during its header-build window
  // (BEFORE serialize_active_o rises), so a buffer read-address mux keyed on
  // the wrong signal feeds pair 0 from a stale address — invisible to the
  // header+CRC checks (the CRC folds whatever bytes were pushed).
  reg [9:0] pa0, pb0, pa1, pb1;
  reg [39:0] grp;
  reg [7:0] pwant;
  integer pbi;
  task check_push_payload_head(input integer pbase, input [11:0] eline,
                               input [1023:0] label);
    begin
      pa0 = eline;        pb0 = eline + 12'd1;   // pixA=(2C+L), pixB=(2C+1+L)
      pa1 = eline + 12'd2; pb1 = eline + 12'd3;  // for C=0,1 (L <= 7 here)
      grp = {pb1, pa1, pb0, pa0};                // little-endian RAW10 stream
      for (pbi = 0; pbi < 5; pbi = pbi + 1) begin
        pwant = grp >> (8*pbi);
        if (wire_bytes[pbase+6+pbi] !== pwant) begin
          errors = errors + 1;
          $display("FAIL: %0s payload[%0d] got %02x want %02x", label, pbi,
                   wire_bytes[pbase+6+pbi], pwant);
        end
      end
    end
  endtask

  integer base, k;
  initial begin
    $dumpfile("out/sweep_tb.vcd"); $dumpvars(0, sweep_tb);
    #100 reset = 0; #100;
    line_req = ~line_req; #500;          // deliver {line=2, sweep=1}
    check(line_ack == line_req, "CDC ack for {line=2, sweep=1}");

    // F1: paced sweep frame — lines 2..7 push, lines 0..1 do not
    base = bytes_lifetime;
    send_frame_paced;                    // frame_cnt = 1
    wait_total_bytes(base + 6*PUSH_BYTES, 6_000_000);
    check(bytes_lifetime == base + 6*PUSH_BYTES, "F1: exactly 6 pushes (start_line=2)");
    for (k = 0; k < 6; k = k + 1) begin
      check_push_hdr(base + k*PUSH_BYTES, 2+k, 8'd1, 4'h0, "F1: push header+CRC");
      check_push_payload_head(base + k*PUSH_BYTES, 2+k, "F1: payload head");
    end
    check(!overrun, "F1: no overrun");
    check(line_sent == 0, "sweep never toggles line_sent");

    // F2: overrun tripwire — short blanking, drain >> row time
    base = bytes_lifetime;
    send_frame;                          // frame_cnt = 2
    wait_total_bytes(base + PUSH_BYTES, 3_000_000);
    #200000;                             // settle: no further pushes may appear
    check(bytes_lifetime == base + PUSH_BYTES, "F2: exactly ONE push (rest dropped)");
    check_push_hdr(base, 12'd2, 8'd2, 4'h0, "F2: push is line 2, flags still 0");
    check(overrun, "F2: overrun latch set");

    // F3: latch propagates into header flag bit0 on later pushes
    base = bytes_lifetime;
    send_frame_paced;                    // frame_cnt = 3
    wait_total_bytes(base + 6*PUSH_BYTES, 6_000_000);
    check(bytes_lifetime == base + 6*PUSH_BYTES, "F3: 6 pushes while latched");
    for (k = 0; k < 6; k = k + 1)
      check_push_hdr(base + k*PUSH_BYTES, 2+k, 8'd3, 4'h1, "F3: header flag bit0 set");
    check(overrun, "F3: latch still set (no re-arm)");

    // F3R: retry-style re-arm — the host re-publishes {sweep=1, line=3}
    // (the first line dropped in F2) WITHOUT a disarmed frame, exactly the
    // SDK retry path. The latch must hold until the next frame boundary,
    // then clear: the retry's pushes carry flags=0.
    line_value = 12'd3; line_req = ~line_req; #500;
    check(line_ack == line_req, "F3R: CDC ack for re-arm publish");
    check(overrun, "F3R: latch holds until the next frame boundary");
    base = bytes_lifetime;
    send_frame_paced;                    // frame_cnt = 4
    wait_total_bytes(base + 5*PUSH_BYTES, 6_000_000);
    check(bytes_lifetime == base + 5*PUSH_BYTES, "F3R: 5 pushes (start_line=3)");
    for (k = 0; k < 5; k = k + 1)
      check_push_hdr(base + k*PUSH_BYTES, 3+k, 8'd4, 4'h0, "F3R: flags clear after re-arm publish");
    check(!overrun, "F3R: latch cleared at frame boundary");

    // F3R2: re-trip the latch (short blanking again) so F5 below proves the
    // disarmed->armed arm edge also clears a SET latch
    base = bytes_lifetime;
    send_frame;                          // frame_cnt = 5
    wait_total_bytes(base + PUSH_BYTES, 3_000_000);
    #200000;
    check(bytes_lifetime == base + PUSH_BYTES, "F3R2: exactly ONE push (rest dropped)");
    check_push_hdr(base, 12'd3, 8'd5, 4'h0, "F3R2: push is line 3, flags 0 (latch was clear)");
    check(overrun, "F3R2: overrun latch set again");

    // F4: disarm (image mode off, like the host exit path) — no pushes
    enable = 0;
    base = bytes_lifetime;
    send_frame;                          // frame_cnt = 6
    #300000;
    check(bytes_lifetime == base, "F4: disarmed frame produces nothing");
    check(overrun, "F4: latch survives a disarmed frame (sticky)");

    // F5: re-arm — arm edge clears the latch; pushes clean again
    enable = 1;
    base = bytes_lifetime;
    send_frame_paced;                    // frame_cnt = 7
    wait_total_bytes(base + 5*PUSH_BYTES, 6_000_000);
    check(bytes_lifetime == base + 5*PUSH_BYTES, "F5: 5 pushes after re-arm");
    for (k = 0; k < 5; k = k + 1)
      check_push_hdr(base + k*PUSH_BYTES, 3+k, 8'd7, 4'h0, "F5: flags clear after re-arm");
    check(!overrun, "F5: latch cleared on arm edge");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end

  initial begin
    #100_000_000;
    $display("FAIL: watchdog timeout");
    $finish;
  end
endmodule
