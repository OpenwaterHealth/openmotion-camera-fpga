`timescale 1ns / 1ps
module i2c_ctrl (
   input  wire       rst_n      ,
   input  wire       clk        ,
   output wire       config_done,
   output reg        cmd        ,
   output reg  [6:0] addr_dev   ,
   output reg  [7:0] addr_reg_H ,
   output reg  [7:0] addr_reg_L ,
   output reg  [7:0] data_wr_H  ,
   output reg  [7:0] data_wr_L  ,
   input  wire       data_rdy   ,
   input  wire [7:0] data_rd    ,
   input  wire       i2c_done   ,
   output reg        i2c_rqt

   )/* synthesis syn_preserve=1 */
   /* synthesis syn_hier = "hard" */;


   reg               i2c_done_s1;
   reg [11:0]         step_cnt;
   wire              i2c_done_neg;

   
   parameter  
      WRITE= 1,
      READ = 0;

   
   parameter ADDR_SENSOR  =7'h36;

   always@(posedge clk ) i2c_done_s1<=i2c_done;
   assign i2c_done_neg = !i2c_done && i2c_done_s1;
  
   always@(posedge clk or  negedge rst_n) begin
      if(!rst_n) begin
         i2c_rqt <= 0;
         step_cnt<=0;   
      end
      else if ( step_cnt<=91) begin // TBD: how many registers need to be configured.
        if(i2c_done_neg) begin
           step_cnt<=step_cnt+1; 
           i2c_rqt <= 1'b0;
        end
        else
           i2c_rqt <= 1'b1;
      end
      else if (i2c_done_neg)
         i2c_rqt <= 1'b0;
   end
   
assign config_done = (step_cnt==84);

// TBD: how many registers need to be configured. slave_addr=0x20 (write 8-bit) slave_addr=0x21 (read 8-bit)
// i2c write format: start slave_addr ACK reg_addr_byte1 ACK reg_addr_byte2 ACK write_data_byte1 ACK write_data_byte2 ACK stop
   always@(*) begin
         case( step_cnt)
			 // ov5647
			 
			// power on			 
            0:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h00; data_wr_H=8'h0F; end
            1:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h01; data_wr_H=8'hFF; end
            2:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h02; data_wr_H=8'hEF; end

			// 1080p30_10bpp
            3:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h01; addr_reg_L=8'h00; data_wr_H=8'h00; end
			4:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h01; addr_reg_L=8'h03; data_wr_H=8'h01; end
			5:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h34; data_wr_H=8'h1a; end
			6:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h35; data_wr_H=8'h21; end
			7:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h36; data_wr_H=8'h62; end
			8:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h3c; data_wr_H=8'h11; end
			9:   begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h31; addr_reg_L=8'h06; data_wr_H=8'hf5; end
			10:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h21; data_wr_H=8'h06; end
			11:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h20; data_wr_H=8'h00; end
			12:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h27; data_wr_H=8'hec; end
			13:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h0c; data_wr_H=8'h03; end
			14:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h12; data_wr_H=8'h5b; end
			15:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h18; data_wr_H=8'h04; end
			16:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h50; addr_reg_L=8'h00; data_wr_H=8'h06; end
			17:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h50; addr_reg_L=8'h02; data_wr_H=8'h41; end
			18:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h50; addr_reg_L=8'h03; data_wr_H=8'h08; end
			19:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h5a; addr_reg_L=8'h00; data_wr_H=8'h08; end
			20:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h00; data_wr_H=8'h00; end
			21:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h01; data_wr_H=8'h00; end
			22:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h02; data_wr_H=8'h00; end
			23:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h16; data_wr_H=8'h08; end
			24:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h17; data_wr_H=8'he0; end
			25:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h18; data_wr_H=8'h44; end
			26:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h1c; data_wr_H=8'hf8; end
			27:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h1d; data_wr_H=8'hf0; end
			28:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h18; data_wr_H=8'h00; end
			29:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h19; data_wr_H=8'hf8; end
			30:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3c; addr_reg_L=8'h01; data_wr_H=8'h80; end
			31:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3b; addr_reg_L=8'h07; data_wr_H=8'h0c; end
			32:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h0c; data_wr_H=8'h09; end
			33:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h0d; data_wr_H=8'h70; end
			34:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h14; data_wr_H=8'h11; end
			35:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h15; data_wr_H=8'h11; end
			36:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h08; data_wr_H=8'h64; end
			37:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h09; data_wr_H=8'h12; end
			38:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h08; data_wr_H=8'h07; end
			39:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h09; data_wr_H=8'h80; end
			40:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h0a; data_wr_H=8'h04; end
			41:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h0b; data_wr_H=8'h38; end
			42:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h00; data_wr_H=8'h01; end
			43:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h01; data_wr_H=8'h5c; end
			44:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h02; data_wr_H=8'h01; end
			45:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h03; data_wr_H=8'hb2; end
			46:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h04; data_wr_H=8'h08; end
			47:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h05; data_wr_H=8'he3; end
			48:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h06; data_wr_H=8'h05; end
			49:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h07; data_wr_H=8'hf1; end
			50:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h11; data_wr_H=8'h04; end
			51:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h38; addr_reg_L=8'h13; data_wr_H=8'h02; end
			52:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h30; data_wr_H=8'h2e; end
			53:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h32; data_wr_H=8'he2; end
			54:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h33; data_wr_H=8'h23; end
			55:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h34; data_wr_H=8'h44; end
			56:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h36; data_wr_H=8'h06; end
			57:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h20; data_wr_H=8'h64; end
			58:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h21; data_wr_H=8'he0; end
			59:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h36; addr_reg_L=8'h00; data_wr_H=8'h37; end
			60:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h04; data_wr_H=8'ha0; end
			61:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h03; data_wr_H=8'h5a; end
			62:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h15; data_wr_H=8'h78; end
			63:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h17; data_wr_H=8'h01; end
			64:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h31; data_wr_H=8'h02; end
			65:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h0b; data_wr_H=8'h60; end
			66:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h37; addr_reg_L=8'h05; data_wr_H=8'h1a; end
			67:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3f; addr_reg_L=8'h05; data_wr_H=8'h02; end
			68:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3f; addr_reg_L=8'h06; data_wr_H=8'h10; end
			69:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3f; addr_reg_L=8'h01; data_wr_H=8'h0a; end
			70:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h08; data_wr_H=8'h01; end
			71:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h09; data_wr_H=8'h4b; end
			72:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h0a; data_wr_H=8'h01; end
			73:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h0b; data_wr_H=8'h13; end
			74:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h0d; data_wr_H=8'h04; end
			75:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h0e; data_wr_H=8'h03; end
			76:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h0f; data_wr_H=8'h58; end
			77:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h10; data_wr_H=8'h50; end
			78:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h1b; data_wr_H=8'h58; end
			79:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h1e; data_wr_H=8'h50; end
			80:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h11; data_wr_H=8'h60; end
			81:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h3a; addr_reg_L=8'h1f; data_wr_H=8'h28; end
			82:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h40; addr_reg_L=8'h01; data_wr_H=8'h02; end
			83:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h40; addr_reg_L=8'h04; data_wr_H=8'h04; end
			84:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h40; addr_reg_L=8'h00; data_wr_H=8'h09; end
			85:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h48; addr_reg_L=8'h37; data_wr_H=8'h19; end
			86:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h48; addr_reg_L=8'h00; data_wr_H=8'h34; end
			87:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h35; addr_reg_L=8'h03; data_wr_H=8'h03; end
			88:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h01; addr_reg_L=8'h00; data_wr_H=8'h01; end

			// stream on
			89:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h42; addr_reg_L=8'h02; data_wr_H=8'h00; end
			90:  begin cmd=WRITE; addr_dev=ADDR_SENSOR; addr_reg_H=8'h30; addr_reg_L=8'h0d; data_wr_H=8'h00; end
						
            default:  begin ;end    
         endcase


   end                                                                                                      
                                                                                                            
                                                                                                            
endmodule                
