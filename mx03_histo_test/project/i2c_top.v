
`timescale 1ns / 1ps
module i2c_top (
   input  wire       clk_i,
   input  wire       rst_n,
   inout  wire       scl,
   inout  wire       sda,
   output  wire reset_sensor,
   output    reset_crosslink,
   output      q,
   output wire  config_done
   );

   wire        i2c_done;
   wire        cmd;
   wire [6:0]  addr_dev;
   wire [7:0]  addr_reg_H;
   wire [7:0]  addr_reg_L;
   wire [7:0]  data_wr_H;
   wire [7:0]  data_wr_L;
   wire [7:0]  data_rd;
   wire        i2c_rqt;
   
   assign clk = clk_i;


reg [23:0] reset_delay;
wire reset_n;
   
always @ (posedge clk or negedge rst_n)
	if (!rst_n)
		reset_delay <= 0;
	else if (!reset_delay[23])
		reset_delay <= reset_delay + 1;
	
assign reset_n = reset_delay[23];
wire i2c_reset_n;
reg [10:0] i2c_delay;

always @ (posedge clk or negedge reset_n)
	if (!reset_n)
		i2c_delay <= 0;
	else if (!i2c_delay[10])
		i2c_delay <= i2c_delay + 1;
	
assign i2c_reset_n = i2c_delay[10];

wire crosslink_reset_n;
reg [16:0] crosslink_delay;

always @ (posedge clk or negedge reset_n)
	if (!reset_n)
		crosslink_delay <= 0;
	else if (!crosslink_delay[16])
		crosslink_delay <= crosslink_delay + 1;

assign crosslink_reset_n = crosslink_delay[16];

   
   i2c_ctrl i2c_ctrl_inst (     
      .rst_n         (i2c_reset_n ),
      .clk           (clk         ),
      .config_done   (config_done ),
      .cmd           (cmd         ),
      .addr_dev      (addr_dev    ),
      .addr_reg_H    (addr_reg_H  ),
      .addr_reg_L    (addr_reg_L  ),
      .data_wr_H     (data_wr_H   ),
      .data_wr_L     (data_wr_L   ),
      .data_rdy      (data_rdy    ),
      .data_rd       (data_rd     ),
      .i2c_done      (i2c_done    ),
      .i2c_rqt       (i2c_rqt     )    
        );
   
   i2c_core i2c_core ( 
      .rst_n            (i2c_reset_n    ),                             
      .clk              ( clk       ),                                
      .scl              (scl        ),                                 
      .sda              (sda        ),                                 
      .i2c_rqt          (i2c_rqt    ),                     
      .cmd              (cmd        ),                             
      .addr_dev         (addr_dev   ),                   
      .addr_reg_H       (addr_reg_H ),                   
      .addr_reg_L       (addr_reg_L ),               
      .data_wr_H        (data_wr_H  ),                     
      .data_wr_L        (data_wr_L  ),               
      .data_rd          (data_rd    ),                         
      .data_rdy         (data_rdy   ),                       
      .i2c_done         (i2c_done   )                        
        );                                       
	

reg [28:0]count;

always @( posedge clk or negedge rst_n)
	if (!rst_n)
		count <= 0;
	else
		count <= count+1;

assign q = count[28];


assign i2c_data_rd= data_rd;
assign reset_sensor = reset_n;
assign reset_crosslink = crosslink_reset_n;
   
endmodule
 