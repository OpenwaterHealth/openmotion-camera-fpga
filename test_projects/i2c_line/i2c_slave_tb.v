`timescale 1ns / 1ps
`include "../HistoFPGAFw/i2c_slave.v"

module i2c_slave_tb;
  reg clk = 0, reset = 1;
  integer clk_half = 21;               // ns: 21 -> ~24 MHz oscillator
  always #(clk_half) clk = ~clk;

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

  // T7 monitor: while foreign_phase is set, the DUT must never drive SDA
  reg foreign_phase = 0;
  always @(posedge dut_sda_oe)
    if (foreign_phase) begin
      errors = errors + 1;
      $display("FAIL: T7 sda_oe asserted during foreign traffic");
    end

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

    // T7: complete foreign transaction whose data bytes look like our address
    // (0xB4 = 0x5A<<1|W, 0xB5 = 0x5A<<1|R) incl. a repeated START to another
    // foreign address. DUT must stay off the bus the whole time (monitor above).
    foreign_phase = 1;
    i2c_start; i2c_write_byte({7'h36,1'b0}, ack); check(!ack, "T7 foreign addr1 no ack");
    i2c_write_byte(8'hB4, ack); check(!ack, "T7 lookalike 0xB4 no ack");
    i2c_write_byte(8'hB5, ack); check(!ack, "T7 lookalike 0xB5 no ack");
    i2c_start; i2c_write_byte({7'h40,1'b0}, ack); check(!ack, "T7 foreign addr2 no ack");
    i2c_write_byte(8'hB4, ack); check(!ack, "T7 lookalike after Sr no ack");
    i2c_stop; #2000;
    foreign_phase = 0;
    // normal read of reg 0 still works afterwards
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); check(ack, "T7 addr ack after foreign");
    i2c_write_byte(8'h00, ack);
    i2c_start; i2c_write_byte({7'h5A,1'b1}, ack);
    i2c_read_byte(1'b0, rb); check(rb == 8'h10, "T7 read reg0 after foreign");
    i2c_stop; #2000;

    // T8: master ACKs a read byte (slave preps next byte 0x13 — MSB 0, so it
    // holds SDA low) then abandons. Bus clear: 9 SCL pulses with SDA released,
    // then STOP, then a clean write+readback must succeed.
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack);
    i2c_write_byte(8'h02, ack);
    i2c_start; i2c_write_byte({7'h5A,1'b1}, ack); check(ack, "T8 rd addr ack");
    i2c_read_byte(1'b1, rb); check(rb == 8'hCA, "T8 first byte");
    m_sda_drive_low = 0;                    // master releases SDA, walks away
    for (i = 0; i < 9; i = i + 1) begin
      #(T_I2C); m_scl = 1; #(2*T_I2C); m_scl = 0; #(T_I2C);
    end
    i2c_stop; #2000;
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); check(ack, "T8 recover addr ack");
    i2c_write_byte(8'h01, ack); i2c_write_byte(8'h5F, ack);
    i2c_stop; #2000;
    check(regfile[1] == 8'h5F, "T8 write after bus clear");
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); i2c_write_byte(8'h01, ack);
    i2c_start; i2c_write_byte({7'h5A,1'b1}, ack);
    i2c_read_byte(1'b0, rb); check(rb == 8'h5F, "T8 readback after bus clear");
    i2c_stop; #2000;

    // T9: bus-speed margin — 1 MHz bus (T_I2C=250) with a slowed ~21.7 MHz clk
    T_I2C = 250; clk_half = 23;
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); check(ack, "T9 addr ack @1MHz");
    i2c_write_byte(8'h08, ack); check(ack, "T9 ptr ack @1MHz");
    i2c_write_byte(8'h5C, ack); check(ack, "T9 data ack @1MHz");
    i2c_stop; #2000;
    check(regfile[8] == 8'h5C, "T9 write @1MHz");
    i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); i2c_write_byte(8'h08, ack);
    i2c_start; i2c_write_byte({7'h5A,1'b1}, ack); check(ack, "T9 rd addr ack @1MHz");
    i2c_read_byte(1'b1, rb); check(rb == 8'h5C, "T9 rd reg8 @1MHz");
    i2c_read_byte(1'b0, rb); check(rb == 8'h19, "T9 rd reg9 autoinc @1MHz");
    i2c_stop; #2000;
    T_I2C = 1250; clk_half = 21;            // restore defaults

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d ERRORS", errors);
    $finish;
  end
endmodule
