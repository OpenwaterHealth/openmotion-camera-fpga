
// Histogram of a 2-pixel-per-clock RAW10 stream, sent to the MCU over SPI.
//
// Two histogram banks (ping-pong). A frame is counted into one bank while the
// other bank's previous frame is still being sent, so a frame that starts
// before the previous 4100-byte push has finished is no longer corrupted.
// Each bank holds one histogram per lane (two histogram3 instances); the
// lane counts are summed at read-out.
//
// Bank life cycle:  FREE -> COUNT (frame_valid high) -> FULL (frame ended)
//                   -> SEND (being serialized, then swept to zero) -> FREE.
// Read-out never writes the RAM; after the last word is sent the bank is
// cleared by a separate sweep over all 1024 bins (SCRUB, ~1030 clocks).
// Frames are counted into the banks alternately. A frame that starts while
// its bank is not FREE (both banks hold unsent data) is dropped whole; it is
// never partially counted. The frame counter still counts it, so the MCU
// sees a gap in the frame id.
//
// SPI packet (unchanged): 1025 x 32-bit words, little-endian, LSB-first,
// word i = {8'h00, count[i]} for bins 0..1022, word 1023 = {frame_id,
// count[1023]}, word 1024 = trailing word (bin 0 re-read, always 0).
//
// Timing: clk = clk_pixel_hs = 132.8 MHz, set by the camera link (OX02C1B,
// 2 lanes x 1328 Mbps RAW10 = 265.6 Mpixel/s = 132.8 MHz at 2 pixels/clock).
// All paths are single-cycle at that rate; there are no multicycle exceptions.
//
// After reset, both banks are scrubbed to zero (about 1030 clocks, ~8 us at
// 132.8 MHz) before frames are accepted, so a reset during a push cannot
// leave stale counts behind.
module histogram_module (
    input clk,
    input reset,
    input [19:0] pixel_data,
    input frame_valid,
    input line_valid,
    input spi_clk_i,
    output spi_mosi_o,
    output spi_clk_o,
    input spi_en,
    output [5:0] debug,
    output [9:0] debug2
  );

  // Serializer / read-out state (codes kept compatible with debug[5:4])
  localparam IDLE = 2'b00, SCRUB = 2'b01, SERIALIZE = 2'b11;
  // Bank states
  localparam B_FREE = 2'd0, B_COUNT = 2'd1, B_FULL = 2'd2, B_SEND = 2'd3;

  reg [1:0]  state = SCRUB;
  reg [1:0]  bank_st0 = B_SEND, bank_st1 = B_SEND;
  reg        wr_bank = 1'b0;        // bank the current / next frame is counted into
  reg        rd_bank = 1'b0;        // bank being serialized
  reg        active = 1'b0;         // a frame is being counted into wr_bank
  reg        prev_fv = 1'b1;
  reg [7:0]  frame_counter = 8'd0;  // frames seen (frame_valid falls), counted or dropped
  reg [7:0]  frame_id0 = 8'd0, frame_id1 = 8'd0; // frame id stored with each bank's histogram
  reg [10:0] scrub_cnt = 11'd0;
  reg [1:0]  scrub_mask = 2'b11;    // banks cleared by the current SCRUB sweep

  reg [9:0]  bin = 10'h3ff;
  wire       serializer_done;
  reg        prev_serializer_done = 1'b0;
  reg        flag = 0;

  wire [9:0] pixel_a = pixel_data[9:0];
  wire [9:0] pixel_b = pixel_data[19:10];

  // ------------------------------------------------------------------
  // Frame acceptance and bank selection
  // ------------------------------------------------------------------
  wire fv_rise      = frame_valid & ~prev_fv;
  wire fv_fall      = ~frame_valid & prev_fv;
  wire wr_bank_free = wr_bank ? (bank_st1 == B_FREE) : (bank_st0 == B_FREE);
  wire accept       = fv_rise & wr_bank_free;
  wire counting     = frame_valid & (active | accept);   // high on the first frame clock too
  wire rw0          = counting & ~wr_bank;
  wire rw1          = counting &  wr_bank;
  wire pv0          = rw0 & line_valid;
  wire pv1          = rw1 & line_valid;

  wire full0        = (bank_st0 == B_FULL);
  wire full1        = (bank_st1 == B_FULL);
  wire start_send   = (state == IDLE) & (full0 | full1);
  wire send_sel     = full0 ? 1'b0 : 1'b1;   // at most one bank is FULL at a time
  wire send_done    = (state == SERIALIZE) & serializer_done & (bin == 10'h0) & flag;
  wire scrub_done   = (state == SCRUB) & (scrub_cnt == 11'd1030);

  always @(posedge clk)
  begin
    if (reset)
    begin
      bank_st0      <= B_SEND;     // busy until the scrub has cleared them
      bank_st1      <= B_SEND;
      wr_bank       <= 1'b0;
      active        <= 1'b0;
      prev_fv       <= frame_valid; // a frame already in progress is not a new frame
      frame_counter <= 8'd0;
      frame_id0     <= 8'd0;
      frame_id1     <= 8'd0;
    end
    else
    begin
      prev_fv <= frame_valid;

      if (accept)
      begin
        active <= 1'b1;
        if (wr_bank) bank_st1 <= B_COUNT; else bank_st0 <= B_COUNT;
      end

      if (fv_fall)
      begin
        frame_counter <= frame_counter + 8'd1;
        if (active)
        begin
          active  <= 1'b0;
          wr_bank <= ~wr_bank;
          if (wr_bank) begin bank_st1 <= B_FULL; frame_id1 <= frame_counter + 8'd1; end
          else         begin bank_st0 <= B_FULL; frame_id0 <= frame_counter + 8'd1; end
        end
      end

      if (start_send)
      begin
        if (send_sel) bank_st1 <= B_SEND; else bank_st0 <= B_SEND;
      end

      // A sent bank stays B_SEND through its clear sweep.
      if (scrub_done)
      begin
        if (scrub_mask[0]) bank_st0 <= B_FREE;
        if (scrub_mask[1]) bank_st1 <= B_FREE;
      end
    end
  end

  // ------------------------------------------------------------------
  // Read-out state machine
  // ------------------------------------------------------------------
  always @(posedge clk)
  begin
    if (reset)
    begin
      state      <= SCRUB;
      rd_bank    <= 1'b0;
      scrub_cnt  <= 11'd0;
      scrub_mask <= 2'b11;          // after reset, clear both banks
    end
    else
    begin
      case (state)
        SCRUB:
        begin
          scrub_cnt <= scrub_cnt + 11'd1;
          if (scrub_done)
            state <= IDLE;
        end
        IDLE:
        begin
          if (start_send)
          begin
            state   <= SERIALIZE;
            rd_bank <= send_sel;
          end
        end
        SERIALIZE:
        begin
          if (send_done)
          begin
            state      <= SCRUB;    // clear the bank that was just sent
            scrub_cnt  <= 11'd0;
            scrub_mask <= rd_bank ? 2'b10 : 2'b01;
          end
        end
        default:
          state <= IDLE;
      endcase
    end
  end

  // Bin sequencing. SCRUB walks every bin once per clock; SERIALIZE advances
  // one bin per 32-bit word sent.
  always @(posedge clk)
  begin
    if (reset)
    begin
      bin <= 10'h3ff;
      prev_serializer_done <= 1'b0;
      flag <= 1'b0;
    end
    else if (state == SCRUB)
    begin
      bin <= bin + 10'd1;
      prev_serializer_done <= 1'b0;
      flag <= 1'b0;
    end
    else if (state != SERIALIZE)
    begin
      bin <= 10'h3ff;
      prev_serializer_done <= 1'b0;
      flag <= 1'b0; // a serialization has ended
    end
    else
    begin
      prev_serializer_done <= serializer_done;
      if (!prev_serializer_done && serializer_done)
        bin <= bin + 10'd1; // next bin on the rising edge of serializer_done

      if (bin == 10'd1)
        flag <= 1'b1; // a serialization has started
    end
  end

  // ------------------------------------------------------------------
  // Histogram banks
  // ------------------------------------------------------------------
  wire clr0 = (state == SCRUB) & scrub_mask[0];
  wire clr1 = (state == SCRUB) & scrub_mask[1];
  // Read port follows the pixel bus unless the bank is being sent or cleared.
  // Taken from the bank state register, not from rw, so the EBR read address
  // does not depend on the frame-accept logic in the same clock.
  wire pix_sel0 = (bank_st0 != B_SEND);
  wire pix_sel1 = (bank_st1 != B_SEND);

  wire [23:0] data_0a, data_0b, data_1a, data_1b;

  histogram3 histo_0a (.clk(clk), .rst(reset), .pix_sel(pix_sel0), .clr_en(clr0),
                       .pixel(pixel_a), .pixel_valid(pv0), .bin(bin), .data(data_0a));
  histogram3 histo_0b (.clk(clk), .rst(reset), .pix_sel(pix_sel0), .clr_en(clr0),
                       .pixel(pixel_b), .pixel_valid(pv0), .bin(bin), .data(data_0b));
  histogram3 histo_1a (.clk(clk), .rst(reset), .pix_sel(pix_sel1), .clr_en(clr1),
                       .pixel(pixel_a), .pixel_valid(pv1), .bin(bin), .data(data_1a));
  histogram3 histo_1b (.clk(clk), .rst(reset), .pix_sel(pix_sel1), .clr_en(clr1),
                       .pixel(pixel_b), .pixel_valid(pv1), .bin(bin), .data(data_1b));

  // Word 1024 (bin 0 sent a second time, flag already set) is forced to 0,
  // as it always was in 1.0.0, so the wire format is unchanged.
  wire        trailing = flag & (bin == 10'h0);
  wire [23:0] data     = trailing ? 24'd0 :
                         rd_bank  ? (data_1a + data_1b) : (data_0a + data_0b);
  wire [7:0]  spacer = (bin == 10'h3ff) ? (rd_bank ? frame_id1 : frame_id0) : 8'b0;

  // Registered read-out word: the lane sum and the selects end in a flip-flop
  // instead of running on into the SPI byte register in the same clock. The
  // serializer waits one extra clock before loading each byte to cover this
  // register (histo_serializer.v).
  reg [31:0] word_r = 32'd0;
  always @(posedge clk)
    word_r <= {spacer, data};

  Serializer seralizer_i (
               .fast_clk_in (spi_clk_i),
               .reset       (reset | (state != SERIALIZE)),
               .data_in     (word_r),
               .serial_out  (spi_mosi_o),
               .slow_clk_out(spi_clk_o),
               .done        (serializer_done),
               .debug       ()
             );

  assign debug2 = frame_valid ? pixel_data[9:0] : bin;

  assign debug[0] = spi_clk_o;
  assign debug[1] = spi_mosi_o;
  assign debug[2] = line_valid;
  assign debug[3] = frame_valid;
  assign debug[4] = state[0];
  assign debug[5] = state[1];

endmodule
