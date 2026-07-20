// raw10_pack.v — little-endian bit gearbox: 20-bit pixel-pair pushes in,
// RAW10 payload bytes out. Pair n of a line occupies payload bits
// [20n+19:20n]; bytes pop low-bits-first. This IS the spec §4.1 layout
// (4 px -> 5 B, pixel k of a group at bits [10k+9:10k], low byte first):
// two consecutive pairs form one 40-bit group and the byte boundaries
// fall out of the same little-endian bitstream. 960 pairs -> 2400 bytes.
//
// Contract (caller-enforced, keeps the datapath minimal):
//   - pair_en only when pair_room (cnt <= 12; worst case 12+20 = 32 bits)
//   - byte_take only when byte_avail (cnt >= 8)
//   - simultaneous pair_en+byte_take is legal and handled
module raw10_pack (
    input  wire        clk,
    input  wire        clear,       // 1-clk pulse: empty the accumulator
    input  wire        pair_en,
    input  wire [19:0] pair_in,
    input  wire        byte_take,
    output wire [7:0]  byte_out,
    output wire        byte_avail,
    output wire        pair_room
);

  reg [31:0] acc;
  reg [5:0]  cnt;

  assign byte_out   = acc[7:0];
  assign byte_avail = (cnt >= 6'd8);
  assign pair_room  = (cnt <= 6'd12);
  // These thresholds guarantee pair_room|byte_avail always holds (all deltas
  // are multiples of 4), so a caller alternating push/pop can never deadlock.
  // Synthesis builds a full 6-bit barrel shifter below even though the
  // contract bounds cnt to [0,12] — single instance, ample slack at 133 MHz.

  always @(posedge clk) begin
    if (clear) begin
      acc <= 32'd0; cnt <= 6'd0;
    end else begin
      case ({pair_en, byte_take})
        2'b10: begin
          acc <= acc | ({12'd0, pair_in} << cnt);
          cnt <= cnt + 6'd20;
        end
        2'b01: begin
          acc <= acc >> 8;
          cnt <= cnt - 6'd8;
        end
        2'b11: begin
          acc <= (acc >> 8) | ({12'd0, pair_in} << (cnt - 6'd8));
          cnt <= cnt + 6'd12;
        end
        default: ;
      endcase
    end
  end
endmodule
