// line_capture.v — captures one selected video line per frame into its own
// 1024x24 EBR and replays it through the shared Serializer using the exact
// framing of histogram packets (1025 words / 4100 bytes, incl. the phantom
// first done pulse — see spec). Serialization starts at frame_valid falling
// edge so packets keep the histogram timing envelope (MCU DMA re-arm race).
// Timing envelope: serialize = ~1.14 ms at 133 MHz; vertical blanking
// ~1.78 ms @40fps / ~1.19 ms @60fps (98 of 1378 line-times) — same envelope
// as histogram packets, ~4% margin at 60 fps.
module line_capture #(
    parameter [7:0] MAGIC = 8'hB6
) (
    input  wire        clk,               // clk_pixel_hs
    input  wire        reset,
    input  wire        enable,            // image mode (already synced to clk)
    input  wire [19:0] pixel_data,
    input  wire        frame_valid,
    input  wire        line_valid,
    // CDC with fpga_regs (osc domain)
    input  wire [11:0] line_value_i,
    input  wire        line_req_toggle_i,
    output reg         line_ack_toggle_o,
    output reg         line_sent_toggle_o,
    output wire [11:0] sent_line_o,       // which line the last toggle reported (quasi-static)
    output wire        img_active_o,
    // serializer interface
    input  wire        serializer_done,
    output wire [31:0] word_o,
    output wire        serialize_active_o
);

  // ---- CDC receive: target line ----
  // Level-mismatch reception (synced req != our ack), NOT edge detection:
  // self-heals from any stale state after reset skew with a stopped pixel
  // clock (an edge-detect history flop can latch a stale '1' and deadlock).
  reg [1:0] s_req /* synthesis syn_preserve=1 */;
  reg [11:0] target;
  always @(posedge clk) begin
    if (reset) begin
      s_req <= 2'b00; target <= 12'd0; line_ack_toggle_o <= 1'b0;
    end else begin
      s_req <= {s_req[0], line_req_toggle_i};
      if (s_req[1] != line_ack_toggle_o) begin
        target <= line_value_i;           // stable while req pending
        line_ack_toggle_o <= s_req[1];
      end
    end
  end

  // ---- video position tracking ----
  reg fv_q, lv_q;
  always @(posedge clk) begin fv_q <= frame_valid; lv_q <= line_valid; end
  wire fv_rise = frame_valid & ~fv_q;
  wire fv_fall = ~frame_valid & fv_q;
  wire lv_fall = ~line_valid & lv_q;

  reg [11:0] line_cnt;
  reg [10:0] col_cnt;
  reg [7:0]  frame_cnt;
  always @(posedge clk) begin
    if (reset) begin line_cnt <= 12'd0; frame_cnt <= 8'd0; end
    else begin
      if (fv_rise) begin line_cnt <= 12'd0; frame_cnt <= frame_cnt + 8'd1; end
      else if (lv_fall) line_cnt <= line_cnt + 12'd1;
    end
    if (reset | ~line_valid) col_cnt <= 11'd0;
    else col_cnt <= col_cnt + 11'd1;
  end

  // ---- capture control ----
  localparam S_IDLE = 1'b0, S_SER = 1'b1;
  reg state;
  reg armed, captured;
  reg [11:0] line_rep;                    // line number of the captured data
  reg [9:0] word_idx;                     // serializer word counter (see below)
  reg prev_done, flag;
  reg capturing_q;

  wire capturing = armed & (state == S_IDLE) & ~captured &
                   frame_valid & line_valid & (line_cnt == target);

  always @(posedge clk) begin
    if (reset) begin
      armed <= 1'b0; captured <= 1'b0; line_rep <= 12'd0;
      state <= S_IDLE; line_sent_toggle_o <= 1'b0; capturing_q <= 1'b0;
    end else begin
      if (fv_rise) armed <= enable;       // mode changes land on frame boundaries
      capturing_q <= capturing;
      if (capturing_q & ~capturing) begin
        // Latch only if capture ended with the line (lv/fv low). If lv&fv are
        // still high, the target changed mid-line: discard the partial capture
        // (no packet, no toggle) — next frame captures the new target cleanly.
        if (!(line_valid & frame_valid)) begin
          captured <= 1'b1; line_rep <= target;
        end
      end
      case (state)
        // Level-based (not fv_fall pulse): `captured` latches one clock after
        // the target line's lv drop, so when the sensor drops fv on the SAME
        // clock as the last line's lv (gap=0, target = last line), the
        // one-cycle fv_fall pulse would miss it and defer the packet a whole
        // frame with a wrong frame-counter spacer. The level arm enters 1 clk
        // later in that corner instead — byte framing unchanged.
        S_IDLE: if (~frame_valid & captured) state <= S_SER;
        S_SER:  if (serializer_done && word_idx == 10'h0 && flag == 1'b1) begin
                  state <= S_IDLE;
                  captured <= 1'b0;
                  line_sent_toggle_o <= ~line_sent_toggle_o;
                end
      endcase
    end
  end
  assign img_active_o = armed;
  assign serialize_active_o = (state == S_SER);
  assign sent_line_o = line_rep;          // quasi-static: stable around the sent toggle

  // ---- word counter: byte-exact replica of histo_module bin behavior ----
  always @(posedge clk) begin
    if (reset | (state != S_SER)) begin
      word_idx <= 10'h3FF; prev_done <= 1'b0; flag <= 1'b0;
    end else begin
      prev_done <= serializer_done;
      if (!prev_done && serializer_done)
        word_idx <= word_idx + 10'd1;
      if (word_idx == 10'd1) flag <= 1'b1;
    end
  end

  // ---- line buffer ----
  wire [23:0] ram_q;
  ram_dp_s line_ram (
    .Reset(reset),
    .RdClock(clk), .RdClockEn(~reset), .RdAddress(word_idx), .Q(ram_q),
    .WrClock(clk), .WrClockEn(~reset), .WrAddress(col_cnt[9:0]),
    .Data({4'b0, pixel_data}),
    .WE(capturing & ~col_cnt[10]));

  // read pipeline — mirrors histo_calc's data_out_persistent staging
  reg [9:0] word_idx_q;
  reg word_changed_q;
  reg [23:0] data_persistent;
  always @(posedge clk) begin
    word_idx_q <= word_idx;
    word_changed_q <= (word_idx != word_idx_q);
    if (word_changed_q) data_persistent <= ram_q;
  end

  // ---- metadata spacer ----
  reg [7:0] spacer;
  always @(*) begin
    case (word_idx)
      10'h3FF: spacer = frame_cnt;
      10'h000: spacer = line_rep[7:0];
      10'h001: spacer = {4'b0, line_rep[11:8]};
      10'h002: spacer = MAGIC;
      default: spacer = 8'h00;
    endcase
  end

  assign word_o = {spacer, data_persistent};
endmodule
