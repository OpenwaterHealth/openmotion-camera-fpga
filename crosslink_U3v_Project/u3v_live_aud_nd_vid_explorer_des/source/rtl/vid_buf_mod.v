////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	(c) 2020-2021, Cypress Semiconductor Corporation (an Infineon company) or an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
//
//	This software, including source code, documentation and related materials ("Software") is owned by Cypress Semiconductor Corporation or one of its affiliates
//	("Cypress") and is protected by and subject to worldwide patent protection (United States and foreign), United States copyright laws and international treaty
//	provisions.  Therefore, you may use this Software only as provided in the license agreement accompanying the software package from which you obtained this
//	Software ("EULA").
//	If no EULA applies, Cypress hereby grants you a personal, non-exclusive, non-transferable license to copy, modify, and compile the Software source code solely
//	for use in connection with Cypress's integrated circuit products.  Any reproduction, modification, translation, compilation, or representation of this Software
//	except as specified above is prohibited without the express written permission of Cypress.
//
//	Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress reserves the right to make changes to the Software without notice. Cypress does
//	not assume any liability arising out of the application or use of the Software or any product or circuit described in the Software. Cypress does not authorize
//	its products for use in any products where a malfunction or failure of the Cypress product may reasonably be expected to result in significant property damage,
//	injury or death ("High Risk Product"). By including Cypress's product in a High Risk Product, the manufacturer of such system or application assumes all risk of
//	such use and in doing so agrees to indemnify Cypress against all liability.
//
//	Design Name:	SX3 Explorer Crosslink Kit - Video Only
//	Module Name:	vid_buf_mod
//	Target Devices:	LIF-MD6000
//	Description:	This modules acts as the video buffer to store the video data when the SlaveFIFO interface is busy.
//					This module resets its video buffers in case of buffer overflow.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module vid_buf_mod
(
	input			clk_i,
	input			rstn_i,

	input			cam_app_en_i,
	input			cam_fv_i,
	input			cam_lv_i,
	input [31:0]	cam_data_i,

    // From GPIF
    input           vid_fifo_rd_req_i,
    input           pktend_st_i,
	// input			gpif_fifo_almostfull_i,

    // To GPIF
	output [15:0]	vid_fifo_rd_data_o /* buf_data_o */,
	output reg		vid_fifo_data_vld_o /* buf_vld_o */,
	output			cam_fifo_overflow_o,
	output			vid_fifo_almost_empty_o,
	output			vid_fifo_almost_full_o,
	output reg		cam_fv_pe_pl_o,
	output reg		cam_fv_ne_pl_o
);

//-----------------------------------------------------------------------------
//	Wire, Register and local parameter declarations
//-----------------------------------------------------------------------------

reg [31:0]	cam_data_r=1'd0;
reg			cam_fv_r1=1'd0;
reg			cam_fv_r2=1'd0;
reg			cam_lv_r=1'd0;
// reg			vid_fifo_rden_r=1'd0;
// reg			vid_fifo_rden_r1=1'd0;
// reg			vid_fifo_rdvld_r=1'd0;
reg			cam_fifo_rst=1'd1;
reg			cam_fifo_overflow=1'd0;
reg			cam_data_en=1'd0;
reg	[5:0]	xtra_dt_en='d0;

reg         vid_fifo_rd_req_f1;

// wire 		vid_fifo_rden;
wire 		vid_fifo_almost_empty;
// wire 		vid_fifo_AlmostFull;
wire 		vid_fifo_empty;
wire 		vid_fifo_full;

// assign buf_vld_o = vid_fifo_rdvld_r;
assign cam_fifo_overflow_o = cam_fifo_overflow;

