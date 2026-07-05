# FPGA I2C Slave + Line-Chunked Full-Frame Readout — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the CrossLink camera FPGA an I2C slave control plane (addr 0x5A) and an image-line readout mode, then use them from a host script to capture one lossless full-frame image from all 16 cameras in two scenes (dark + laser-on) and produce an HTML report with 32 PNGs and sensor temperatures.

**Architecture:** Three new RTL modules (`i2c_slave`, `fpga_regs`, `line_capture`) on the free-running oscillator / pixel-clock domains; `Serializer` hoisted from `histogram_module` to `top` with a mode mux; image packets keep the exact 4100-byte histogram SPI envelope so MCU firmware needs **zero changes** (control plane rides the existing `OW_CMD_I2C_REG_READ` passthrough; data rides the histogram path). Host tooling lives in `tools/full_frame_capture/` in this repo.

**Tech Stack:** Verilog-2001, Icarus Verilog (`C:\iverilog\bin\iverilog.exe`), Lattice Diamond 3.14 (`C:\lscc\diamond\3.14\bin\nt64\pnmainc.exe`), Python 3.12+ with `omotion` SDK, numpy, Pillow.

**Spec:** `docs/superpowers/specs/2026-07-05-i2c-slave-line-readout-design.md` (read it first — register map, packet format, CDC rules, verified system facts).

**Key constants (from spec, do not re-derive):** image 1920×1280 (960 pixel-pairs × 1280 lines); packet = 1025 words = 4100 B, transmitted word order 0..1023 then word 0 repeated; spacers: word0=line[7:0], word1=line[11:8], word2=0xB6, word1023=frame counter; I2C addr 0x5A; regs 0x00 ID=0x5A, 0x01 VERSION, 0x02 SCRATCH (reset 0xA5), 0x03 CTRL.bit0=MODE, 0x04/0x05 LINE_L/H (H commits), 0x06/0x07 LINE_CUR, 0x08 FRAME_CNT, 0x09 STATUS.

---

## Task 0: Process setup (GitHub issue + branch)

**Files:** none (process only)

- [ ] **Step 0.1: Create the tracking issue**

```bash
gh issue create -R OpenwaterHealth/openmotion-camera-fpga \
  --title "FPGA I2C slave control plane + full-frame image readout in line chunks" \
  --label feature \
  --body "Adds a soft I2C slave (0x5A) with a register map (mode select, line select, status) and a line_capture module that streams one full-resolution image line per frame over the existing SPI histogram envelope. Spec: docs/superpowers/specs/2026-07-05-i2c-slave-line-readout-design.md. Host bring-up tooling in tools/full_frame_capture/. Deliverable: 16-camera full-frame capture (dark + laser scenes) with lossless PNGs + HTML report."
```

Record the issue number `<N>` for all later steps.

- [ ] **Step 0.2: Add to Project 11 board, set In progress**

```bash
gh project item-add 11 --owner OpenwaterHealth --url https://github.com/OpenwaterHealth/openmotion-camera-fpga/issues/<N> --format json
# note the returned item id, then:
gh project item-edit --id <ITEM_ID> --project-id PVT_kwDOAif52c4BVgTu \
  --field-id PVTSSF_lADOAif52c4BVgTuzhQ7qcU --single-select-option-id 47fc9ee4
```

- [ ] **Step 0.3: Rename working branch and comment planned approach**

```bash
git branch -m feature/<N>-i2c-line-readout
gh issue comment <N> -R OpenwaterHealth/openmotion-camera-fpga \
  --body "Starting work. Approach: soft I2C slave @0x5A + fpga_regs + line_capture with own EBR buffer; Serializer hoisted to top with mode mux; packets keep the 4100B histogram envelope (zero FW changes — control via OW_CMD_I2C_REG_READ write-trick). Spec + plan committed on branch feature/<N>-i2c-line-readout."
```

---

## Task 1: `i2c_slave.v` (TDD)

**Files:**
- Create: `HistoFPGAFw/i2c_slave.v`
- Create: `test_projects/i2c_line/i2c_master_tasks.vh`
- Create: `test_projects/i2c_line/i2c_slave_tb.v`
- Create: `test_projects/i2c_line/run.bat`

- [ ] **Step 1.1: Write the sim runner**

`test_projects/i2c_line/run.bat`:
```bat
@echo off
rem Usage: run.bat <tb_name_without_extension>
setlocal
set IVERILOG=C:\iverilog\bin\iverilog.exe
set VVP=C:\iverilog\bin\vvp.exe
cd /d %~dp0..
if not exist out mkdir out
%IVERILOG% -g2005 -o out\%1.vvp -I . i2c_line\%1.v || exit /b 1
%VVP% out\%1.vvp
```

- [ ] **Step 1.2: Write the bit-banged I2C master tasks (shared TB include)**

`test_projects/i2c_line/i2c_master_tasks.vh` — assumes the including TB declares
`reg m_scl, m_sda_drive_low;` (master lines, open-drain model) and a `wire sda_bus`.
`T_I2C` is the half-bit delay in ns (use 1250 → 400 kHz).

```verilog
// I2C bit-bang master tasks. Open-drain: master pulls low via m_sda_drive_low/m_scl=0.
localparam T_I2C = 1250;

task i2c_start;   // also repeated start
  begin
    m_sda_drive_low = 0; #(T_I2C);
    m_scl = 1;           #(T_I2C);
    m_sda_drive_low = 1; #(T_I2C);   // SDA falls while SCL high
    m_scl = 0;           #(T_I2C);
  end
endtask

task i2c_stop;
  begin
    m_sda_drive_low = 1; #(T_I2C);
    m_scl = 1;           #(T_I2C);
    m_sda_drive_low = 0; #(T_I2C);   // SDA rises while SCL high
  end
endtask

task i2c_write_byte(input [7:0] b, output ack);
  integer i;
  begin
    for (i = 7; i >= 0; i = i - 1) begin
      m_sda_drive_low = ~b[i]; #(T_I2C);
      m_scl = 1; #(2*T_I2C); m_scl = 0; #(T_I2C);
    end
    m_sda_drive_low = 0;       // release for slave ACK
    #(T_I2C); m_scl = 1; #(T_I2C);
    ack = ~sda_bus;            // low = ACK
    #(T_I2C); m_scl = 0; #(T_I2C);
  end
endtask

task i2c_read_byte(input send_ack, output [7:0] b);
  integer i;
  begin
    m_sda_drive_low = 0;       // release — slave drives
    for (i = 7; i >= 0; i = i - 1) begin
      #(T_I2C); m_scl = 1; #(T_I2C);
      b[i] = sda_bus;
      #(T_I2C); m_scl = 0; #(T_I2C);
    end
    m_sda_drive_low = send_ack; #(T_I2C);
    m_scl = 1; #(2*T_I2C); m_scl = 0; #(T_I2C);
    m_sda_drive_low = 0;
  end
endtask
```

- [ ] **Step 1.3: Write the failing testbench**

`test_projects/i2c_line/i2c_slave_tb.v`:

