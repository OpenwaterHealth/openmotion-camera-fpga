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
  reg [11:0] sent_line = 12'd0;       // line number the pixel side just finished sending
  wire mode_image;
  wire [11:0] line_value;
  wire line_req_toggle;
  wire sweep_value;
  reg  overrun_i = 0;
  reg  wedge_i = 0;
  reg  pix_sweep = 0;
  reg [11:0] pix_target = 12'hEEE;

  fpga_regs regs (
    .clk(clk), .reset(reset),
    .reg_addr(reg_addr), .wr_data(wr_data), .wr_strobe(wr_strobe),
    .rd_data(rd_data),
    .pll_lock_i(pll_lock), .fv_i(fv),
    .line_sent_toggle_i(line_sent_toggle), .sent_line_i(sent_line),
    .img_active_i(img_active),
    .overrun_i(overrun_i),
    .wedge_i(wedge_i),
    .line_ack_toggle_i(line_ack_toggle),
    .mode_image_o(mode_image), .line_value_o(line_value),
    .sweep_value_o(sweep_value),
    .line_req_toggle_o(line_req_toggle));

  // pixel-domain CDC responder (async to clk on purpose)
  reg responder_on = 1;
  always @(line_req_toggle) if (responder_on) begin
    #100; pix_target = line_value; pix_sweep = sweep_value;
    line_ack_toggle = line_req_toggle;
  end

  // stability monitor: while enabled, the published pair must never change
  // — line AND sweep, so a torn {sweep,line} publish fails deterministically
  reg monitor_stability = 0;
  integer errors = 0;
  always @(line_value or sweep_value) if (monitor_stability) begin
    errors = errors + 1;
    $display("FAIL: {sweep,line} publish changed while req pending");
  end

  // count req toggles so tests can assert exact handshake activity
  integer req_edges = 0;
  always @(line_req_toggle) req_edges = req_edges + 1;

  `include "i2c_line/i2c_master_tasks.vh"

  reg ack; reg [7:0] rb, rb2;
  task check(input cond, input [511:0] msg);  // 64 chars: T-sweep-withheld labels are long
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

  integer k, req_snap;
  initial begin
    $dumpfile("out/fpga_regs_tb.vcd"); $dumpvars(0, fpga_regs_tb);
    #200 reset = 0;

    // T-initial-publish: reset forces one publish of the reset counter (0)
    #2000;
    check(pix_target == 12'd0, "initial publish delivered 0");

    rd_reg(8'h00, rb); check(rb == 8'h5A, "ID");
    rd_reg(8'h01, rb); check(rb == 8'h02, "VERSION == 0x02");
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
    sent_line = 12'h234;                          // pixel side sent our current target
    line_sent_toggle = ~line_sent_toggle; #5000;
    rd_reg(8'h06, rb); check(rb == 8'h35, "auto-increment");
    check(pix_target == 12'h235, "CDC re-published");

    // T-stale: a line_sent for an OLD target (arriving after an MCU rewind)
    // must be discarded, not bump the freshly committed counter
    wr_reg(8'h04, 8'h50); wr_reg(8'h05, 8'h00);   // rewind to line 0x050
    #5000;
    check(pix_target == 12'h050, "CDC delivered 0x050");
    sent_line = 12'h234;                          // stale: old-target packet finishes late
    line_sent_toggle = ~line_sent_toggle; #5000;
    rd_reg(8'h06, rb); rd_reg(8'h07, rb2);
    check({rb2[3:0], rb} == 12'h050, "stale line_sent discarded");
    sent_line = 12'h050;                          // legit completion for current target
    line_sent_toggle = ~line_sent_toggle; #5000;
    rd_reg(8'h06, rb); rd_reg(8'h07, rb2);
    check({rb2[3:0], rb} == 12'h051, "legit line_sent increments");
    check(pix_target == 12'h051, "CDC re-published 0x051");

    // T-withheld-ack: while a req is pending the published bus must hold
    // steady; back-to-back commits coalesce and the LAST one wins
    responder_on = 0;
    wr_reg(8'h04, 8'hAA); wr_reg(8'h05, 8'h00);   // 0x0AA — publishes, req pends
    monitor_stability = 1;                        // 0x0AA publish already fired
    wr_reg(8'h04, 8'hBB); wr_reg(8'h05, 8'h00);   // 0x0BB — must NOT publish
    wr_reg(8'h04, 8'hCC); wr_reg(8'h05, 8'h00);   // 0x0CC — must NOT publish
    check(line_value == 12'h0AA, "line_value_o held at 0x0AA while pending");
    monitor_stability = 0;
    req_snap = req_edges;
    responder_on = 1;
    #100; pix_target = line_value; line_ack_toggle = line_req_toggle; // ack pending req
    #5000;
    check(pix_target == 12'h0CC, "withheld ack: last write wins (0x0CC)");
    check(req_edges == req_snap + 1, "exactly one more req edge");
    rd_reg(8'h06, rb); rd_reg(8'h07, rb2);
    check({rb2[3:0], rb} == 12'h0CC, "LINE_CUR == 0x0CC after coalesce");

    // T-lone-H: an H write alone commits using the last staged L
    wr_reg(8'h04, 8'h11);                         // stage L only
    wr_reg(8'h02, 8'h77);                         // unrelated write; staging persists
    wr_reg(8'h05, 8'h03);                         // commit {0x3, 0x11} = 0x311
    #5000;
    rd_reg(8'h06, rb); rd_reg(8'h07, rb2);
    check({rb2[3:0], rb} == 12'h311, "lone H write commits 0x311");
    check(pix_target == 12'h311, "CDC delivered 0x311");

    // T-sweep: CTRL bit1 write/readback; {sweep, line} publish atomically
    wr_reg(8'h04, 8'h40); wr_reg(8'h05, 8'h00);   // LINE = 0x040
    wr_reg(8'h03, 8'h03);                          // image + sweep
    rd_reg(8'h03, rb); check(rb == 8'h03, "T-sweep: CTRL image+sweep readback");
    #5000;
    check(pix_target == 12'h040, "T-sweep: CDC delivered line 0x040");
    check(pix_sweep == 1'b1, "T-sweep: sweep=1 delivered with the line");
    wr_reg(8'h03, 8'h01);                          // sweep off, image stays
    #5000;
    check(pix_sweep == 1'b0, "T-sweep: sweep=0 republished");
    check(pix_target == 12'h040, "T-sweep: line unchanged by sweep republish");

    // T-sweep-withheld: while a LINE publish pends (ack withheld), a CTRL
    // SWEEP flip must NOT tear onto the published bus; after a single ack
    // the one republish delivers {sweep=1, line} together
    responder_on = 0;
    wr_reg(8'h04, 8'hB0); wr_reg(8'h05, 8'h00);   // LINE = 0x0B0 — publishes {0,0x0B0}, req pends
    monitor_stability = 1;                        // {0,0x0B0} publish already fired
    wr_reg(8'h03, 8'h03);                         // CTRL |= SWEEP — must NOT publish
    check(line_value == 12'h0B0, "T-sweep-withheld: line held 0x0B0 while pending");
    check(sweep_value == 1'b0, "T-sweep-withheld: sweep held 0 while pending");
    monitor_stability = 0;
    req_snap = req_edges;
    #100; line_ack_toggle = line_req_toggle;      // single manual ack
    #5000;
    check(req_edges == req_snap + 1, "T-sweep-withheld: exactly one more req edge");
    check(sweep_value == 1'b1, "T-sweep-withheld: republish delivers sweep=1");
    check(line_value == 12'h0B0, "T-sweep-withheld: ...atomically with line 0x0B0");
    #100; line_ack_toggle = line_req_toggle;      // ack the republish
    pix_target = line_value; pix_sweep = sweep_value;
    responder_on = 1;
    #2000;

    // T-overrun: STATUS bit2 mirrors the pixel-domain latch level; bit3
    // must NOT follow it (overrun and wedge are separate diagnoses)
    overrun_i = 1; #500;
    rd_reg(8'h09, rb); check(rb[2] === 1'b1, "T-overrun: STATUS bit2 set");
    check(rb[3] === 1'b0, "T-overrun: bit3 stays clear (not a wedge)");
    overrun_i = 0; #500;
    rd_reg(8'h09, rb); check(rb[2] === 1'b0, "T-overrun: STATUS bit2 clear");

    // T-wedge: STATUS bit3 mirrors the wedge latch level, independent of
    // bit2 (disambiguation: wedge = electrical/SEU event mid-push,
    // overrun = host misprogrammed sensor timing)
    wedge_i = 1; #500;
    rd_reg(8'h09, rb); check(rb[3] === 1'b1, "T-wedge: STATUS bit3 set");
    check(rb[2] === 1'b0, "T-wedge: bit2 stays clear (not an overrun)");
    wedge_i = 0; #500;
    rd_reg(8'h09, rb); check(rb[3] === 1'b0, "T-wedge: STATUS bit3 clear");

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
