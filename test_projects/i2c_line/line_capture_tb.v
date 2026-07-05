`timescale 1ns / 1ps
`include "../HistoFPGAFw/line_capture.v"
`include "../HistoFPGAFw/histo_serializer.v"
`include "../HistoFPGAFw/spi_master.v"
`include "i2c_line/ram_dp_s_beh.v"

module line_capture_tb;
  reg clk = 0;                       // pixel clock ~133 MHz
  always #3.75 clk = ~clk;
  reg reset = 1;

  // stimulus: 8 lines x 16 pairs per frame
  localparam LINES = 8, PAIRS = 16;
  reg fv = 0, lv = 0;
  reg [19:0] pd = 0;
  integer L, C;
  // NOTE: all stimulus (fv/lv/pd) is driven with NON-BLOCKING assignments.
  // The DUT samples these same signals in its own `always @(posedge clk)`
  // blocks (and the behavioral RAM samples pixel_data on the identical
  // edge for a write). Driving them with blocking assignments from a
  // process triggered by the same `@(posedge clk)` is a classic Verilog
  // testbench/DUT race: whichever always-block the simulator happens to
  // run first in the Active region that timestep sees a different value,
  // silently duplicating/dropping samples. Non-blocking assignment defers
  // the update to the NBA region, guaranteeing every `always @(posedge
  // clk)` process in the design (this TB's included) observes the value
  // that was stable BEFORE this edge, and the new value is stable and
  // race-free for the entirety of the next clock period.
  task send_frame;
    begin
      fv <= 1; #400;
      for (L = 0; L < LINES; L = L + 1) begin
        @(posedge clk); lv <= 1;
        for (C = 0; C < PAIRS; C = C + 1) begin
          // pixA = 2C + L (10b), pixB = 2C + 1 + L (10b): unique, checkable
          pd <= ((((2*C + 1 + L) & 20'h3FF) << 10) | ((2*C + L) & 20'h3FF));
          @(posedge clk);
        end
        lv <= 0; pd <= 0;
        repeat (40) @(posedge clk);   // horizontal blanking
      end
      fv <= 0;
    end
  endtask

  // CDC: TB plays the fpga_regs side
  reg  [11:0] line_value = 12'd5;
  reg  line_req = 0;
  wire line_ack, line_sent;
  wire [11:0] sent_line;
  wire enable = 1'b1;

  wire ser_done;
  wire [31:0] word;
  wire ser_active;
  wire img_active;

  line_capture dut (
    .clk(clk), .reset(reset), .enable(enable),
    .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
    .line_value_i(line_value), .line_req_toggle_i(line_req),
    .line_ack_toggle_o(line_ack), .line_sent_toggle_o(line_sent),
    .sent_line_o(sent_line), .img_active_o(img_active),
    .serializer_done(ser_done), .word_o(word),
    .serialize_active_o(ser_active));

  wire spi_clk, spi_mosi;
  Serializer ser (
    .fast_clk_in(clk), .reset(reset | ~ser_active), .data_in(word),
    .serial_out(spi_mosi), .slow_clk_out(spi_clk), .done(ser_done), .debug());

  // SPI monitor: mode 0, LSB-first (matches SPI_Master modification)
  reg [7:0] cur; integer nbits = 0, nbytes = 0;
  reg [7:0] pkt [0:4099];
  always @(posedge spi_clk) begin
    cur = {spi_mosi, cur[7:1]};       // LSB first
    nbits = nbits + 1;
    if (nbits == 8) begin
      pkt[nbytes] = cur; nbytes = nbytes + 1; nbits = 0;
    end
  end

  integer errors = 0, w, sent_seen = 0;
  reg [31:0] wv;
  task check(input cond, input [255:0] msg);
    if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask
  function [31:0] getword(input integer idx);
    getword = {pkt[4*idx+3], pkt[4*idx+2], pkt[4*idx+1], pkt[4*idx]};
  endfunction

  // Count only post-reset toggles: line_sent_toggle_o is a reg with no
  // explicit initial value, so its reset assignment is an x->0 settling
  // transition in 4-state simulation, not a real "line sent" event (no
  // consumer is watching before reset releases in real hardware either).
  always @(line_sent) if (!reset) sent_seen = sent_seen + 1;

  initial begin
    $dumpfile("out/line_capture_tb.vcd"); $dumpvars(0, line_capture_tb);
    #100 reset = 0; #100;
    // deliver target line 5 over CDC
    line_req = ~line_req; #200;
    check(line_ack == line_req, "CDC ack");

    send_frame;                        // frame 1: capture line 5, then serialize
    wait (ser_active); wait (!ser_active); #2000;

    check(nbytes == 4100, "packet is 4100 bytes");
    // words 0..15 carry line-5 pixel pairs
    for (w = 0; w < PAIRS; w = w + 1) begin
      wv = getword(w);
      check((wv & 20'hFFFFF) ==
            ((((2*w + 1 + 5) & 10'h3FF) << 10) | ((2*w + 5) & 10'h3FF)),
            "pixel word");
    end
    // spacer metadata
    check(getword(0) >> 24 == 8'h05, "spacer0 = line low");
    check(getword(1) >> 24 == 8'h00, "spacer1 = line high");
    check(getword(2) >> 24 == 8'hB6, "spacer2 = magic");
    check(getword(1023) >> 24 == 8'h01, "spacer1023 = frame counter (frame 1)");
    // unwritten words are zero data
    check((getword(500) & 24'hFFFFFF) == 0, "unused words zero");
    check(sent_seen == 1, "one line_sent event");
    check(sent_line == 12'd5, "sent_line reports captured line");

    // no capture when target exceeds frame height: no new packet
    nbytes = 0;
    line_value = 12'd100; line_req = ~line_req; #500;
    send_frame; #200000;
    check(nbytes == 0, "no packet for out-of-range line");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end
endmodule
