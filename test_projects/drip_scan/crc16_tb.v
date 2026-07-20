`timescale 1ns / 1ps
// crc16_tb.v — proves crc16.v == sensor-fw util_crc16 (utils.c): poly
// 0x1021, init 0xFFFF, MSB-first byte folding, no final XOR. All expected
// values below were computed with the actual crc16_tab from utils.c.
`include "../HistoFPGAFw/crc16.v"

module crc16_tb;
  reg clk = 0; always #3.75 clk = ~clk;   // ~133 MHz, like clk_pixel_hs
  reg init = 0, byte_en = 0;
  reg [7:0] byte_in = 8'h00;
  wire [15:0] crc;

  crc16 dut (.clk(clk), .init(init), .byte_en(byte_en),
             .byte_in(byte_in), .crc(crc));

  integer errors = 0;
  task check(input cond, input [511:0] msg);
    if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask

  task crc_init;
    begin @(posedge clk); init <= 1; @(posedge clk); init <= 0; @(posedge clk); end
  endtask
  task crc_byte(input [7:0] b);
    begin byte_in <= b; byte_en <= 1; @(posedge clk); byte_en <= 0; @(posedge clk); end
  endtask

  reg [71:0] s;
  integer i;
  initial begin
    $dumpfile("out/crc16_tb.vcd"); $dumpvars(0, crc16_tb);
    #100;

    // T1: init value
    crc_init;
    check(crc == 16'hFFFF, "T1: init -> 0xFFFF");

    // T2: standard check string "123456789" -> 0x29B1 (CRC-16/CCITT-FALSE)
    s = "123456789";
    for (i = 8; i >= 0; i = i - 1) crc_byte(s[8*i +: 8]);
    check(crc == 16'h29B1, "T2: crc(123456789) == 0x29B1");

    // T3: drip-scan header example B6 01 05 00 01 00 -> 0x5D78
    crc_init;
    crc_byte(8'hB6); crc_byte(8'h01); crc_byte(8'h05);
    crc_byte(8'h00); crc_byte(8'h01); crc_byte(8'h00);
    check(crc == 16'h5D78, "T3: crc(header B6 01 05 00 01 00) == 0x5D78");

    // T4: single zero byte -> 0xE1F0 (catches init/table-index mistakes)
    crc_init;
    crc_byte(8'h00);
    check(crc == 16'hE1F0, "T4: crc(00) == 0xE1F0");

    // T5: AA 55 -> 0xE5EA (bit-order sentinel: reflected variants differ)
    crc_init;
    crc_byte(8'hAA); crc_byte(8'h55);
    check(crc == 16'hE5EA, "T5: crc(AA 55) == 0xE5EA");

    // T6: re-init discards history
    crc_init;
    check(crc == 16'hFFFF, "T6: re-init -> 0xFFFF");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end

  initial begin
    #1_000_000;
    $display("FAIL: watchdog timeout");
    $finish;
  end
endmodule
