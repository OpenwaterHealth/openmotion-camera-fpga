// crc16.v — byte-wise CRC-16/CCITT-FALSE: poly 0x1021, init 0xFFFF, bytes
// folded MSB-first, no reflection, no final XOR. Byte-identical to
// sensor-fw util_crc16 (Core/Src/utils.c: crc = (crc<<8) ^ tab[(crc>>8)^b]).
// The SPI link transmits bytes LSB-first (spi_master.v) but the CRC is
// defined over byte VALUES, so bytes are folded pre-serialization.
// One byte per byte_en pulse; 8 unrolled XOR stages — trivial at 133 MHz.
module crc16 (
    input  wire        clk,
    input  wire        init,        // 1-clk pulse: crc <= 16'hFFFF
    input  wire        byte_en,     // 1-clk pulse: fold byte_in into crc
    input  wire [7:0]  byte_in,
    output reg  [15:0] crc          // undefined until the first init pulse
);

  function [15:0] crc_step8(input [15:0] c, input [7:0] b);
    integer k;
    reg [15:0] t;
    reg fb;
    begin
      t = c;
      for (k = 7; k >= 0; k = k - 1) begin
        fb = t[15] ^ b[k];                       // MSB of the byte first
        t = {t[14:0], 1'b0} ^ (fb ? 16'h1021 : 16'h0000);
      end
      crc_step8 = t;
    end
  endfunction

  always @(posedge clk) begin
    if (init) crc <= 16'hFFFF;
    else if (byte_en) crc <= crc_step8(crc, byte_in);
  end
endmodule
