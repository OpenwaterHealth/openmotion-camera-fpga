///////////////////////////////////////////////////////////////////////
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// ====================================================================
// Copyright 2015 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
//
// This confidential and proprietary software may be used only as
// authorised by a licensing agreement from Lattice Semiconductor 
// Corporation.
// The entire notice above must be reproduced on all authorized
// copies and copies may only be made to the extent permitted
// by a licensing agreement from Lattice Semiconductor Corporation.
//
// ====================================================================
// File Details         
// ====================================================================
// Project     : PDM->PCM converter
// File        : PDM_iddr.v
// Title       : 
// 
// Description : PDM left/right split module
//                    
// Additional info. : 
// ====================================================================

`timescale 1ns/100ps

module PDM_iddr     (rst,
                     clk,
                     din,
                     dout_L,
                     dout_R
                    );

input                      rst;
input                      clk;
input                      din;
output                     dout_L;
output                     dout_R;

reg                        dout_R_p1;
reg                        dout_R_p2;
reg                        dout_L_p1;
reg                        dout_L_p2;


// Right channel
always @(posedge clk or posedge rst)
begin
   if(rst) begin
      dout_R_p1 <= 1'b0;
      dout_R_p2 <= 1'b0;
   end else begin
      dout_R_p1 <= din;
      dout_R_p2 <= dout_R_p1;
   end
end

// Left channel
always @(negedge clk or posedge rst)
begin
   if(rst) begin
      dout_L_p1 <= 1'b0;
   end else begin
      dout_L_p1 <= din;
   end
end
always @(posedge clk or posedge rst)
begin
   if(rst) begin
      dout_L_p2 <= 1'b0;
   end else begin
      dout_L_p2 <= dout_L_p1;
   end
end

assign dout_L = dout_L_p2;
assign dout_R = dout_R_p2;

endmodule
