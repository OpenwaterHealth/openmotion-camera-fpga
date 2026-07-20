// image_pusher.v — builds one 2408-B drip-scan line push (6-B header +
// 2400-B packed RAW10 + CRC-16, spec §4.1) as 602 x 32-bit words for the
// shared Serializer. Bytes assemble in wire order: CRC (crc16.v, matches
// sensor-fw util_crc16) folds bytes 0..2405 as they are placed, then bytes
// 2406/2407 emit crc high-then-low (uart_comms.c convention). Payload
// bytes come from raw10_pack fed by a fetch engine reading 960 pixel
// pairs from the handed-off line RAM (sync read, 1-clk latency).
//
// Serializer contract: word_o must be stable per 4-byte word and advance
// on `done` rises — EXCEPT the first done after serialize_active_o rises,
// which is the phantom pulse (select==11 while o_TX_Ready rises out of
// reset, before any byte transmits — see histo_serializer.v). It is
// filtered with phantom_seen. Timing slack: ~150 clk per wire word vs
// <~30 clk to build one, so the builder always waits on the wire.
//
// Handoff contract with line_capture: start_i is a 1-clk pulse with
// line_i/frame_i/ovr_flag_i registered on the same edge; start_i is never
// pulsed while busy_o is high (line_capture drops the line instead).
module image_pusher #(
    parameter [7:0] MAGIC       = 8'hB6,
    parameter [7:0] FMT_VERSION = 8'h01
) (
    input  wire        clk,
    input  wire        reset,
    // handoff from line_capture
    input  wire        start_i,
    input  wire [11:0] line_i,
    input  wire [7:0]  frame_i,
    input  wire        ovr_flag_i,      // header flags bit0
    output wire        busy_o,
    // line RAM read port (pair index; sync read)
    output wire [9:0]  ram_addr_o,
    input  wire [23:0] ram_q_i,
    // shared Serializer
    input  wire        serializer_done,
    output reg  [31:0] word_o,
    output reg         serialize_active_o
);

  localparam integer N_PAIRS = 960;     // 1920 px / line
  localparam integer N_WORDS = 602;     // 2408 B / 4

  reg [11:0] line_r;
  reg [7:0]  frame_r;
  reg        ovr_r;
  reg        busy;
  assign busy_o = busy | start_i;

  // ---- serializer done edges + phantom filter ----
  reg done_q, phantom_seen;
  wire done_rise = serializer_done & ~done_q;
  wire word_done = done_rise & phantom_seen;

  // ---- pair fetch engine: keep the gearbox fed ----
  reg  [9:0] fetch_idx;
  reg        fetch_pend;                // ram_q_i holds pair[fetch_idx] now
  wire       pair_room;
  assign ram_addr_o = fetch_idx;
  always @(posedge clk) begin
    if (reset | start_i) begin
      fetch_idx <= 10'd0; fetch_pend <= 1'b0;
    end else if (fetch_pend) begin
      fetch_idx <= fetch_idx + 10'd1;   // gearbox consumed it this edge
      fetch_pend <= 1'b0;
    end else if (busy && fetch_idx < N_PAIRS && pair_room) begin
      fetch_pend <= 1'b1;               // addr presented now; Q valid next clk
    end
  end

  wire [7:0] gb_byte;
  wire       gb_avail;
  wire       pay_take;
  raw10_pack gearbox (
    .clk(clk), .clear(start_i),
    .pair_en(fetch_pend), .pair_in(ram_q_i[19:0]),
    .byte_take(pay_take), .byte_out(gb_byte),
    .byte_avail(gb_avail), .pair_room(pair_room));

  // ---- byte source mux (combinational) ----
  localparam [1:0] S_IDLE = 2'd0, S_BUILD = 2'd1, S_HAND = 2'd2, S_TAIL = 2'd3;
  reg [1:0]  state;
  reg [11:0] byte_idx;                  // 0..2407 in wire order
  reg [31:0] build;
  reg [9:0]  words_loaded;

  wire [15:0] crc;
  reg [7:0] cur_byte;
  reg       cur_rdy;
  always @(*) begin
    cur_rdy = 1'b1;
    case (byte_idx)
      12'd0: cur_byte = MAGIC;
      12'd1: cur_byte = FMT_VERSION;
      12'd2: cur_byte = line_r[7:0];
      12'd3: cur_byte = {3'b000, ovr_r, line_r[11:8]};
      12'd4: cur_byte = frame_r;
      12'd5: cur_byte = 8'h00;
      12'd2406: cur_byte = crc[15:8];   // high byte first (uart_comms.c)
      12'd2407: cur_byte = crc[7:0];
      default: begin cur_byte = gb_byte; cur_rdy = gb_avail; end
    endcase
  end
  wire is_payload = (byte_idx >= 12'd6) && (byte_idx <= 12'd2405);
  wire take_byte  = (state == S_BUILD) && cur_rdy;
  assign pay_take = take_byte && is_payload;

  crc16 crc_i (
    .clk(clk), .init(start_i),
    .byte_en(take_byte && (byte_idx < 12'd2406)),
    .byte_in(cur_byte), .crc(crc));

  // ---- builder / word-hand FSM ----
  always @(posedge clk) begin
    if (reset) begin
      state <= S_IDLE; busy <= 1'b0; serialize_active_o <= 1'b0;
      byte_idx <= 12'd0; words_loaded <= 10'd0;
      done_q <= 1'b0; phantom_seen <= 1'b0;
      line_r <= 12'd0; frame_r <= 8'd0; ovr_r <= 1'b0;
      build <= 32'd0; word_o <= 32'd0;
    end else begin
      done_q <= serializer_done;
      if (done_rise & serialize_active_o & ~phantom_seen)
        phantom_seen <= 1'b1;
      case (state)
        S_IDLE: if (start_i) begin
          busy <= 1'b1; byte_idx <= 12'd0; words_loaded <= 10'd0;
          phantom_seen <= 1'b0;
          line_r <= line_i; frame_r <= frame_i; ovr_r <= ovr_flag_i;
          state <= S_BUILD;
        end
        S_BUILD: if (cur_rdy) begin
          case (byte_idx[1:0])          // Serializer sends data_in[7:0] first
            2'b00: build[7:0]   <= cur_byte;
            2'b01: build[15:8]  <= cur_byte;
            2'b10: build[23:16] <= cur_byte;
            2'b11: build[31:24] <= cur_byte;
          endcase
          byte_idx <= byte_idx + 12'd1;
          if (byte_idx[1:0] == 2'b11) state <= S_HAND;
        end
        S_HAND: begin
          if (words_loaded == 10'd0) begin
            word_o <= build;
            words_loaded <= 10'd1;
            serialize_active_o <= 1'b1; // serializer reset releases now
            state <= S_BUILD;
          end else if (word_done) begin
            word_o <= build;
            words_loaded <= words_loaded + 10'd1;
            state <= (words_loaded == N_WORDS - 1) ? S_TAIL : S_BUILD;
          end
        end
        S_TAIL: if (word_done) begin    // last word finished on the wire
          serialize_active_o <= 1'b0;
          busy <= 1'b0;
          state <= S_IDLE;
        end
      endcase
    end
  end
endmodule