//	Excess data of 30 bytes are written into the buffer at the frame end to compensate for the almost empty flag
//	used to enable the read from the FIFO in the gpif_interface_top module. Minimum of 12 bytes has to be written at the end(based on Almost empty setting)
always @(posedge clk_i)
	if(cam_fv_r2 & (!cam_fv_r1))	// Frame end
		xtra_dt_en <= 6'd30;
	else if(xtra_dt_en>6'd0)
		xtra_dt_en <= xtra_dt_en - 1'd1;

always @(posedge clk_i) begin
	if(cam_data_en) begin
		cam_lv_r <= (cam_lv_i || (xtra_dt_en>6'd0)) /*& (!vid_fifo_almost_full_o)*/;
	end
	else begin
		cam_lv_r <= 1'b0;
	end
end

// always @(posedge clk_i) begin
// 	vid_fifo_rden_r <= !(gpif_fifo_almostfull_i||vid_fifo_empty);
// 	vid_fifo_rden_r1 <= vid_fifo_rden;
// 	vid_fifo_rdvld_r <= vid_fifo_rden_r1;
// end
//
// assign vid_fifo_rden = vid_fifo_rden_r & (!vid_fifo_empty);

always @ (posedge clk_i or negedge rstn_i)
  begin
    if (~rstn_i)
      begin
        vid_fifo_rd_req_f1  <= 1'b0;
        vid_fifo_data_vld_o <= 1'b0;
      end
    else
      begin
        vid_fifo_rd_req_f1  <= vid_fifo_rd_req_i;
        vid_fifo_data_vld_o <= vid_fifo_rd_req_f1;
      end
  end

//	Buffer Overflow Flag
always @(posedge clk_i) begin
	if(!cam_app_en_i)
		cam_fifo_overflow <= 1'd0;
	else if(cam_lv_r  & vid_fifo_full)
		cam_fifo_overflow <= 1'd1;
	else if(!cam_data_en)
		cam_fifo_overflow <= 1'd0;
end

//	Generation of Camera Data Enable
always @(posedge clk_i, negedge rstn_i) begin
	if(!rstn_i)
		cam_data_en <= 1'd0;
	else if((!cam_app_en_i) || cam_fifo_overflow)
		cam_data_en <= 1'd0;
	else if(cam_fv_r1 & (!cam_fv_r2))
		cam_data_en <= 1'd1;
end

//	Generation of FIFO reset
always @(posedge clk_i) begin
	if(cam_fifo_overflow||(!cam_app_en_i)|| pktend_st_i)
		cam_fifo_rst <= 1'd1;
	else if(((!cam_fv_r2) & cam_fv_r1)&(!vid_fifo_empty))	// When the FIFO is not empty during frame start
		cam_fifo_rst <= 1'd1;
	else
		cam_fifo_rst <= 1'd0;
end

always @(posedge clk_i) begin
	cam_fv_r1      <= cam_fv_i;
	cam_fv_r2      <= cam_fv_r1;
	cam_fv_pe_pl_o <= ( ( cam_fv_r1 ) & ( ~cam_fv_r2 ) );
	cam_fv_ne_pl_o <= ( ( ~cam_fv_r1 ) & ( cam_fv_r2 ) );
end

always @(posedge clk_i)
	cam_data_r <= cam_data_i;

//	Video Buffer :
//	Depth - 2048
//	Width - 16 bits
//	Buffer Size - 4096 bytes
//	Buffer size is set as 4096 bytes to store minimum of 1 line of max resolution(1080p)
vid_buf_fifo vid_buf_fifo
(
    .vid_fifo_Data			(cam_data_r),
    .vid_fifo_Q				(vid_fifo_rd_data_o),
    .vid_fifo_AlmostEmpty	(vid_fifo_almost_empty_o),
    .vid_fifo_AlmostFull	(vid_fifo_almost_full_o),
    .vid_fifo_Empty			(vid_fifo_empty),
    .vid_fifo_Full			(vid_fifo_full),
    .vid_fifo_RPReset		(cam_fifo_rst),
    .vid_fifo_RdClock		(clk_i),
    .vid_fifo_RdEn			(vid_fifo_rd_req_i),
    .vid_fifo_Reset			(cam_fifo_rst),
    .vid_fifo_WrClock		(clk_i),
    .vid_fifo_WrEn			(cam_lv_r)
);

endmodule
