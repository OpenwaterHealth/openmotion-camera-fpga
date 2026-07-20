// line_capture.v — image-mode readout producers (single-line + sweep).
//
// SINGLE-LINE mode (feature/5, unchanged): captures one selected video
// line per frame into buffer 0 and replays it through the shared
// Serializer using the exact framing of histogram packets (1025 words /
// 4100 bytes, incl. the phantom first done pulse — see spec).
// Serialization starts at frame_valid falling edge so packets keep the
// histogram timing envelope (MCU DMA re-arm race).
//
// SWEEP mode (feature/8 drip-scan): when the sweep bit (delivered
// atomically with the start line over the req/ack handshake) is armed at
// a frame boundary, EVERY line >= target is captured, ping/pong across
// two line RAMs, and handed to image_pusher, which drains a 2408-B RAW10
// push while the next line lands in the other buffer. A line that
// completes while the pusher is still draining is DROPPED and a sticky
// overrun latch is set (STATUS bit2 / header flag bit0). Any (re-)arm
// publish — a CDC delivery with sweep=1, with or without an intervening
// disarmed frame — clears the latch at the next frame boundary, so the
// host's retry path (re-publish {sweep, first-missing-line} and rerun)
// starts each attempt with a clean tripwire.
// Open-loop timing with a tripwire: at sweep HTS
// (row 0.80 ms > drain 0.69 ms) an overrun means the host mis-programmed
// the sensor. Sweep never toggles line_sent, so fpga_regs' line counter
// holds the host-written start line.
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
    input  wire        sweep_value_i,     // atomic with line_value_i
    input  wire        line_req_toggle_i,
    output reg         line_ack_toggle_o,
    output reg         line_sent_toggle_o,
    output wire [11:0] sent_line_o,       // which line the last toggle reported (quasi-static)
    output wire        img_active_o,
    output wire        overrun_o,         // sticky latch (quasi-static level)
    // serializer interface
    input  wire        serializer_done,
    output wire [31:0] word_o,
    output wire        serialize_active_o
);

  // ---- CDC receive: target line + sweep bit ----
  // Level-mismatch reception (synced req != our ack), NOT edge detection:
  // self-heals from any stale state after reset skew with a stopped pixel
  // clock (an edge-detect history flop can latch a stale '1' and deadlock).
  reg [1:0] s_req /* synthesis syn_preserve=1 */;
  reg [11:0] target;
  reg sweep_pend;
  always @(posedge clk) begin
    if (reset) begin
      s_req <= 2'b00; target <= 12'd0; sweep_pend <= 1'b0;
      line_ack_toggle_o <= 1'b0;
    end else begin
      s_req <= {s_req[0], line_req_toggle_i};
      if (s_req[1] != line_ack_toggle_o) begin
        target <= line_value_i;           // stable while req pending
        sweep_pend <= sweep_value_i;
        line_ack_toggle_o <= s_req[1];
      end
    end
  end

  // CDC delivery event (1 clk): the same edge that latched target/sweep_pend
  wire cdc_event = (s_req[1] != line_ack_toggle_o);

  // ---- video position tracking ----
  reg fv_q, lv_q;
  always @(posedge clk) begin fv_q <= frame_valid; lv_q <= line_valid; end
  wire fv_rise = frame_valid & ~fv_q;
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
  reg armed, armed_sweep, captured;
  reg [11:0] line_rep;                    // line number of the captured data
  reg [9:0] word_idx;                     // serializer word counter (see below)
  reg prev_done, flag;
  reg capturing_q;

  wire pusher_busy, pusher_active;

  // single-line capture: gated off entirely while sweep is armed
  wire capturing = armed & ~armed_sweep & (state == S_IDLE) & ~captured &
                   frame_valid & line_valid & (line_cnt == target);

  // sweep capture: every line >= start line
  wire sweep_hit = armed_sweep & frame_valid & line_valid & (line_cnt >= target);
  reg  sweep_hit_q;
  reg  wr_sel;                            // buffer being written
  reg  ovr_latch;
  reg  cdc_event_q;                       // pipelined so sweep_pend is settled
  reg  ovr_clr_pend;                      // re-arm publish seen: clear at next fv_rise
  reg  push_start;
  reg  [11:0] push_line;
  reg  [7:0]  push_frame;
  reg  push_buf;                          // buffer being drained
  wire sweep_arm_edge = fv_rise & enable & sweep_pend & ~armed_sweep;

  always @(posedge clk) begin
    if (reset) begin
      armed <= 1'b0; armed_sweep <= 1'b0; captured <= 1'b0;
      line_rep <= 12'd0; state <= S_IDLE;
      line_sent_toggle_o <= 1'b0; capturing_q <= 1'b0;
      sweep_hit_q <= 1'b0; wr_sel <= 1'b0; ovr_latch <= 1'b0;
      cdc_event_q <= 1'b0; ovr_clr_pend <= 1'b0;
      push_start <= 1'b0; push_line <= 12'd0; push_frame <= 8'd0;
      push_buf <= 1'b0;
    end else begin
      push_start <= 1'b0;                 // default: 1-clk pulse
      if (fv_rise) begin
        armed <= enable;                  // mode changes land on frame boundaries
        armed_sweep <= enable & sweep_pend;
      end
      if (sweep_arm_edge) ovr_latch <= 1'b0;   // spec: cleared on sweep arm
      // Any (re-)arm publish also clears the latch at the next frame
      // boundary — the host retry path re-publishes {sweep=1, line}
      // WITHOUT a disarmed frame, so the disarmed->armed sweep_arm_edge
      // alone would leave the latch (and header flag bit0) stuck for the
      // whole session. Pend on the pipelined CDC event (sweep_pend is the
      // single sample point of the async sweep bit); consume at fv_rise.
      cdc_event_q <= cdc_event;
      if (fv_rise & ovr_clr_pend) begin
        ovr_latch <= 1'b0; ovr_clr_pend <= 1'b0;
      end
      if (cdc_event_q & sweep_pend) ovr_clr_pend <= 1'b1;

      // -- single-line path (feature/5, unchanged) --
      capturing_q <= capturing;
      if (capturing_q & ~capturing) begin
        // Latch only if capture ended with the line (lv/fv low). If lv&fv
        // are still high, the target changed mid-line: discard the partial
        // capture (no packet, no toggle) — next frame captures cleanly.
        if (!(line_valid & frame_valid)) begin
          captured <= 1'b1; line_rep <= target;
        end
      end
      case (state)
        // Level-based (not fv_fall pulse) — see feature/5 gap=0 rationale.
        // ~pusher_busy: never contend with a still-draining sweep push
        // (cross-mode corner at sweep exit; host sequencing avoids it,
        // the guard makes it safe regardless).
        S_IDLE: if (~frame_valid & captured & ~pusher_busy) state <= S_SER;
        S_SER:  if (serializer_done && word_idx == 10'h0 && flag == 1'b1) begin
                  state <= S_IDLE;
                  captured <= 1'b0;
                  line_sent_toggle_o <= ~line_sent_toggle_o;
                end
      endcase

      // -- sweep path: hand each completed line to the pusher, or drop --
      sweep_hit_q <= sweep_hit;
      if (sweep_hit_q & ~sweep_hit) begin
        if (!(line_valid & frame_valid)) begin   // clean line end
          // state==S_SER: reverse cross-mode guard — a sweep line completing
          // while a legacy single-line drain is in flight (misprogrammed VTS)
          // takes the standard drop+tripwire instead of contending for the
          // Serializer, symmetric with the ~pusher_busy guard on S_SER entry.
          if (pusher_busy || state == S_SER) begin
            ovr_latch <= 1'b1;            // drop: wr_sel unchanged, reuse buffer
          end else begin
            push_start <= 1'b1;
            push_line  <= line_cnt;       // pre-increment value (lv_fall
                                          // bumps line_cnt this same edge)
            push_frame <= frame_cnt;
            push_buf   <= wr_sel;
            wr_sel     <= ~wr_sel;
          end
        end
      end
    end
  end
  assign img_active_o = armed;
  assign overrun_o = ovr_latch;
  assign serialize_active_o = (state == S_SER) | pusher_active;
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

  // ---- line buffers (ping/pong; buffer 0 doubles as the legacy buffer) ----
  wire [23:0] q0, q1;
  wire [9:0]  pusher_addr;
  // Mux on busy_o, NOT serialize_active_o: the pusher fetches pair 0 during
  // its header-build window, ~4 clks before serialize_active_o rises (see
  // image_pusher.v fetch contract "addr presented now; Q valid next clk").
  // busy_o covers from the start_i cycle; keying on serialize_active_o feeds
  // pair 0 from word_idx's parked address (0x3FF) on every buffer-0 push.
  // Never contends with the legacy S_SER read: S_SER entry is guarded by
  // ~pusher_busy.
  wire [9:0]  rd_addr0 = pusher_busy ? pusher_addr : word_idx;
  wire we0 = (capturing | (sweep_hit & ~wr_sel)) & ~col_cnt[10];
  wire we1 = (sweep_hit &  wr_sel) & ~col_cnt[10];
  ram_dp_s line_ram (
    .Reset(reset),
    .RdClock(clk), .RdClockEn(~reset), .RdAddress(rd_addr0), .Q(q0),
    .WrClock(clk), .WrClockEn(~reset), .WrAddress(col_cnt[9:0]),
    .Data({4'b0, pixel_data}),
    .WE(we0));
  ram_dp_s line_ram_b (
    .Reset(reset),
    .RdClock(clk), .RdClockEn(~reset), .RdAddress(pusher_addr), .Q(q1),
    .WrClock(clk), .WrClockEn(~reset), .WrAddress(col_cnt[9:0]),
    .Data({4'b0, pixel_data}),
    .WE(we1));

  // legacy read pipeline — mirrors histo_calc's data_out_persistent staging
  reg [9:0] word_idx_q;
  reg word_changed_q;
  reg [23:0] data_persistent;
  always @(posedge clk) begin
    word_idx_q <= word_idx;
    word_changed_q <= (word_idx != word_idx_q);
    if (word_changed_q) data_persistent <= q0;
  end

  // ---- metadata spacer (legacy envelope) ----
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

  // ---- sweep drain: image_pusher ----
  wire [31:0] pusher_word;
  image_pusher #(.MAGIC(MAGIC)) pusher_i (
    .clk(clk), .reset(reset),
    .start_i(push_start), .line_i(push_line), .frame_i(push_frame),
    .ovr_flag_i(ovr_latch), .busy_o(pusher_busy),
    .ram_addr_o(pusher_addr), .ram_q_i(push_buf ? q1 : q0),
    .serializer_done(serializer_done),
    .word_o(pusher_word), .serialize_active_o(pusher_active));

  assign word_o = pusher_active ? pusher_word : {spacer, data_persistent};
endmodule
