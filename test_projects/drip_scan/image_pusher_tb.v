`timescale 1ns / 1ps
// image_pusher_tb.v — byte-exact 2408-B push through the REAL Serializer
// + SPI master. Pinned anchors (computed with the sensor-fw utils.c CRC
// table): for RAM pairs C<16 patterned pixA=(2C+5)&3FF pixB=(2C+6)&3FF,
// rest zero, header line=5 frame=1 flags=0:
//   payload[0..9]  = 05 18 70 00 02 09 28 B0 00 03
//   payload[35..40]= 21 88 30 02 09 00
//   CRC over bytes 0..2405 = 0x3C22 -> wire bytes 3C 22
`include "../HistoFPGAFw/crc16.v"
`include "../HistoFPGAFw/raw10_pack.v"
`include "../HistoFPGAFw/image_pusher.v"
`include "../HistoFPGAFw/histo_serializer.v"
`include "../HistoFPGAFw/spi_master.v"
`include "i2c_line/ram_dp_s_beh.v"

module image_pusher_tb;
  reg clk = 0; always #3.75 clk = ~clk;
  reg reset = 1;

  reg start = 0;
  reg [11:0] line = 12'd0;
  reg [7:0]  frame = 8'd0;
  reg ovr = 0;
  wire busy;
  wire [9:0] ram_addr;
  wire [23:0] ram_q;
  wire ser_done, ser_active;
  wire [31:0] word;

  image_pusher dut (
    .clk(clk), .reset(reset),
    .start_i(start), .line_i(line), .frame_i(frame), .ovr_flag_i(ovr),
    .busy_o(busy),
    .ram_addr_o(ram_addr), .ram_q_i(ram_q),
    .serializer_done(ser_done),
    .word_o(word), .serialize_active_o(ser_active));

  // sync-read line RAM (behavioral DP8KE stand-in); write port unused,
  // contents preloaded hierarchically below
  ram_dp_s line_ram (
    .Reset(reset),
    .RdClock(clk), .RdClockEn(1'b1), .RdAddress(ram_addr), .Q(ram_q),
    .WrClock(clk), .WrClockEn(1'b0), .WrAddress(10'd0),
    .Data(24'd0), .WE(1'b0));

  wire spi_clk, spi_mosi;
  Serializer ser (
    .fast_clk_in(clk), .reset(reset | ~ser_active), .data_in(word),
    .serial_out(spi_mosi), .slow_clk_out(spi_clk), .done(ser_done), .debug());

  // SPI monitor: LSB-first bytes into a flat stream
  reg [7:0] cur; integer nbits = 0;
  integer bytes_lifetime = 0;
  reg [7:0] wire_bytes [0:8191];
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
  integer t0;
  task wait_total_bytes(input integer target, input integer max_ns);
    begin
      t0 = $time;
      while (bytes_lifetime < target && ($time - t0) < max_ns) #10000;
      #50000;
    end
  endtask

  // ---- reference model ----
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
  reg [39:0] gval;
  reg [15:0] ecrc;
  integer ep, eb;
  task build_expected_push(input [11:0] hline, input [11:0] pline,
                           input [7:0] eframe, input [3:0] eflags);
    begin
      exp_push[0] = 8'hB6; exp_push[1] = 8'h01;
      exp_push[2] = hline[7:0];
      exp_push[3] = {eflags, hline[11:8]};
      exp_push[4] = eframe; exp_push[5] = 8'h00;
      for (ep = 0; ep < 480; ep = ep + 1) begin
        gval = {tb_pair(pline, 2*ep + 1), tb_pair(pline, 2*ep)};
        for (eb = 0; eb < 5; eb = eb + 1)
          exp_push[6 + 5*ep + eb] = gval >> (8*eb);
      end
      ecrc = 16'hFFFF;
      for (eb = 0; eb < 2406; eb = eb + 1)
        ecrc = crc16_ref(ecrc, exp_push[eb]);
      exp_push[2406] = ecrc[15:8];        // high byte first (uart_comms.c)
      exp_push[2407] = ecrc[7:0];
    end
  endtask
  integer ci, mism;
  task check_push(input integer base, input [11:0] hline, input [11:0] pline,
                  input [7:0] eframe, input [3:0] eflags,
                  input [1023:0] label);
    begin
      build_expected_push(hline, pline, eframe, eflags);
      mism = 0;
      for (ci = 0; ci < 2408; ci = ci + 1)
        if (wire_bytes[base+ci] !== exp_push[ci]) begin
          if (mism == 0)
            $display("  first mismatch at byte %0d: got %02x want %02x",
                     ci, wire_bytes[base+ci], exp_push[ci]);
          mism = mism + 1;
        end
      check(mism == 0, label);
    end
  endtask

  task do_start(input [11:0] l, input [7:0] f, input o);
    begin
      @(posedge clk);
      line <= l; frame <= f; ovr <= o; start <= 1;
      @(posedge clk);
      start <= 0;
    end
  endtask

  integer i, base;
  initial begin
    $dumpfile("out/image_pusher_tb.vcd"); $dumpvars(0, image_pusher_tb);
    for (i = 0; i < 1024; i = i + 1)
      line_ram.mem[i] = {4'b0, tb_pair(12'd5, i)};
    #100 reset = 0; #100;

    // ---- push 1: line=5 frame=1 flags=0 (pinned anchor vector) ----
    base = bytes_lifetime;
    do_start(12'd5, 8'd1, 1'b0);
    @(posedge clk);
    check(busy, "push1: busy during push");
    wait_total_bytes(base + 2408, 2_000_000);
    check(bytes_lifetime == base + 2408, "push1: exactly 2408 bytes");
    check(!busy, "push1: busy deasserts after drain");
    check(wire_bytes[base+0] == 8'hB6, "push1: [0] magic 0xB6");
    check(wire_bytes[base+1] == 8'h01, "push1: [1] format version 0x01");
    check(wire_bytes[base+2] == 8'h05, "push1: [2] line[7:0] == 5");
    check(wire_bytes[base+3] == 8'h00, "push1: [3] flags/line_h == 0x00");
    check(wire_bytes[base+4] == 8'h01, "push1: [4] frame_cnt == 1");
    check(wire_bytes[base+5] == 8'h00, "push1: [5] reserved 0x00");
    check(wire_bytes[base+6]  == 8'h05 && wire_bytes[base+7]  == 8'h18 &&
          wire_bytes[base+8]  == 8'h70 && wire_bytes[base+9]  == 8'h00 &&
          wire_bytes[base+10] == 8'h02 && wire_bytes[base+11] == 8'h09 &&
          wire_bytes[base+12] == 8'h28 && wire_bytes[base+13] == 8'hB0 &&
          wire_bytes[base+14] == 8'h00 && wire_bytes[base+15] == 8'h03,
          "push1: pinned payload[0..9] == 05 18 70 00 02 09 28 B0 00 03");
    check(wire_bytes[base+41] == 8'h21 && wire_bytes[base+42] == 8'h88 &&
          wire_bytes[base+43] == 8'h30 && wire_bytes[base+44] == 8'h02 &&
          wire_bytes[base+45] == 8'h09 && wire_bytes[base+46] == 8'h00,
          "push1: pinned payload[35..40] == 21 88 30 02 09 00");
    check(wire_bytes[base+2406] == 8'h3C && wire_bytes[base+2407] == 8'h22,
          "push1: pinned CRC bytes 3C 22 (utils.c table, high byte first)");
    check_push(base, 12'd5, 12'd5, 8'd1, 4'h0, "push1: byte-exact vs model");

    // ---- push 2: same RAM, line=6 frame=2 overrun flag set ----
    base = bytes_lifetime;
    do_start(12'd6, 8'd2, 1'b1);
    wait_total_bytes(base + 2408, 2_000_000);
    check(bytes_lifetime == base + 2408, "push2: exactly 2408 bytes");
    check(wire_bytes[base+3] == 8'h10, "push2: [3] flags bit0 set");
    check_push(base, 12'd6, 12'd5, 8'd2, 4'h1, "push2: byte-exact (flag + fresh CRC)");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end

  initial begin
    #20_000_000;
    $display("FAIL: watchdog timeout");
    $finish;
  end
endmodule
