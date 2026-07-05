// fpga_regs.v — register file for the I2C control plane. clk_osc domain.
// Owns the auto-incrementing image line counter and publishes it to the
// pixel domain via a toggle req/ack handshake (bus stable while req pending).
module fpga_regs #(
    parameter [7:0] ID_VAL  = 8'h5A,
    parameter [7:0] VERSION = 8'h01
) (
    input  wire       clk,
    input  wire       reset,
    // i2c_slave
    input  wire [7:0] reg_addr,
    input  wire [7:0] wr_data,
    input  wire       wr_strobe,
    output reg  [7:0] rd_data,
    // async status inputs (synchronized here)
    input  wire       pll_lock_i,
    input  wire       fv_i,
    input  wire       line_sent_toggle_i,
    input  wire       img_active_i,
    input  wire       line_ack_toggle_i,
    // control outputs
    output reg        mode_image_o,
    output reg [11:0] line_value_o,
    output reg        line_req_toggle_o
);

  reg [1:0] s_pll, s_fv, s_sent, s_ack, s_act;
  reg fv_q, sent_q;
  always @(posedge clk) begin
    s_pll  <= {s_pll[0],  pll_lock_i};
    s_fv   <= {s_fv[0],   fv_i};
    s_sent <= {s_sent[0], line_sent_toggle_i};
    s_ack  <= {s_ack[0],  line_ack_toggle_i};
    s_act  <= {s_act[0],  img_active_i};
    fv_q   <= s_fv[1];
    sent_q <= s_sent[1];
  end
  wire fv_rise    = s_fv[1] & ~fv_q;
  wire sent_event = s_sent[1] ^ sent_q;

  reg [7:0]  scratch;
  reg [7:0]  line_stage_l;
  reg [11:0] line_counter;
  reg [7:0]  frame_cnt;

  always @(posedge clk) begin
    if (reset) begin
      scratch <= 8'hA5; mode_image_o <= 1'b0;
      line_stage_l <= 8'h00; line_counter <= 12'd0; frame_cnt <= 8'd0;
    end else begin
      if (fv_rise) frame_cnt <= frame_cnt + 8'd1;
      if (sent_event) line_counter <= line_counter + 12'd1;
      if (wr_strobe) begin
        case (reg_addr)
          8'h02: scratch <= wr_data;
          8'h03: mode_image_o <= wr_data[0];
          8'h04: line_stage_l <= wr_data;
          8'h05: line_counter <= {wr_data[3:0], line_stage_l}; // commit; wins over sent_event
          default: ;
        endcase
      end
    end
  end

  // publish line_counter to the pixel domain (req/ack toggle handshake)
  reg [11:0] published;
  wire hs_idle = (line_req_toggle_o == s_ack[1]);
  always @(posedge clk) begin
    if (reset) begin
      line_req_toggle_o <= 1'b0; line_value_o <= 12'd0;
      published <= 12'hFFF;                    // != 0 forces initial publish
    end else if (hs_idle && published != line_counter) begin
      line_value_o <= line_counter;
      published <= line_counter;
      line_req_toggle_o <= ~line_req_toggle_o;
    end
  end

  always @(*) begin
    case (reg_addr)
      8'h00: rd_data = ID_VAL;
      8'h01: rd_data = VERSION;
      8'h02: rd_data = scratch;
      8'h03: rd_data = {7'b0, mode_image_o};
      8'h04: rd_data = line_stage_l;
      8'h05: rd_data = {4'b0, line_counter[11:8]};
      8'h06: rd_data = line_counter[7:0];
      8'h07: rd_data = {4'b0, line_counter[11:8]};
      8'h08: rd_data = frame_cnt;
      8'h09: rd_data = {6'b0, s_act[1], s_pll[1]};
      default: rd_data = 8'h00;
    endcase
  end
endmodule