```verilog
`timescale 1ns / 1ps
`include "../HistoFPGAFw/i2c_slave.v"

module i2c_slave_tb;
  reg clk = 0, reset = 1;
  always #21 clk = ~clk;               // ~24 MHz oscillator

  reg m_scl = 1, m_sda_drive_low = 0;
  wire dut_sda_oe;
  wire sda_bus = (m_sda_drive_low | dut_sda_oe) ? 1'b0 : 1'b1;
  wire scl_bus = m_scl;

  wire [7:0] reg_addr, wr_data;
  wire wr_strobe;
  reg  [7:0] regfile [0:15];           // tiny TB regfile
  wire [7:0] rd_data = (reg_addr < 16) ? regfile[reg_addr[3:0]] : 8'h00;
  integer i;
  always @(posedge clk)
    if (wr_strobe && reg_addr < 16) regfile[reg_addr[3:0]] <= wr_data;

  i2c_slave #(.I2C_ADDR(7'h5A)) dut (
    .clk(clk), .reset(reset),
    .scl_i(scl_bus), .sda_i(sda_bus), .sda_oe(dut_sda_oe),
    .reg_addr(reg_addr), .wr_data(wr_data), .wr_strobe(wr_strobe),
    .rd_data(rd_data));

  `include "i2c_line/i2c_master_tasks.vh"

  reg ack; reg [7:0] rb; integer errors = 0;
  task check(input cond, input [255:0] msg);
    if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask

  initial begin
    $dumpfile("out/i2c_slave_tb.vcd"); $dumpvars(0, i2c_slave_tb);
    for (i = 0; i < 16; i = i + 1) regfile[i] = 8'h10 + i;
    #200 reset = 0; #200;

    // T1: write pointer=2, data 0xCA; read back
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); check(ack, "T1 addr ack");
    i2c_write_byte(8'h02, ack); check(ack, "T1 ptr ack");
    i2c_write_byte(8'hCA, ack); check(ack, "T1 data ack");
    i2c_stop; #2000;
    check(regfile[2] == 8'hCA, "T1 regfile[2]==0xCA");

    // T2: combined-format read of reg 2 then auto-inc reg 3
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack);
    i2c_write_byte(8'h02, ack);
    i2c_start; i2c_write_byte({7'h5A,1'b1}, ack); check(ack, "T2 rd addr ack");
    i2c_read_byte(1'b1, rb); check(rb == 8'hCA, "T2 rd reg2");
    i2c_read_byte(1'b0, rb); check(rb == 8'h13, "T2 rd reg3 autoinc"); // NACK last
    i2c_stop; #2000;

    // T3: auto-inc write regs 4,5 in one transaction
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack);
    i2c_write_byte(8'h04, ack);
    i2c_write_byte(8'hAA, ack); i2c_write_byte(8'h0B, ack);
    i2c_stop; #2000;
    check(regfile[4] == 8'hAA && regfile[5] == 8'h0B, "T3 autoinc write");

    // T4: wrong address gets no ACK
    i2c_start; i2c_write_byte({7'h33,1'b0}, ack); check(!ack, "T4 no ack");
    i2c_stop; #2000;

    // T5: HAL_I2C_Mem_Read(2-byte addr) trick: W [06][0x77] Sr R 1 byte
    // -> writes 0x77 into reg 6, dummy read returns reg 7
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack);
    i2c_write_byte(8'h06, ack); i2c_write_byte(8'h77, ack);
    i2c_start; i2c_write_byte({7'h5A,1'b1}, ack);
    i2c_read_byte(1'b0, rb);
    i2c_stop; #2000;
    check(regfile[6] == 8'h77, "T5 write-trick reg6");
    check(rb == 8'h17, "T5 dummy read == reg7");

    // T6: aborted transfer (STOP mid-byte) then a clean transaction
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack);
    m_sda_drive_low = 1; #(T_I2C); m_scl = 1; #(T_I2C);
    m_sda_drive_low = 0; #(T_I2C);          // premature STOP
    m_scl = 1; #2000;
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); check(ack, "T6 recover ack");
    i2c_write_byte(8'h00, ack);
    i2c_start; i2c_write_byte({7'h5A,1'b1}, ack);
    i2c_read_byte(1'b0, rb); check(rb == 8'h10, "T6 read reg0");
    i2c_stop; #2000;

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end
endmodule
```

- [ ] **Step 1.4: Run to verify it fails**

Run: `cd test_projects && i2c_line\run.bat i2c_slave_tb`
Expected: iverilog compile error — `i2c_slave.v` does not exist.

- [ ] **Step 1.5: Implement `HistoFPGAFw/i2c_slave.v`**

```verilog
// i2c_slave.v — synthesizable 7-bit-address I2C slave, byte register interface.
// Oversampling design: SCL/SDA are double-flop synchronized to clk and all
// edges are detected in the clk domain. clk must be >= ~20x the SCL rate
// (24 MHz oscillator vs 400 kHz - 1 MHz bus). No clock stretching.
// Write:  S addr+W [ptr] [data]+ P      (pointer auto-increments per data byte)
// Read:   S addr+W [ptr] Sr addr+R [data]+ P   (auto-increments per byte)
module i2c_slave #(
    parameter [6:0] I2C_ADDR = 7'h5A
) (
    input  wire       clk,
    input  wire       reset,       // active-high synchronous
    input  wire       scl_i,
    input  wire       sda_i,
    output reg        sda_oe,      // 1 = pull SDA low
    output reg  [7:0] reg_addr,
    output reg  [7:0] wr_data,
    output reg        wr_strobe,   // 1-clk pulse: commit wr_data to reg_addr
    input  wire [7:0] rd_data      // combinational read of reg_addr
);

  reg [1:0] scl_sync, sda_sync;
  reg scl_q, sda_q;
  wire scl = scl_sync[1];
  wire sda = sda_sync[1];
  always @(posedge clk) begin
    scl_sync <= {scl_sync[0], scl_i};
    sda_sync <= {sda_sync[0], sda_i};
    scl_q <= scl;
    sda_q <= sda;
  end
  wire scl_rise   = scl & ~scl_q;
  wire scl_fall   = ~scl & scl_q;
  wire start_cond = scl & scl_q & sda_q & ~sda;
  wire stop_cond  = scl & scl_q & ~sda_q & sda;

  localparam [3:0] ST_IDLE    = 4'd0,
                   ST_ADDR    = 4'd1,
                   ST_ACK_A   = 4'd2,
                   ST_PTR     = 4'd3,
                   ST_ACK_P   = 4'd4,
                   ST_WDATA   = 4'd5,
                   ST_ACK_W   = 4'd6,
                   ST_RD_LOAD = 4'd7,
                   ST_RDATA   = 4'd8;

  reg [3:0] state;
  reg [3:0] bit_cnt;
  reg [7:0] sh;
  reg       rw_bit;
  reg       ack_rx;

  always @(posedge clk) begin
    wr_strobe <= 1'b0;
    if (reset) begin
      state <= ST_IDLE; sda_oe <= 1'b0; bit_cnt <= 4'd0;
      rw_bit <= 1'b0; ack_rx <= 1'b0;
      reg_addr <= 8'h00; wr_data <= 8'h00; sh <= 8'h00;
    end else if (start_cond) begin
      state <= ST_ADDR; bit_cnt <= 4'd0; sda_oe <= 1'b0;
    end else if (stop_cond) begin
      state <= ST_IDLE; sda_oe <= 1'b0;
    end else begin
      case (state)
        ST_IDLE: ;

        ST_ADDR: begin
          if (scl_rise && bit_cnt < 4'd8) begin
            sh <= {sh[6:0], sda}; bit_cnt <= bit_cnt + 4'd1;
          end
          if (scl_fall && bit_cnt == 4'd8) begin
            if (sh[7:1] == I2C_ADDR) begin
              rw_bit <= sh[0]; sda_oe <= 1'b1; state <= ST_ACK_A;
            end else state <= ST_IDLE;
          end
        end

        ST_ACK_A: if (scl_fall) begin
          bit_cnt <= 4'd0;
          if (rw_bit) begin sda_oe <= 1'b0; state <= ST_RD_LOAD; end
          else        begin sda_oe <= 1'b0; state <= ST_PTR;     end
        end

        ST_PTR: begin
          if (scl_rise && bit_cnt < 4'd8) begin
            sh <= {sh[6:0], sda}; bit_cnt <= bit_cnt + 4'd1;
          end
          if (scl_fall && bit_cnt == 4'd8) begin
            reg_addr <= sh; sda_oe <= 1'b1; state <= ST_ACK_P;
          end
        end

        ST_ACK_P: if (scl_fall) begin
          bit_cnt <= 4'd0; sda_oe <= 1'b0; state <= ST_WDATA;
        end

        ST_WDATA: begin
          if (scl_rise && bit_cnt < 4'd8) begin
            sh <= {sh[6:0], sda}; bit_cnt <= bit_cnt + 4'd1;
          end
          if (scl_fall && bit_cnt == 4'd8) begin
            wr_data <= sh; wr_strobe <= 1'b1;
            sda_oe <= 1'b1; state <= ST_ACK_W;
          end
        end

        ST_ACK_W: if (scl_fall) begin
          bit_cnt <= 4'd0; sda_oe <= 1'b0;
          reg_addr <= reg_addr + 8'd1;
          state <= ST_WDATA;
        end

        ST_RD_LOAD: begin        // one clk to settle rd_data after pointer change
          sh <= rd_data;
          sda_oe <= ~rd_data[7]; // present MSB (SCL is low here)
          bit_cnt <= 4'd0;
          state <= ST_RDATA;
        end

        ST_RDATA: begin
          if (scl_fall) begin
            if (bit_cnt < 4'd7) begin
              sda_oe <= ~sh[6];
              sh <= {sh[6:0], 1'b0};
              bit_cnt <= bit_cnt + 4'd1;
            end else if (bit_cnt == 4'd7) begin
              sda_oe <= 1'b0;              // release for master ACK/NACK
              bit_cnt <= 4'd8;
            end else if (bit_cnt == 4'd9) begin
              reg_addr <= reg_addr + 8'd1;
              if (ack_rx) state <= ST_RD_LOAD;
              else        state <= ST_IDLE;   // await STOP / repeated START
            end
          end
          if (scl_rise && bit_cnt == 4'd8) begin
            ack_rx <= ~sda; bit_cnt <= 4'd9;
          end
        end

        default: state <= ST_IDLE;
      endcase
    end
  end
endmodule
```

- [ ] **Step 1.6: Run to verify it passes**

Run: `cd test_projects && i2c_line\run.bat i2c_slave_tb`
Expected: `ALL TESTS PASSED`. If a test fails, debug with `gtkwave out/i2c_slave_tb.vcd` (superpowers:systematic-debugging).

- [ ] **Step 1.7: Commit**

```bash
git add HistoFPGAFw/i2c_slave.v test_projects/i2c_line/
git commit -m "feat: synthesizable I2C slave (0x5A) with register interface (#<N>)"
```

---

## Task 2: `fpga_regs.v` (TDD)

**Files:**
- Create: `HistoFPGAFw/fpga_regs.v`
- Create: `test_projects/i2c_line/fpga_regs_tb.v`

- [ ] **Step 2.1: Write the failing testbench**

`test_projects/i2c_line/fpga_regs_tb.v`:

```verilog
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
```

- [ ] **Step 2.2: Run to verify it fails**

Run: `cd test_projects && i2c_line\run.bat fpga_regs_tb`
Expected: compile error — `fpga_regs.v` missing.

- [ ] **Step 2.3: Implement `HistoFPGAFw/fpga_regs.v`**

```verilog
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
```

- [ ] **Step 2.4: Run to verify it passes**

Run: `cd test_projects && i2c_line\run.bat fpga_regs_tb`
Expected: `ALL TESTS PASSED`

- [ ] **Step 2.5: Commit**

```bash
git add HistoFPGAFw/fpga_regs.v test_projects/i2c_line/fpga_regs_tb.v
git commit -m "feat: register file with line counter + CDC publish handshake (#<N>)"
```

---

## Task 3: `line_capture.v` (TDD)

**Files:**
- Create: `HistoFPGAFw/line_capture.v`
- Create: `test_projects/i2c_line/ram_dp_s_beh.v` (sim stand-in for the EBR macro)
- Create: `test_projects/i2c_line/line_capture_tb.v`

- [ ] **Step 3.1: Write the behavioral RAM model**

`test_projects/i2c_line/ram_dp_s_beh.v` — port-compatible with the SCUBA netlist
`HistoFPGAFw/ram_dp/ram_dp_s/ram_dp_s.v` (DP8KE, NOREG → sync-read, data after clock edge):

```verilog
module ram_dp_s (
    input  wire [9:0]  WrAddress,
    input  wire [9:0]  RdAddress,
    input  wire [23:0] Data,
    input  wire        WE,
    input  wire        RdClock,
    input  wire        RdClockEn,
    input  wire        Reset,
    input  wire        WrClock,
    input  wire        WrClockEn,
    output reg  [23:0] Q
);
  reg [23:0] mem [0:1023];
  integer i;
  initial for (i = 0; i < 1024; i = i + 1) mem[i] = 24'd0;  // INIT_ALL_0s
  always @(posedge WrClock) if (WrClockEn && WE) mem[WrAddress] <= Data;
  always @(posedge RdClock) if (RdClockEn) Q <= mem[RdAddress];
endmodule
```

- [ ] **Step 3.2: Write the failing testbench**

`test_projects/i2c_line/line_capture_tb.v`. It drives a shrunken frame geometry
(8 lines × 16 pixel-pairs — geometry is not hardcoded in the DUT), captures line 5,
and checks the full 4100-byte packet through the real `Serializer`/`SPI_Master`:

```verilog
`timescale 1ns / 1ps
`include "../HistoFPGAFw/line_capture.v"
`include "../HistoFPGAFw/histo_serializer.v"
`include "../HistoFPGAFw/spi_master.v"
`include "i2c_line/ram_dp_s_beh.v"

module line_capture_tb;
  reg clk = 0;                       // pixel clock ~133 MHz
  always #3.75 clk = ~clk;
  reg reset = 1;

  // stimulus: 8 lines x 16 pairs per frame
  localparam LINES = 8, PAIRS = 16;
  reg fv = 0, lv = 0;
  reg [19:0] pd = 0;
  integer L, C;
  task send_frame;
    begin
      fv = 1; #400;
      for (L = 0; L < LINES; L = L + 1) begin
        @(posedge clk); lv = 1;
        for (C = 0; C < PAIRS; C = C + 1) begin
          // pixA = 2C + L (10b), pixB = 2C + 1 + L (10b): unique, checkable
          pd = {((2*C + 1 + L) & 20'h3FF) << 10 | ((2*C + L) & 20'h3FF)};
          @(posedge clk);
        end
        lv = 0; pd = 0;
        repeat (40) @(posedge clk);   // horizontal blanking
      end
      fv = 0;
    end
  endtask

  // CDC: TB plays the fpga_regs side
  reg  [11:0] line_value = 12'd5;
  reg  line_req = 0;
  wire line_ack, line_sent;
  wire enable = 1'b1;

  wire ser_done;
  wire [31:0] word;
  wire ser_active;
  wire img_active;

  line_capture dut (
    .clk(clk), .reset(reset), .enable(enable),
    .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
    .line_value_i(line_value), .line_req_toggle_i(line_req),
    .line_ack_toggle_o(line_ack), .line_sent_toggle_o(line_sent),
    .img_active_o(img_active),
    .serializer_done(ser_done), .word_o(word),
    .serialize_active_o(ser_active));

  wire spi_clk, spi_mosi;
  Serializer ser (
    .fast_clk_in(clk), .reset(reset | ~ser_active), .data_in(word),
    .serial_out(spi_mosi), .slow_clk_out(spi_clk), .done(ser_done), .debug());

  // SPI monitor: mode 0, LSB-first (matches SPI_Master modification)
  reg [7:0] cur; integer nbits = 0, nbytes = 0;
  reg [7:0] pkt [0:4099];
  always @(posedge spi_clk) begin
    cur = {spi_mosi, cur[7:1]};       // LSB first
    nbits = nbits + 1;
    if (nbits == 8) begin
      pkt[nbytes] = cur; nbytes = nbytes + 1; nbits = 0;
    end
  end

  integer errors = 0, w, sent_seen = 0;
  reg [31:0] wv;
  task check(input cond, input [255:0] msg);
    if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask
  function [31:0] getword(input integer idx);
    getword = {pkt[4*idx+3], pkt[4*idx+2], pkt[4*idx+1], pkt[4*idx]};
  endfunction

  always @(line_sent) sent_seen = sent_seen + 1;

  initial begin
    $dumpfile("out/line_capture_tb.vcd"); $dumpvars(0, line_capture_tb);
    #100 reset = 0; #100;
    // deliver target line 5 over CDC
    line_req = ~line_req; #200;
    check(line_ack == line_req, "CDC ack");

    send_frame;                        // frame 1: capture line 5, then serialize
    wait (ser_active); wait (!ser_active); #2000;

    check(nbytes == 4100, "packet is 4100 bytes");
    // words 0..15 carry line-5 pixel pairs
    for (w = 0; w < PAIRS; w = w + 1) begin
      wv = getword(w);
      check((wv & 20'hFFFFF) ==
            ((((2*w + 1 + 5) & 10'h3FF) << 10) | ((2*w + 5) & 10'h3FF)),
            "pixel word");
    end
    // spacer metadata
    check(getword(0) >> 24 == 8'h05, "spacer0 = line low");
    check(getword(1) >> 24 == 8'h00, "spacer1 = line high");
    check(getword(2) >> 24 == 8'hB6, "spacer2 = magic");
    check(getword(1023) >> 24 == 8'h01, "spacer1023 = frame counter (frame 1)");
    // unwritten words are zero data
    check((getword(500) & 24'hFFFFFF) == 0, "unused words zero");
    check(sent_seen == 1, "one line_sent event");

    // no capture when target exceeds frame height: no new packet
    nbytes = 0;
    line_value = 12'd100; line_req = ~line_req; #500;
    send_frame; #200000;
    check(nbytes == 0, "no packet for out-of-range line");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end
endmodule
```

- [ ] **Step 3.3: Run to verify it fails**

Run: `cd test_projects && i2c_line\run.bat line_capture_tb`
Expected: compile error — `line_capture.v` missing.

- [ ] **Step 3.4: Implement `HistoFPGAFw/line_capture.v`**

```verilog
// line_capture.v — captures one selected video line per frame into its own
// 1024x24 EBR and replays it through the shared Serializer using the exact
// framing of histogram packets (1025 words / 4100 bytes, incl. the phantom
// first done pulse — see spec). Serialization starts at frame_valid falling
// edge so packets keep the histogram timing envelope (MCU DMA re-arm race).
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
    output wire        img_active_o,
    // serializer interface
    input  wire        serializer_done,
    output wire [31:0] word_o,
    output wire        serialize_active_o
);

  // ---- CDC receive: target line ----
  reg [1:0] s_req; reg req_q;
  reg [11:0] target;
  always @(posedge clk) begin
    if (reset) begin
      s_req <= 2'b00; req_q <= 1'b0; target <= 12'd0; line_ack_toggle_o <= 1'b0;
    end else begin
      s_req <= {s_req[0], line_req_toggle_i};
      req_q <= s_req[1];
      if (s_req[1] ^ req_q) begin
        target <= line_value_i;           // stable while req pending
        line_ack_toggle_o <= ~line_ack_toggle_o;
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
      if (capturing_q & ~capturing) begin // capture just ended (lv dropped)
        captured <= 1'b1; line_rep <= target;
      end
      case (state)
        S_IDLE: if (fv_fall & captured) state <= S_SER;
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
```

Design note: `captured` latches off the falling edge of the registered
`capturing` signal (capture ends when lv drops at the end of the target line) —
do not gate it on `lv_fall & capturing`, which can never be true since
`capturing` requires `line_valid` high.

- [ ] **Step 3.5: Run to verify it passes**

Run: `cd test_projects && i2c_line\run.bat line_capture_tb`
Expected: `ALL TESTS PASSED` — specifically `packet is 4100 bytes` proves the
phantom-done framing matches histogram packets.

- [ ] **Step 3.6: Commit**

```bash
git add HistoFPGAFw/line_capture.v test_projects/i2c_line/ram_dp_s_beh.v test_projects/i2c_line/line_capture_tb.v
git commit -m "feat: line_capture module — one image line per frame, histogram-envelope packets (#<N>)"
```

---

## Task 4: Hoist Serializer out of `histogram_module`; wire everything in `top.v`

**Files:**
- Modify: `HistoFPGAFw/histo_module.v` (interface only — lines 2-14, 47-51, 120-128)
- Modify: `HistoFPGAFw/top.v`

- [ ] **Step 4.1: Edit `histo_module.v` — ports**

Replace the module header (lines 2-14) with:

```verilog
module histogram_module (
    input clk,
    input reset,
    input enable,                    // histogram mode active (synced to clk)
    input [19:0] pixel_data,
    input frame_valid,
    input line_valid,
    input serializer_done_i,         // from top-level Serializer
    output [31:0] word_o,            // {spacer, data} to top-level Serializer
    output serialize_active_o,
    output [5:0] debug,
    output [9:0] debug2
  );
```

- [ ] **Step 4.2: Edit `histo_module.v` — gate IDLE and replace the Serializer instance**

In the state machine, change `IDLE:` case (line 47-51) to:

```verilog
        IDLE:
        begin
          if (frame_valid && enable)
            state <= HISTO;
        end
```

Add after `wire serializer_done;` declarations near the top:

```verilog
  wire serializer_done = serializer_done_i;
```

(and delete `wire serializer_done;` — it becomes this assign). Replace the whole
`Serializer seralizer_i (...)` instantiation (lines 120-128) with:

```verilog
  assign word_o = {spacer, data};
  assign serialize_active_o = (state == SERIALIZE);
```

Finally update the debug assigns that referenced `spi_clk_o` / `spi_mosi_o`
(lines 133-134) to `1'b0`, and delete the now-unused `spi_*` ports everywhere.
**No other lines change** — histogram counting logic stays bit-identical.

- [ ] **Step 4.3: Rewrite `top.v`**

Replace the `/*------------------Histogram Module--------------------*/` section
and pin assignments of `HistoFPGAFw/top.v` (keep everything above line 80 as-is):

```verilog
  /*------------------I2C control plane (clk_osc domain)------------------*/
  wire osc_reset = ~reset_n_HFCLKOUT;
  wire [7:0] r_addr, r_wdata, r_rdata;
  wire r_wstrobe, sda_oe;
  wire mode_image;
  wire [11:0] line_value;
  wire line_req_toggle, line_ack_toggle, line_sent_toggle, img_active;

  i2c_slave #(.I2C_ADDR(7'h5A)) i2c_slave_i (
      .clk(clk_osc), .reset(osc_reset),
      .scl_i(SCL), .sda_i(SDA), .sda_oe(sda_oe),
      .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
      .rd_data(r_rdata));

  fpga_regs fpga_regs_i (
      .clk(clk_osc), .reset(osc_reset),
      .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
      .rd_data(r_rdata),
      .pll_lock_i(pll_lock), .fv_i(cmos_fv),
      .line_sent_toggle_i(line_sent_toggle), .img_active_i(img_active),
      .line_ack_toggle_i(line_ack_toggle),
      .mode_image_o(mode_image), .line_value_o(line_value),
      .line_req_toggle_o(line_req_toggle));

  /*------------------Readout producers (clk_pixel_hs domain)-------------*/
  // mode bit into the pixel domain
  reg [1:0] mode_sync;
  always @(posedge clk_pixel_hs) mode_sync <= {mode_sync[0], mode_image};
  wire mode_pix = mode_sync[1];
  wire pix_reset = ~reset_n_HFCLKOUT;

  wire ser_done;
  wire [31:0] hm_word, lc_word;
  wire hm_active, lc_active;

  histogram_module histogram_module_i (
      .clk(clk_pixel_hs), .reset(pix_reset), .enable(~mode_pix),
      .pixel_data(cmos_data), .frame_valid(cmos_fv), .line_valid(cmos_lv),
      .serializer_done_i(ser_done),
      .word_o(hm_word), .serialize_active_o(hm_active),
      .debug(), .debug2());

  line_capture line_capture_i (
      .clk(clk_pixel_hs), .reset(pix_reset), .enable(mode_pix),
      .pixel_data(cmos_data), .frame_valid(cmos_fv), .line_valid(cmos_lv),
      .line_value_i(line_value), .line_req_toggle_i(line_req_toggle),
      .line_ack_toggle_o(line_ack_toggle),
      .line_sent_toggle_o(line_sent_toggle), .img_active_o(img_active),
      .serializer_done(ser_done),
      .word_o(lc_word), .serialize_active_o(lc_active));

  /*------------------Shared Serializer + SPI-----------------------------*/
  wire spi_mosi, spi_clk;
  Serializer serializer_i (
      .fast_clk_in(clk_pixel_hs),
      .reset(pix_reset | ~(hm_active | lc_active)),
      .data_in(lc_active ? lc_word : hm_word),
      .serial_out(spi_mosi), .slow_clk_out(spi_clk),
      .done(ser_done), .debug());

  /*------------------Output Pin Assignments------------------------------*/
  assign SDA = sda_oe ? 1'b0 : 1'bz;   // open-drain data
  assign FSIN = 1'bz;
  assign DIFF_P = spi_clk;
  assign DIFF_N = spi_mosi;
  assign reset_n_i = GPIO0;
endmodule
```

Notes: `spi_en` was constant 1 so `DIFF_P/N` gating is dropped with identical
behavior. `SCL` stays an input (already is). Everything above the histogram
section (OSCI, PLL, clk divider, reset bridge, mipidphy2cmos) is untouched.

- [ ] **Step 4.4: Lint-compile the pure-RTL subset**

Run (from `test_projects/`): `i2c_line\run.bat line_capture_tb` and `i2c_line\run.bat fpga_regs_tb`
Expected: both still `ALL TESTS PASSED` (histo_module/top aren't in these sims;
this catches accidental breakage of shared files).

- [ ] **Step 4.5: Commit**

```bash
git add HistoFPGAFw/histo_module.v HistoFPGAFw/top.v
git commit -m "refactor: hoist Serializer to top, add mode mux + I2C control plane wiring (#<N>)"
```

---

## Task 5: Integration testbench (I2C → regs → capture → SPI bytes)

**Files:**
- Create: `test_projects/i2c_line/integration_tb.v`

- [ ] **Step 5.1: Write the testbench**

```verilog
`timescale 1ns / 1ps
`include "../HistoFPGAFw/i2c_slave.v"
`include "../HistoFPGAFw/fpga_regs.v"
`include "../HistoFPGAFw/line_capture.v"
`include "../HistoFPGAFw/histo_serializer.v"
`include "../HistoFPGAFw/spi_master.v"
`include "i2c_line/ram_dp_s_beh.v"

module integration_tb;
  // two clock domains
  reg clk_osc = 0;  always #21   clk_osc = ~clk_osc;   // ~24 MHz
  reg clk_pix = 0;  always #3.75 clk_pix = ~clk_pix;   // ~133 MHz
  reg reset = 1;

  // I2C bus
  reg m_scl = 1, m_sda_drive_low = 0;
  wire sda_oe;
  wire sda_bus = (m_sda_drive_low | sda_oe) ? 1'b0 : 1'b1;

  wire [7:0] r_addr, r_wdata, r_rdata; wire r_wstrobe;
  i2c_slave #(.I2C_ADDR(7'h5A)) slave (
    .clk(clk_osc), .reset(reset), .scl_i(m_scl), .sda_i(sda_bus),
    .sda_oe(sda_oe), .reg_addr(r_addr), .wr_data(r_wdata),
    .wr_strobe(r_wstrobe), .rd_data(r_rdata));

  wire mode_image; wire [11:0] line_value;
  wire req_t, ack_t, sent_t, img_act;
  reg fv = 0, lv = 0; reg [19:0] pd = 0;

  fpga_regs regs (
    .clk(clk_osc), .reset(reset),
    .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
    .rd_data(r_rdata),
    .pll_lock_i(1'b1), .fv_i(fv), .line_sent_toggle_i(sent_t),
    .img_active_i(img_act), .line_ack_toggle_i(ack_t),
    .mode_image_o(mode_image), .line_value_o(line_value),
    .line_req_toggle_o(req_t));

  reg [1:0] msync; always @(posedge clk_pix) msync <= {msync[0], mode_image};
  wire ser_done; wire [31:0] lc_word; wire lc_active;

  line_capture lc (
    .clk(clk_pix), .reset(reset), .enable(msync[1]),
    .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
    .line_value_i(line_value), .line_req_toggle_i(req_t),
    .line_ack_toggle_o(ack_t), .line_sent_toggle_o(sent_t),
    .img_active_o(img_act), .serializer_done(ser_done),
    .word_o(lc_word), .serialize_active_o(lc_active));

  wire spi_clk, spi_mosi;
  Serializer ser (
    .fast_clk_in(clk_pix), .reset(reset | ~lc_active), .data_in(lc_word),
    .serial_out(spi_mosi), .slow_clk_out(spi_clk), .done(ser_done), .debug());

  // SPI byte monitor (LSB-first)
  reg [7:0] cur; integer nbits = 0, nbytes = 0;
  reg [7:0] pkt [0:4099];
  always @(posedge spi_clk) begin
    cur = {spi_mosi, cur[7:1]}; nbits = nbits + 1;
    if (nbits == 8) begin
      if (nbytes < 4100) pkt[nbytes] = cur;
      nbytes = nbytes + 1; nbits = 0;
    end
  end
  function [31:0] getword(input integer idx);
    getword = {pkt[4*idx+3], pkt[4*idx+2], pkt[4*idx+1], pkt[4*idx]};
  endfunction

  // camera stimulus: 8 lines x 16 pairs
  integer L, C;
  task send_frame;
    begin
      fv = 1; #400;
      for (L = 0; L < 8; L = L + 1) begin
        @(posedge clk_pix); lv = 1;
        for (C = 0; C < 16; C = C + 1) begin
          pd = {((2*C + 1 + L) & 20'h3FF) << 10 | ((2*C + L) & 20'h3FF)};
          @(posedge clk_pix);
        end
        lv = 0; pd = 0;
        repeat (40) @(posedge clk_pix);
      end
      fv = 0;
    end
  endtask

  `include "i2c_line/i2c_master_tasks.vh"
  reg ack; reg [7:0] rb, rb2; integer errors = 0;
  task check(input cond, input [255:0] msg);
    if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
  endtask
  // MCU-style register access: write via the "2-byte mem-address read" trick
  task mcu_write_reg(input [7:0] r, input [7:0] v);
    begin
      i2c_start; i2c_write_byte({7'h5A,1'b0}, ack);
      i2c_write_byte(r, ack); i2c_write_byte(v, ack);
      i2c_start; i2c_write_byte({7'h5A,1'b1}, ack);
      i2c_read_byte(1'b0, rb); i2c_stop; #2000;
    end
  endtask
  task mcu_read_reg(input [7:0] r, output [7:0] v);
    begin
      i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); i2c_write_byte(r, ack);
      i2c_start; i2c_write_byte({7'h5A,1'b1}, ack);
      i2c_read_byte(1'b0, v); i2c_stop; #2000;
    end
  endtask

  initial begin
    $dumpfile("out/integration_tb.vcd"); $dumpvars(0, integration_tb);
    #300 reset = 0; #1000;

    mcu_read_reg(8'h00, rb); check(rb == 8'h5A, "ID over I2C");
    mcu_write_reg(8'h04, 8'h05); mcu_write_reg(8'h05, 8'h00); // line = 5
    mcu_write_reg(8'h03, 8'h01);                              // image mode
    #10000;

    nbytes = 0;
    send_frame;                       // capture happens on next armed frame
    send_frame;
    #300000;
    check(nbytes >= 4100, "got a packet");
    check(getword(0) >> 24 == 8'h05, "line tag 5");
    check(getword(2) >> 24 == 8'hB6, "magic");

    mcu_read_reg(8'h06, rb); check(rb == 8'h06, "LINE_CUR auto-inc to 6");
    mcu_read_reg(8'h08, rb); check(rb >= 8'h02, "FRAME_CNT counted");

    // rewind to line 0
    mcu_write_reg(8'h04, 8'h00); mcu_write_reg(8'h05, 8'h00);
    nbytes = 0;
    send_frame; #300000;
    check(nbytes >= 4100, "packet after rewind");
    check(getword(0) >> 24 == 8'h00, "line tag 0 after rewind");

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end
endmodule
```

- [ ] **Step 5.2: Run it**

Run: `cd test_projects && i2c_line\run.bat integration_tb`
Expected: `ALL TESTS PASSED`. Note I2C at 400 kHz makes this sim slow (~10s wall).

- [ ] **Step 5.3: Commit**

```bash
git add test_projects/i2c_line/integration_tb.v
git commit -m "test: end-to-end I2C -> regs -> line capture -> SPI packet (#<N>)"
```

---

## Task 6: Diamond synthesis + bitstream

**Files:**
- Modify: `HistoFPGAFw/HistoFPGAFw.ldf` (add 3 sources)
- Create: `HistoFPGAFw/synth.tcl`

- [ ] **Step 6.1: Add sources to the project**

In `HistoFPGAFw/HistoFPGAFw.ldf`, after the `spi_master.v` Source entry insert:

```xml
        <Source name="i2c_slave.v" type="Verilog" type_short="Verilog">
            <Options VerilogStandard="Verilog 2001"/>
        </Source>
        <Source name="fpga_regs.v" type="Verilog" type_short="Verilog">
            <Options VerilogStandard="Verilog 2001"/>
        </Source>
        <Source name="line_capture.v" type="Verilog" type_short="Verilog">
            <Options VerilogStandard="Verilog 2001"/>
        </Source>
```

- [ ] **Step 6.2: Create `HistoFPGAFw/synth.tcl`**

```tcl
prj_project open "HistoFPGAFw.ldf"
prj_run Synthesis -impl impl1 -forceAll
prj_run Translate -impl impl1
prj_run Map -impl impl1
prj_run PAR -impl impl1
prj_run Export -impl impl1 -task Bitgen
prj_project close
```

- [ ] **Step 6.3: Build**

```powershell
cd HistoFPGAFw
& "C:\lscc\diamond\3.14\bin\nt64\pnmainc.exe" synth.tcl
```

Expected: completes with no errors; produces `impl1\HistoFPGAFw_impl1.bit`.
Check `impl1\HistoFPGAFw_impl1.par` / `.mrp` for: EBR usage (expect prior + 3),
0 timing errors. If LSE errors on Verilog, fix and re-run.

- [ ] **Step 6.4: Verify bitstream size against the firmware's hardcoded 163489**

```bash
gh release download -R OpenwaterHealth/openmotion-camera-fpga --pattern "*.bit" -D /tmp/ref-bit --clobber || gh release list -R OpenwaterHealth/openmotion-camera-fpga
ls -l /tmp/ref-bit HistoFPGAFw/impl1/HistoFPGAFw_impl1.bit
```

Expected: our .bit == 163489 bytes (same as the released asset). If it differs
only by the ASCII comment header length (project/date strings), pad or trim is
NOT acceptable blindly — instead set Bitgen to produce a raw-equivalent file:
compare the first 128 bytes (`xxd`) of both files; the fix is usually matching
the Strategy's Bitgen options to what produced the release. Do not proceed to
hardware until sizes match.

- [ ] **Step 6.5: Commit + issue update**

```bash
git add HistoFPGAFw/HistoFPGAFw.ldf HistoFPGAFw/synth.tcl
git commit -m "build: add I2C/line-capture sources to Diamond project + headless synth script (#<N>)"
gh issue comment <N> -R OpenwaterHealth/openmotion-camera-fpga --body "RTL + TBs green in iverilog; Diamond build fits (<EBR count> EBR, 0 timing errors); bitstream size verified 163489B."
```

---

## Task 7: Host tools — `fpga_link.py` (offline TDD)

**Files:**
- Create: `tools/full_frame_capture/fpga_link.py`
- Create: `tools/full_frame_capture/test_fpga_link.py`

- [ ] **Step 7.1: Write the failing unit test**

`tools/full_frame_capture/test_fpga_link.py` (pure offline — fake sensor):

```python
import pytest
from fpga_link import FpgaRegs, REG_ID, REG_CTRL, REG_LINE_L, REG_LINE_H

class FakeSensor:
    def __init__(self):
        self.calls = []
        self.next = b"\x5a"
    def i2c_read_register(self, dev_addr, reg_addr, read_len=1,
                          reg_addr_size=1, mux_channel=None):
        self.calls.append(dict(dev=dev_addr, reg=reg_addr, n=read_len,
                               size=reg_addr_size, mux=mux_channel))
        return self.next

def test_read_id():
    s = FakeSensor()
    r = FpgaRegs(s, cam=3)
    assert r.read(REG_ID) == 0x5A
    c = s.calls[0]
    assert c == dict(dev=0x5A, reg=0x00, n=1, size=1, mux=3)

def test_write_encodes_reg_and_value_in_16bit_address():
    s = FakeSensor()
    r = FpgaRegs(s, cam=0)
    r.write(REG_CTRL, 0x01)
    c = s.calls[0]
    assert c["size"] == 2 and c["reg"] == (REG_CTRL << 8) | 0x01

def test_set_line_writes_l_then_h():
    s = FakeSensor()
    r = FpgaRegs(s, cam=7)
    r.set_line(0x234)
    assert s.calls[0]["reg"] == (REG_LINE_L << 8) | 0x34
    assert s.calls[1]["reg"] == (REG_LINE_H << 8) | 0x02

def test_read_error_raises():
    s = FakeSensor()
    s.next = False
    with pytest.raises(IOError):
        FpgaRegs(s, cam=0).read(REG_ID)
```

- [ ] **Step 7.2: Run to verify it fails**

Run: `cd tools/full_frame_capture && python -m pytest test_fpga_link.py -q`
Expected: `ModuleNotFoundError: fpga_link` (install pytest first if missing:
`pip install pytest`).

- [ ] **Step 7.3: Implement `tools/full_frame_capture/fpga_link.py`**

```python
"""Register access to the camera FPGA's I2C slave (0x5A) through the sensor
firmware's OW_CMD_I2C_REG_READ passthrough (SDK MotionSensor.i2c_read_register).

Writes use the '16-bit register address' trick: the firmware emits
START,addr+W,[hi],[lo],RESTART,addr+R,read — the slave interprets [hi] as the
register pointer and [lo] as a data write (see design spec)."""

FPGA_ADDR = 0x5A
REG_ID, REG_VERSION, REG_SCRATCH, REG_CTRL = 0x00, 0x01, 0x02, 0x03
REG_LINE_L, REG_LINE_H, REG_LINE_CUR_L, REG_LINE_CUR_H = 0x04, 0x05, 0x06, 0x07
REG_FRAME_CNT, REG_STATUS = 0x08, 0x09
ID_VAL, MAGIC = 0x5A, 0xB6


class FpgaRegs:
    def __init__(self, sensor, cam: int):
        self.sensor = sensor
        self.cam = cam

    def read(self, reg: int, n: int = 1):
        r = self.sensor.i2c_read_register(
            FPGA_ADDR, reg, read_len=n, reg_addr_size=1, mux_channel=self.cam)
        if r is False or r is None:
            raise IOError(f"cam{self.cam}: I2C read reg 0x{reg:02X} failed")
        return r[0] if n == 1 else bytes(r)

    def write(self, reg: int, value: int) -> None:
        r = self.sensor.i2c_read_register(
            FPGA_ADDR, ((reg & 0xFF) << 8) | (value & 0xFF),
            read_len=1, reg_addr_size=2, mux_channel=self.cam)
        if r is False or r is None:
            raise IOError(f"cam{self.cam}: I2C write reg 0x{reg:02X} failed")

    def check_id(self) -> bool:
        try:
            return self.read(REG_ID) == ID_VAL
        except IOError:
            return False

    def scratch_test(self) -> bool:
        self.write(REG_SCRATCH, 0x3C)
        ok = self.read(REG_SCRATCH) == 0x3C
        self.write(REG_SCRATCH, 0xA5)
        return ok

    def set_line(self, line: int) -> None:
        self.write(REG_LINE_L, line & 0xFF)
        self.write(REG_LINE_H, (line >> 8) & 0x0F)

    def get_line(self) -> int:
        lo = self.read(REG_LINE_CUR_L)
        hi = self.read(REG_LINE_CUR_H)
        return ((hi & 0x0F) << 8) | lo

    def set_image_mode(self, start_line: int = 0) -> None:
        self.set_line(start_line)
        self.write(REG_CTRL, 0x01)

    def set_histogram_mode(self) -> None:
        self.write(REG_CTRL, 0x00)

    def frame_count(self) -> int:
        return self.read(REG_FRAME_CNT)
```

- [ ] **Step 7.4: Run to verify it passes**

Run: `cd tools/full_frame_capture && python -m pytest test_fpga_link.py -q`
Expected: `4 passed`

- [ ] **Step 7.5: Commit**

```bash
git add tools/full_frame_capture/fpga_link.py tools/full_frame_capture/test_fpga_link.py
git commit -m "feat: host-side FPGA register access via I2C passthrough (#<N>)"
```

---

## Task 8: Hardware bring-up smoke test (first hardware contact)

**Files:**
- Create: `tools/full_frame_capture/smoke_test.py`

Precondition: 2 sensor modules + console on USB. Check `python -c "import omotion, numpy, PIL"`
inside the SDK environment (`pip install numpy pillow` if needed).

- [ ] **Step 8.1: Write `tools/full_frame_capture/smoke_test.py`**

```python
"""Bring-up smoke test: program new bitstream into ONE camera's FPGA SRAM,
verify the I2C control plane, verify histogram mode still streams.
Usage: python smoke_test.py <bitstream.bit> [--side left] [--cam 0]"""
import argparse, sys, time
from omotion import MotionInterface
from fpga_link import FpgaRegs

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bitstream")
    ap.add_argument("--side", default="left", choices=["left", "right"])
    ap.add_argument("--cam", type=int, default=0)
    a = ap.parse_args()

    iface = MotionInterface(data_dir="smoke_out")
    iface.start(wait=True, wait_timeout=2.0)
    iface.wait_for_ready(console=False, sensors=1, timeout=15)
    sensor = iface.left if a.side == "left" else iface.right
    assert sensor.uart is not None, f"{a.side} sensor not connected"
    mask = 1 << a.cam

    print(f"[1/5] power on cam {a.cam}")
    assert sensor.enable_camera_power(mask)

    print("[2/5] program FPGA SRAM")
    assert sensor.enter_sram_prog_fpga(mask)
    assert sensor.send_bitstream_fpga(a.bitstream)
    assert sensor.program_fpga(mask, manual_process=False)
    assert sensor.exit_sram_prog_fpga(mask)

    print("[3/5] I2C control plane")
    regs = FpgaRegs(sensor, a.cam)
    assert regs.check_id(), "ID register != 0x5A — I2C slave not answering"
    assert regs.read(0x01) == 0x01, "VERSION mismatch"
    assert regs.scratch_test(), "SCRATCH write/read failed"
    print("      ID/VERSION/SCRATCH OK")

    print("[4/5] histogram mode still works (default mode)")
    import queue
    q = queue.Queue()
    sensor.uart.histo.flush_stale_data(expected_size=32833)
    sensor.uart.histo.start_streaming(q, expected_size=32833)
    assert sensor.enable_camera(mask)
    got = None
    t0 = time.time()
    while time.time() - t0 < 5:
        try:
            got = q.get(timeout=0.5); break
        except queue.Empty:
            pass
    assert got, "no histogram packet in 5 s"
    print(f"      histogram packet OK ({len(got)} B), FRAME_CNT={regs.frame_count()}")

    print("[5/5] image mode round-trip (packets flow, tagged)")
    regs.set_image_mode(start_line=0)
    time.sleep(2.0)
    cur = regs.get_line()
    assert cur > 0, f"line counter did not advance (still {cur})"
    print(f"      line counter advanced to {cur}")
    regs.set_histogram_mode()
    sensor.disable_camera(mask)
    sensor.uart.histo.stop_streaming()
    print("SMOKE TEST PASSED")

if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 8.2: Run it against hardware**

Run: `cd tools/full_frame_capture && python smoke_test.py ..\..\HistoFPGAFw\impl1\HistoFPGAFw_impl1.bit --side left --cam 0`
Expected: `SMOKE TEST PASSED`. Debug ladder if not:
- ID fails → check SDA pin drive (scope C3/F3), try `sensor.i2c_scan()` — 0x5A should appear next to 0x36/0x40.
- Histogram fails → regression in the hoist; recheck Task 4 vs a known-good bitstream.
- Line counter stuck → FPGA not receiving frames (camera not streaming) or CDC issue; read STATUS (0x09) and FRAME_CNT.

- [ ] **Step 8.3: Commit + issue comment**

```bash
git add tools/full_frame_capture/smoke_test.py
git commit -m "feat: hardware bring-up smoke test (#<N>)"
gh issue comment <N> -R OpenwaterHealth/openmotion-camera-fpga --body "Bring-up: new bitstream programmed to SRAM over USB->I2C; ID/SCRATCH round-trip OK; histogram regression OK; image-mode line counter advancing. Proceeding to full capture."
```

---

## Task 9: Full capture script

**Files:**
- Create: `tools/full_frame_capture/capture.py`

- [ ] **Step 9.1: Write `tools/full_frame_capture/capture.py`**

```python
"""Capture one lossless full-frame image (1920x1280, 10-bit) from every camera
by streaming one line per camera frame through the histogram SPI envelope.

Usage:
  python capture.py --bitstream <path.bit> --out captures --scene dark
  python capture.py --bitstream <path.bit> --out captures --scene laser
Options: --sides left,right  --cams 0-7 (mask)  --skip-program
"""
import argparse, json, queue, threading, time
from pathlib import Path
import numpy as np
from omotion import MotionInterface
from omotion.MotionProcessing import parse_histogram_packet_structured
from fpga_link import FpgaRegs, MAGIC

WIDTH, HEIGHT, PAIRS = 1920, 1280, 960
EXPECTED_SIZE = 32833


def decode_line(hist: np.ndarray):
    """hist: uint32[1024] from HistogramSample. Returns (line, row) or None."""
    spac = (hist >> 24) & 0xFF
    if int(spac[2]) != MAGIC:
        return None                      # not an image packet
    line = int(spac[0]) | ((int(spac[1]) & 0x0F) << 8)
    pairs = hist[:PAIRS] & 0xFFFFFF
    row = np.empty(WIDTH, np.uint16)
    row[0::2] = (pairs & 0x3FF).astype(np.uint16)
    row[1::2] = ((pairs >> 10) & 0x3FF).astype(np.uint16)
    return line, row


class CameraAccum:
    def __init__(self):
        self.rows = {}
        self.temps = []
        self.frame_ids = []

    def add(self, sample):
        d = decode_line(sample.histogram)
        if d is None:
            return
        line, row = d
        if line < HEIGHT:
            self.rows[line] = row
        self.temps.append(float(sample.temperature_c))
        self.frame_ids.append(sample.frame_id)

    def missing(self):
        return sorted(set(range(HEIGHT)) - set(self.rows))

    def image(self):
        img = np.zeros((HEIGHT, WIDTH), np.uint16)
        for ln, row in self.rows.items():
            img[ln] = row
        return img


def capture_side(sensor, side, cams, timeout_s=90, retry_rounds=5):
    accum = {c: CameraAccum() for c in cams}
    regs = {c: FpgaRegs(sensor, c) for c in cams}
    mask = 0
    for c in cams:
        mask |= 1 << c

    for c in cams:
        regs[c].set_image_mode(start_line=0)

    q = queue.Queue()
    stop = threading.Event()

    def consume():
        while not stop.is_set() or not q.empty():
            try:
                raw = q.get(timeout=0.2)
            except queue.Empty:
                continue
            try:
                pkt = parse_histogram_packet_structured(memoryview(raw))
                for s in pkt.samples:
                    if s.cam_id in accum:
                        accum[s.cam_id].add(s)
            except Exception as e:
                print(f"  [{side}] parse error: {e}")

    sensor.uart.histo.flush_stale_data(expected_size=EXPECTED_SIZE)
    sensor.uart.histo.start_streaming(q, expected_size=EXPECTED_SIZE)
    t = threading.Thread(target=consume, daemon=True)
    t.start()
    assert sensor.enable_camera(mask), f"{side}: enable_camera failed"

    def total_missing():
        return sum(len(accum[c].missing()) for c in cams)

    t0 = time.time()
    last_progress, last_missing = time.time(), total_missing()
    while time.time() - t0 < timeout_s:
        time.sleep(1.0)
        m = total_missing()
        if m == 0:
            break
        if m < last_missing:
            last_missing, last_progress = m, time.time()
        elif time.time() - last_progress > 5.0:
            break                        # stalled — go to retry rounds
    for rnd in range(retry_rounds):
        gaps = {c: accum[c].missing() for c in cams if accum[c].missing()}
        if not gaps:
            break
        print(f"  [{side}] retry round {rnd+1}: " +
              ", ".join(f"cam{c}:{len(g)}" for c, g in gaps.items()))
        for c, g in gaps.items():
            regs[c].set_line(g[0])       # auto-inc replays from first gap
        deadline = time.time() + 40
        while time.time() < deadline and any(accum[c].missing() for c in cams):
            time.sleep(1.0)

    sensor.disable_camera(mask)
    for c in cams:
        try:
            regs[c].set_histogram_mode()
        except IOError:
            pass
    stop.set()
    sensor.uart.histo.stop_streaming()
    sensor.uart.histo.drain_final(expected_size=EXPECTED_SIZE)
    t.join(timeout=3)
    return accum


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bitstream", required=True)
    ap.add_argument("--out", default="captures")
    ap.add_argument("--scene", required=True, choices=["dark", "laser"])
    ap.add_argument("--sides", default="left,right")
    ap.add_argument("--cams", default="0,1,2,3,4,5,6,7")
    ap.add_argument("--skip-program", action="store_true")
    a = ap.parse_args()
    sides = a.sides.split(",")
    cams = [int(c) for c in a.cams.split(",")]
    cam_mask = 0
    for c in cams:
        cam_mask |= 1 << c
    out = Path(a.out) / a.scene
    out.mkdir(parents=True, exist_ok=True)

    need_console = a.scene == "laser"
    iface = MotionInterface(data_dir=str(out / "sdk_data"))
    iface.start(wait=True, wait_timeout=2.0)
    iface.wait_for_ready(console=need_console, sensors=len(sides), timeout=20)
    sensors = {s: getattr(iface, s) for s in sides}
    for s, sen in sensors.items():
        assert sen.uart is not None, f"{s} sensor not connected"

    for s, sen in sensors.items():
        print(f"[{s}] camera power on")
        assert sen.enable_camera_power(cam_mask)
        if not a.skip_program:
            print(f"[{s}] programming FPGA SRAM (mask 0x{cam_mask:02X}) ...")
            assert sen.enter_sram_prog_fpga(cam_mask)
            assert sen.send_bitstream_fpga(a.bitstream)
            assert sen.program_fpga(cam_mask, manual_process=False)
            assert sen.exit_sram_prog_fpga(cam_mask)
        good = []
        for c in cams:
            ok = FpgaRegs(sen, c).check_id()
            print(f"[{s}] cam{c} I2C ID: {'OK' if ok else 'FAIL'}")
            if ok:
                good.append(c)
        sensors[s] = (sen, good)

    if a.scene == "laser":
        print("[laser] applying laser power config")
        assert iface.apply_laser_power(), "apply_laser_power failed"
        for s, (sen, _) in sensors.items():
            assert sen.enable_camera_fsin_ext()
        print("[laser] trigger config:", iface.console.get_trigger_json())
        assert iface.console.start_trigger(), "start_trigger failed"

    results = {}
    try:
        threads, out_acc = [], {}
        for s, (sen, good) in sensors.items():
            th = threading.Thread(
                target=lambda s=s, sen=sen, good=good:
                    out_acc.__setitem__(s, capture_side(sen, s, good)))
            th.start(); threads.append(th)
        for th in threads:
            th.join()
        results = out_acc
    finally:
        if a.scene == "laser":
            iface.console.stop_trigger()
            for s, (sen, _) in sensors.items():
                sen.disable_camera_fsin_ext()

    meta = {"scene": a.scene, "captured_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "width": WIDTH, "height": HEIGHT, "bit_depth": 10, "cameras": {}}
    for s, acc in results.items():
        for c, a_ in acc.items():
            img = a_.image()
            key = f"{s}_cam{c}"
            np.save(out / f"{key}.npy", img)
            from PIL import Image
            Image.fromarray(img, mode="I;16").save(out / f"{key}.png")
            meta["cameras"][key] = {
                "missing_lines": a_.missing(),
                "temperature_c_median": float(np.median(a_.temps)) if a_.temps else None,
                "temperature_c_last": a_.temps[-1] if a_.temps else None,
                "lines_received": len(a_.rows),
            }
            print(f"[{key}] {len(a_.rows)}/{HEIGHT} lines, "
                  f"temp={meta['cameras'][key]['temperature_c_median']}")
    (out / "meta.json").write_text(json.dumps(meta, indent=2))
    print(f"done -> {out}")

if __name__ == "__main__":
    main()
```

- [ ] **Step 9.2: Single-camera hardware validation**

Run: `python capture.py --bitstream ..\..\HistoFPGAFw\impl1\HistoFPGAFw_impl1.bit --out probe --scene dark --sides left --cams 0`
Expected: `left_cam0.npy/.png` with 1280/1280 lines in `probe\dark\meta.json`.
Open the PNG — a dark frame should be near-black with sensor noise; verify
pixel values are 10-bit (max < 1024) via
`python -c "import numpy as np; a=np.load('probe/dark/left_cam0.npy'); print(a.shape, a.min(), a.max())"`.

- [ ] **Step 9.3: Commit**

```bash
git add tools/full_frame_capture/capture.py
git commit -m "feat: 16-camera full-frame capture orchestration (#<N>)"
```

---

## Task 10: The two scene runs (dark + laser)

**Files:** none new (runs of Task 9 script)

- [ ] **Step 10.1: Dark scene, all 16 cameras** — confirm with Ethan the rig is dark/covered, then:

```
python capture.py --bitstream ..\..\HistoFPGAFw\impl1\HistoFPGAFw_impl1.bit --out captures --scene dark
```

Expected: 16 × `.npy` + `.png` under `captures\dark\`, all 1280/1280 lines in meta.json.

- [ ] **Step 10.2: Laser scene, all 16 cameras** — Ethan has authorized console-driven laser-on. Announce before running; verify `apply_laser_power` and `start_trigger` return True; `stop_trigger` runs in a `finally`.

```
python capture.py --bitstream ..\..\HistoFPGAFw\impl1\HistoFPGAFw_impl1.bit --out captures --scene laser --skip-program
```

(`--skip-program` — SRAM already holds the image from step 10.1; power stayed on.)
Expected: 16 more images under `captures\laser\`, speckle visible in the PNGs.

- [ ] **Step 10.3: Issue comment with capture stats**

```bash
gh issue comment <N> -R OpenwaterHealth/openmotion-camera-fpga --body "Captured 32/32 full frames (16 cams x dark+laser). <lines stats, temps range, any retried lines>."
```

---

## Task 11: Report generation

**Files:**
- Create: `tools/full_frame_capture/report.py`

- [ ] **Step 11.1: Write `tools/full_frame_capture/report.py`**

```python
"""Build an HTML report embedding display previews of all captured frames.
Raw data stays in the lossless .npy/.png files; previews are normalized 8-bit.
Usage: python report.py --captures captures --out captures/report.html"""
import argparse, base64, io, json
from pathlib import Path
import numpy as np
from PIL import Image

def preview_b64(npy_path: Path, max_w=480) -> tuple[str, dict]:
    img = np.load(npy_path).astype(np.float64)
    stats = dict(min=int(img.min()), max=int(img.max()),
                 mean=round(float(img.mean()), 2))
    lo, hi = np.percentile(img, [1, 99.5])
    disp = np.clip((img - lo) / max(hi - lo, 1) * 255, 0, 255).astype(np.uint8)
    im = Image.fromarray(disp, mode="L")
    im = im.resize((max_w, int(max_w * img.shape[0] / img.shape[1])))
    buf = io.BytesIO(); im.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode(), stats

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--captures", default="captures")
    ap.add_argument("--out", default="captures/report.html")
    a = ap.parse_args()
    root = Path(a.captures)
    scenes = [d for d in ["dark", "laser"] if (root / d / "meta.json").exists()]
    html = ["<!doctype html><meta charset='utf-8'>",
            "<title>Open-Motion 16-camera full-frame capture</title>",
            "<style>body{font-family:sans-serif;margin:24px;background:#111;color:#eee}",
            ".grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}",
            ".card{background:#1c1c1c;padding:8px;border-radius:8px}",
            ".card img{width:100%;image-rendering:pixelated}",
            "td,th{padding:2px 10px;text-align:right}h2{margin-top:40px}",
            ".warn{color:#f80}</style>"]
    for scene in scenes:
        meta = json.loads((root / scene / "meta.json").read_text())
        html.append(f"<h1>Scene: {scene}</h1>")
        html.append(f"<p>Captured {meta['captured_at']} — "
                    f"{meta['width']}x{meta['height']}, {meta['bit_depth']}-bit "
                    f"lossless (raw values in .npy/.png files; previews are "
                    f"1-99.5 percentile normalized)</p><div class='grid'>")
        for key in sorted(meta["cameras"]):
            m = meta["cameras"][key]
            b64, st = preview_b64(root / scene / f"{key}.npy")
            miss = len(m["missing_lines"])
            warn = f"<div class='warn'>{miss} lines missing</div>" if miss else ""
            temp = m["temperature_c_median"]
            html.append(
                f"<div class='card'><b>{key}</b> — "
                f"{temp:.1f} °C<br>min {st['min']} / max {st['max']} / "
                f"mean {st['mean']}{warn}"
                f"<img src='data:image/png;base64,{b64}'>"
                f"<div><a href='{scene}/{key}.png'>png</a> · "
                f"<a href='{scene}/{key}.npy'>npy</a></div></div>")
        html.append("</div>")
    Path(a.out).write_text("\n".join(html), encoding="utf-8")
    print(f"report -> {a.out}")

if __name__ == "__main__":
    main()
```

- [ ] **Step 11.2: Generate + deliver**

Run: `python report.py --captures captures --out captures/report.html`
Then render the report for Ethan (Artifact tool or SendUserFile) along with the
capture directory location. Verify: 32 preview cards, temperatures on each, no
(or documented) missing-line warnings.

- [ ] **Step 11.3: Commit**

```bash
git add tools/full_frame_capture/report.py
git commit -m "feat: HTML capture report generator (#<N>)"
```

---

## Task 12: Close out

- [ ] **Step 12.1: Re-run all sims + unit tests** (regression gate)

```
cd test_projects && i2c_line\run.bat i2c_slave_tb && i2c_line\run.bat fpga_regs_tb && i2c_line\run.bat line_capture_tb && i2c_line\run.bat integration_tb
cd ..\tools\full_frame_capture && python -m pytest test_fpga_link.py -q
```

All `ALL TESTS PASSED` / `4 passed`.

- [ ] **Step 12.2: PR**

```bash
git push -u origin feature/<N>-i2c-line-readout
gh pr create -R OpenwaterHealth/openmotion-camera-fpga --base main \
  --title "feat: I2C slave control plane + line-chunked full-frame image readout" \
  --body "Refs #<N>

- Soft I2C slave @0x5A (clk_osc domain), register map per spec
- line_capture: one image line per frame in the 4100B histogram SPI envelope (zero FW changes)
- Serializer hoisted to top with mode mux; histogram logic bit-identical
- iverilog TBs (slave, regs, capture, integration) + Diamond headless build
- tools/full_frame_capture: bring-up + 16-camera capture + HTML report

Validated on hardware: 32/32 full frames captured (dark + laser scenes).

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

- [ ] **Step 12.3: Move issue to In review, final comment with results + report location.**

```bash
gh project item-edit --id <ITEM_ID> --project-id PVT_kwDOAif52c4BVgTu \
  --field-id PVTSSF_lADOAif52c4BVgTuzhQ7qcU --single-select-option-id 5ef0dc97
```

---

## Verification summary (spec → task map)

| Spec requirement | Task |
|---|---|
| I2C slave 0x5A, write/read/auto-inc/STOP recovery | 1 |
| Register map + LINE commit + auto-inc + FRAME_CNT + CDC publish | 2 |
| line_capture: capture, fv-fall serialize, 4100B framing, spacers, CDC | 3 |
| Histogram bit-identical, serializer hoist, top wiring, SDA open-drain | 4 |
| End-to-end I2C→packet→auto-inc→rewind | 5 |
| Diamond fit/timing, bitstream == 163489 B | 6 |
| Host control plane (write-trick) | 7 (offline) + 8 (hardware) |
| Zero-FW-change bring-up, histogram regression | 8 |
| 16-camera capture, gap re-request, lossless outputs, temps | 9, 10 |
| 32-image report | 11 |
| Issue tracking / PR per CLAUDE.md | 0, 12 |
