`timescale 1ns / 1ps
`include "../HistoFPGAFw/i2c_slave.v"
`include "../HistoFPGAFw/fpga_regs.v"

module fpga_regs_tb;
  reg clk = 0, reset = 1;
  always #21 clk = ~clk;              // ~24 MHz

  reg m_scl = 1, m_sda_drive_low = 0;
  wire dut_sda_oe;
  wire sda_bus = (m_sda_drive_low | dut_sda_oe) ? 1'b0 : 1'b1;

  wire [7:0] reg_addr, wr_data, rd_data;
  wire wr_strobe;
  i2c_slave #(.I2C_ADDR(7'h5A)) slave (
    .clk(clk), .reset(reset), .scl_i(m_scl), .sda_i(sda_bus),
    .sda_oe(dut_sda_oe), .reg_addr(reg_addr), .wr_data(wr_data),
    .wr_strobe(wr_strobe), .rd_data(rd_data));

  // TB models the pixel domain side of the CDC
  reg pll_lock = 1, fv = 0, line_sent_toggle = 0, img_active = 0;
  reg line_ack_toggle = 0;
  wire mode_image;
  wire [11:0] line_value;
  wire line_req_toggle;
  reg [11:0] pix_target = 12'hEEE;

  fpga_regs regs (
    .clk(clk), .reset(reset),
    .reg_addr(reg_addr), .wr_data(wr_data), .wr_strobe(wr_strobe),
    .rd_data(rd_data),
    .pll_lock_i(pll_lock), .fv_i(fv),
    .line_sent_toggle_i(line_sent_toggle), .img_active_i(img_active),
    .line_ack_toggle_i(line_ack_toggle),
    .mode_image_o(mode_image), .line_value_o(line_value),
    .line_req_toggle_o(line_req_toggle));

  // pixel-domain CDC responder (async to clk on purpose)
  always @(line_req_toggle) begin
    #100; pix_target = line_value; line_ack_toggle = line_req_toggle;
  end

  `include "i2c_line/i2c_master_tasks.vh"

  reg ack; reg [7:0] rb, rb2; integer errors = 0;
  task check(input cond, input [255:0] msg);
    if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask
  task wr_reg(input [7:0] r, input [7:0] v);
    begin
      i2c_start; i2c_write_byte({7'h5A,1'b0}, ack);
      i2c_write_byte(r, ack); i2c_write_byte(v, ack); i2c_stop; #2000;
    end
  endtask
  task rd_reg(input [7:0] r, output [7:0] v);
    begin
      i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); i2c_write_byte(r, ack);
      i2c_start; i2c_write_byte({7'h5A,1'b1}, ack);
      i2c_read_byte(1'b0, v); i2c_stop; #2000;
    end
  endtask

  integer k;
  initial begin
    $dumpfile("out/fpga_regs_tb.vcd"); $dumpvars(0, fpga_regs_tb);
    #200 reset = 0; #500;

    rd_reg(8'h00, rb); check(rb == 8'h5A, "ID");
    rd_reg(8'h01, rb); check(rb == 8'h01, "VERSION");
    rd_reg(8'h02, rb); check(rb == 8'hA5, "SCRATCH default");
    wr_reg(8'h02, 8'h3C); rd_reg(8'h02, rb); check(rb == 8'h3C, "SCRATCH rw");

    check(mode_image == 1'b0, "mode default 0");
    wr_reg(8'h03, 8'h01); check(mode_image == 1'b1, "mode set");

    // LINE commit on H write; CDC delivers to pixel side
    wr_reg(8'h04, 8'h34); wr_reg(8'h05, 8'h02);   // line 0x234
    #5000;
    check(pix_target == 12'h234, "CDC delivered 0x234");
    rd_reg(8'h06, rb); rd_reg(8'h07, rb2);
    check({rb2[3:0], rb} == 12'h234, "LINE_CUR readback");

    // line_sent event increments the counter and re-publishes
    line_sent_toggle = ~line_sent_toggle; #5000;
    rd_reg(8'h06, rb); check(rb == 8'h35, "auto-increment");
    check(pix_target == 12'h235, "CDC re-published");

    // FRAME_CNT counts fv rising edges
    for (k = 0; k < 3; k = k + 1) begin fv = 1; #500; fv = 0; #500; end
    rd_reg(8'h08, rb); check(rb == 8'd3, "FRAME_CNT==3");

    // STATUS: pll_lock bit0, img_active bit1
    img_active = 1; #500;
    rd_reg(8'h09, rb); check(rb == 8'h03, "STATUS lock+active");

    rd_reg(8'h0F, rb); check(rb == 8'h00, "undefined reads 0");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end
endmodule
