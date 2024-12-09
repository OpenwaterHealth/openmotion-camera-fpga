`timescale 1ns / 1ps
`include "i2c_pipeline/i2c_regmap.v"

module tb;

   // Inputs
   reg rst_n;
   reg clk;
   reg data_rdy;
   reg [7:0] data_rd;
   reg i2c_done=0;
   reg register_list;

   // Outputs
   wire config_done;
   wire cmd;
   wire [6:0] addr_dev;
   wire [7:0] addr_reg_H;
   wire [7:0] addr_reg_L;
   wire [7:0] data_wr_H;
   wire [7:0] data_wr_L;
   wire i2c_rqt;

   // Instantiate the i2c_regmap module
   i2c_regmap dut (
      .rst_n(rst_n),
      .clk(clk),
      .config_done(config_done),
      .cmd(cmd),
      .i2c_done(i2c_done),
      .i2c_rqt(i2c_rqt),
      .register_list(register_list),
      
      .addr_dev(addr_dev),
      .addr_reg_H(addr_reg_H),
      .addr_reg_L(addr_reg_L),
      .data_wr_H(data_wr_H),
      .data_wr_L(data_wr_L),
      .data_rd(data_rd)
   );

   // Clock generation
   always begin
      #3 clk = ~clk;
   end
   always begin
      #10 i2c_done = ~i2c_done;
   end
   
  initial begin
    $dumpfile("out/i2c_regmap_tb.vcd");
    $dumpvars(0, tb);  // Dump all signals
  end
   // Initialize inputs
   initial begin
      clk = 0;
      data_rdy = 0;
      data_rd = 0;
      register_list = 0;

      // Reset
      rst_n = 0;
      #20 rst_n = 1;
      
      #100 rst_n = 0;
      register_list = 1;
      #20 rst_n = 1;
      
      #1000 $finish;
   end

endmodule
