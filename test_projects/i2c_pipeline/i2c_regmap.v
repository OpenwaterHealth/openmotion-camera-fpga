`include "i2c_pipeline/rom.v"

`timescale 1ns / 1ps
module i2c_regmap (
    input wire rst_n,  // active low
    input wire clk,  // clock
    output wire config_done,  // goes high at end
    output reg cmd,  // ***read/write
    input wire i2c_done,  // signal from master to tell this when to increment
    output reg  i2c_rqt,      // high when a new message is available, low after new message is sent and reset state
    input register_list,

    output reg  [6:0] addr_dev,    // ***device address
    output reg  [7:0] addr_reg_H,  // ***device address
    output reg  [7:0] addr_reg_L,  // ***device address
    output reg  [7:0] data_wr_H,   // ***device address
    output reg  [7:0] data_wr_L,   // ***device address
    input  wire [7:0] data_rd,      // ***device address
	
	output wire [11:0] step_number
)
  /* synthesis syn_preserve=1 */
  /* synthesis syn_hier = "hard" */;

  parameter WRITE = 1, READ = 0;

  parameter GET_TEMP = 0, SET_MAP = 1;
  parameter ADDR_SENSOR = 7'h36;
  wire [23:0]  MAP_LENGTH = (register_list == SET_MAP) ? 1100 : 3;  //645;

  reg  i2c_done_prev;
  wire i2c_done_negedge;
  always @(posedge clk) i2c_done_prev <= i2c_done;
  assign i2c_done_negedge = !i2c_done && i2c_done_prev;  // true if i2c_done has a negative edge 

  reg [11:0] step_cnt;
  assign step_number = step_cnt;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      i2c_rqt  <= 0;
      step_cnt <= 0;
    end else if (step_cnt <= MAP_LENGTH - 1) begin
      if (i2c_done_negedge) begin
        step_cnt <= step_cnt + 1;
        i2c_rqt  <= 1'b0;
      end else i2c_rqt <= 1'b1;
    end else if (i2c_done_negedge) i2c_rqt <= 1'b0;
  end

  assign config_done = (step_cnt == MAP_LENGTH);

  //Set up ROM for long memory list
  wire rom_enable = (register_list == SET_MAP);
  wire [23:0] rom_data_out;
  wire rom_rst = ~rst_n;
  rom_i rom_s (
	  .Address(step_cnt),
	  .OutClock(clk),
	  .OutClockEn(rom_enable),
	  .Reset(rst_n),
	  .Q(rom_data_out)
  );

  // TBD: how many registers need to be configured. slave_addr=0x20 (write 8-bit) slave_addr=0x21 (read 8-bit)
  // i2c write format: start slave_addr ACK reg_addr_byte1 ACK reg_addr_byte2 ACK write_data_byte1 ACK write_data_byte2 ACK stop
  always @(*) begin
    case (register_list)
      GET_TEMP: begin
        case (step_cnt)
          0: begin
            cmd = READ;
            addr_dev = ADDR_SENSOR;
            addr_reg_H = 8'h4d;
            addr_reg_L = 8'h2a;
          end
          1: begin
            cmd = READ;
            addr_dev = ADDR_SENSOR;
            addr_reg_H = 8'h4d;
            addr_reg_L = 8'h2b;
          end
          2: begin
            cmd = READ;
            addr_dev = ADDR_SENSOR;
            addr_reg_H = 8'h4d;
            addr_reg_L = 8'h2c;
          end

          default: begin
            ;
          end
        endcase
      end
      SET_MAP: begin
        cmd = WRITE;
        addr_dev = ADDR_SENSOR;

        addr_reg_H = rom_data_out[23:16];
        addr_reg_L = rom_data_out[15:8];
        data_wr_H =  rom_data_out[7:0];
      end

      default: begin
        ;
      end
    endcase
  end

endmodule
