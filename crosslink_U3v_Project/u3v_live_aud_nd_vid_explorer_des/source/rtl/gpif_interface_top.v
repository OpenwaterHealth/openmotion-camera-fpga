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
//	Module Name:	gpif_interface_top
//	Target Devices:	LIF-MD6000
//	Description:	This module controls the gpif_interface_mod to send the video data to the SX3 via Slave FIFO interface
//					It has a FIFO to recevie, buffer the video data.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module gpif_interface_top
#
(	
	parameter IS_U3V	= 	1
)
(
	//	Global Inputs
	input 			clk_i,
	input 			rstn_i,	// Active Low reset

	//	Control Signals
	input 			cam_app_en_i,		 	// cam_app_enable from I2C_Slave
	input 			aud_app_en_i,			
	input 			vid_skt_rst_i,			// video channel reset from I2C_Slave
	input 			aud_skt_rst_i,
	input [31:0]	frame_size_i,			// Number of pixels in a frame
	input 			cam_fv_i,				
	input 			cam_fv_pe_pl_i,			// FV-Posedge
	input 			cam_fv_ne_pl_i,			// FV-Negedge
	input 			cam_lv_i,

    // From Video Buffer Module
	input [15:0]	vid_fifo_rd_data_i,		 // 16 bit data read from FIFO-Out
	input [15:0]	vid_frame_width_i,		 // // Number of pixels in a line; 1280 or 1920 or 640 
	input 			vid_fifo_data_vld_i,	 //  Read_Enable signal for FIFO-In; (vid_fifo_data_vld_i <= vid_fifo_rd_req_o)
	input 			vid_fifo_almost_empty_i, // Almost_Empty from  FIFO-Out
	input 			cam_fifo_overflow_i,	 // Video_FIFO_Full(from FIFO) & line_valid

    output          vid_fifo_rd_req_o,		 // Read_Enable signal for FIFO-In
    output          vid_pktend_st_o,		 // pktend state & video stream enable 

    // To/From Audio Buffer Manager
	input [11:0]	aud_fifo_rd_count_i,
	input [15:0]	aud_fifo_rd_data_i,
	input 			aud_fifo_data_vld_i,
	input 			aud_fifo_almost_empty_i,
	input 			aud_fifo_empty_i,
	input 			app_stop_i,  			// App_Stop Notification from FX3 through I2C Writes

    output          aud_fifo_rd_req_o,
    output          aud_pktend_o,
    output          vid_pktend_o,

	// SlaveFIFO Interface IOs
	input 			flaga_i,
	input 			flagb_i,
	
	input 			is_u3v,

	output [1:0]	sl_addr_o,			    // For video - "01,00"; For audio - "10,11"
	output [15:0]	sldata_o,				
	output 			slwr_o,
	output 			slrd_o,
	output 			sloe_o,
	output 			slcs_o,
	output 			pktend_o,
	output			aud_fifo_rd_count_o, 		
	output [1:0]    cur_gpif_st,
	output			buf_done_o,				 // Full Buffer asserted
	output [2:0]	current_stream_in_state_o,
	output          vid_fifo_rd_counter_check_o, // count of frame_width
	output          watermark_count_o,
	output          fifo_ae,
	output          fifo_rden_rw,			
	output          vid_frame_end,			// Frame End Signal
	output          send_traling_zlp,
	output          send_leading_zlp,
	//output          wm_val_4_o,
	output          full_fx3_bufr_rd_o,		// FX3 buffer count
	output          vid_frame_word_counter_max_value_o,
	output          full_fx3_bufr_wr_o
);

reg block_slwr=1'b0;
//-----------------------------------------------------------------------------
//	Wire, Register and local parameter declarations
//-----------------------------------------------------------------------------

localparam [4:0] WATERMARK      = 5'd8;	// Watermark value has to be changed based on the setting in SX3
localparam [2:0] GPIF_IDLE_ST	= 2'd0;
localparam [2:0] VID_COMMIT_ST	= 2'd1;
localparam [2:0] AUD_COMMIT_ST	= 2'd2;

// Total chunks in single ping pong buffer.
localparam LAST_WORD_IN_SINGLE_PING_PONG_BUFR = 11'd1920;

// Minimum frame length to be sent when audio mode is selected.
// It should be 192 bytes = 96 words.
localparam MIN_AUD_FRAME_LEN_TO_BE_SENT_W = 8'd96;

reg         gpif_en_r=1'b0;
reg         vid_skt_r=1'b0;
reg         aud_skt_r=1'b0;
reg         pktend_frc_r=1'b0; 		// Force pktend
reg         vid_stream_en_r=1'b0;
reg         aud_stream_en_r=1'b0;
reg         gpif_rst_r=1'b0;
reg         gpif_en_rw=1'b0;
reg [2:0]   cur_gpif_st=GPIF_IDLE_ST;
reg [2:0]   cur_gpif_st_r=GPIF_IDLE_ST;
reg [2:0]   next_gpif_st;
reg [1:0]   sl_addr_r;
reg         aud_stream_en_f1;
reg         aud_stream_en_f2;
reg         send_traling_zlp;
reg         send_leading_zlp;
reg         vid_frame_end;
wire        full_frame_sent;

wire        aud_stream_en_pe_pl;
wire        vid_frame_line_end;
wire        buf_done_o;
wire        pktend_g_o;
wire        fifo_ae;
wire        fifo_rd_req;
wire        pktend_st;			//when gpif in pktend state
wire        fifo_data_vld;
wire [15:0] fifo_rd_data;
reg  [31:0] frame_size;

// Slave FIFO Address
assign sl_addr_o = sl_addr_r;

//	flag to force the frame end when an overflow in the buffer is detected
always @(posedge clk_i, negedge rstn_i) begin
	if(!rstn_i)
		pktend_frc_r <= 1'b0;
	else if(cam_fifo_overflow_i)
		pktend_frc_r <= 1'b1;
	else if(vid_pktend_st_o||(!cam_app_en_i))
		pktend_frc_r <= 1'b0;
end

//	Switch betweeen sockets in SX3 once every full and partial buffer is commited

always @(posedge clk_i, negedge rstn_i) begin
	if((!rstn_i) || vid_skt_rst_i || (!cam_app_en_i))
		vid_skt_r <= 'd0;
	else if ( ( buf_done_o ) | ( pktend_g_o) &
              (cur_gpif_st==VID_COMMIT_ST)
            )
		vid_skt_r <= !vid_skt_r;
end

always @(posedge clk_i, negedge rstn_i) begin
	if((!rstn_i) || aud_skt_rst_i || (!aud_app_en_i))
		aud_skt_r <= 'd0;
	else if((buf_done_o||pktend_g_o ) & (cur_gpif_st==AUD_COMMIT_ST))
		aud_skt_r <= !aud_skt_r;
end

always @(posedge clk_i, negedge rstn_i) begin
	if(!rstn_i)
		sl_addr_r <= 2'd0;
	else if((cur_gpif_st==VID_COMMIT_ST))
		sl_addr_r <= {1'b0,vid_skt_r};
	else if((cur_gpif_st==AUD_COMMIT_ST))
		sl_addr_r <= {1'b1,aud_skt_r};
end

generate
if(IS_U3V) begin
// Leader ZLP
always @ ( posedge clk_i or negedge rstn_i )
  begin
    if ( ~rstn_i )
      begin
        send_leading_zlp <= 1'b0;
      end
    else if (( ( pktend_g_o ) &
              ( cur_gpif_st == VID_COMMIT_ST ) &
              ( send_leading_zlp )
            ) || (app_stop_i))  	// Preventing Leader when App_Stop Notification comes
      begin
        send_leading_zlp <= 1'b0;
      end
    else if ( cam_fv_pe_pl_i )
      begin
        send_leading_zlp <= 1'b1;
      end
  end

// Falling edge of FV
 always @ ( posedge clk_i or negedge rstn_i )
   begin
     if ( ~rstn_i )
       begin
         vid_frame_end <= 1'b0;
       end
    else if ( ( pktend_g_o ) &
              ( full_frame_sent == 1'b0 ) &
              ( cur_gpif_st == VID_COMMIT_ST ) &
              ( send_traling_zlp == 1'b1 ) &
              ( vid_frame_end == 1'b1 )
            )
       begin
         vid_frame_end <= 1'b0;
       end
     else if ( ( cam_fv_ne_pl_i ) & ( cam_lv_i == 1'b0 ) )
       begin
         vid_frame_end <= 1'b1;
       end
   end

always @ ( posedge clk_i or negedge rstn_i )
  begin
    if ( ~rstn_i )
      begin
        send_traling_zlp <= 1'b0;
      end
    else if ( ( pktend_g_o ) &
              ( full_frame_sent == 1'b0 ) &
              ( cur_gpif_st == VID_COMMIT_ST ) &
              ( send_traling_zlp == 1'b1 ) 
            )
      begin
        send_traling_zlp <= 1'b0;
      end
    else if ( 
              ( pktend_g_o      == 1'b1 ) &
              ( cur_gpif_st == VID_COMMIT_ST ) &
              ( full_frame_sent == 1'b1 )
            )
      begin
        send_traling_zlp <= 1'b1;
      end
  end
/****  Blocking Payload from writing to DMA when APP_Stop Notification occurs ****/
always @ ( posedge clk_i )   
	begin
	if (send_traling_zlp && app_stop_i)begin
		block_slwr <=1'b1;	
	end
	else if(send_leading_zlp)
		block_slwr <=1'b0;
	end
end
endgenerate

// GPIF State Machine

 //	GPIF Interface controller state machine
 always @ (posedge clk_i or negedge rstn_i) begin
 	if(~rstn_i)begin
 		cur_gpif_st <= 'd0;
 		cur_gpif_st_r <= 'd0;
 	end else begin
 		cur_gpif_st <= next_gpif_st;
 		cur_gpif_st_r <= cur_gpif_st;
 	end
 end

 always @(*) begin
 	next_gpif_st = cur_gpif_st;
 	gpif_en_rw = 'd0;
 	case(cur_gpif_st)
 		GPIF_IDLE_ST:begin
 			gpif_en_rw = 1'd0;

 		    if(aud_app_en_i & ( aud_fifo_rd_count_i >= MIN_AUD_FRAME_LEN_TO_BE_SENT_W))
 				next_gpif_st = AUD_COMMIT_ST;
            else if(cam_app_en_i & ( cam_fv_i | send_traling_zlp ) )
 				next_gpif_st = VID_COMMIT_ST;
 			else
 				next_gpif_st = GPIF_IDLE_ST;
 		end
 		VID_COMMIT_ST:begin
 			gpif_en_rw = 1'd1;

 			if((!cam_app_en_i)) begin
 				next_gpif_st = GPIF_IDLE_ST;
 			end else if(pktend_g_o | vid_frame_line_end ) begin
 					next_gpif_st = GPIF_IDLE_ST;
 			end else begin
 				next_gpif_st = VID_COMMIT_ST;
 			end
 		end
 		AUD_COMMIT_ST:begin
 			gpif_en_rw = 1'd1;

 			if((!aud_app_en_i)) begin
 				next_gpif_st = GPIF_IDLE_ST;
 			end else if(pktend_g_o) begin
 					next_gpif_st = GPIF_IDLE_ST;
 			end else begin
 				next_gpif_st = AUD_COMMIT_ST;
 			end
 		end
 	endcase
 end

always @ (posedge clk_i) begin
  vid_stream_en_r <= (cur_gpif_st==VID_COMMIT_ST);
  aud_stream_en_r <= (cur_gpif_st==AUD_COMMIT_ST);
  gpif_rst_r      <= (cur_gpif_st==VID_COMMIT_ST)&(!cam_app_en_i) || ((cur_gpif_st==AUD_COMMIT_ST)&(!aud_app_en_i));
  gpif_en_r       <= gpif_en_rw;
end

// Audio/Video Buffer Read Requests
assign vid_fifo_rd_req_o = vid_stream_en_r & fifo_rd_req;
assign aud_fifo_rd_req_o = aud_stream_en_r & fifo_rd_req;
assign aud_pktend_o      = pktend_g_o & aud_stream_en_r;
assign vid_pktend_st_o   = pktend_st & vid_stream_en_r;
assign vid_pktend_o      = pktend_g_o & vid_stream_en_r;

// Almost empty flag is not useful here as FSM will be in AUD_COMMIT_ST once there are 96 words
// available in ping pong buffer. Hence, it is assigned 0.

// FIFO Almost Empty
assign fifo_ae       = ( aud_stream_en_r ? 1'b0 /*aud_fifo_almost_empty_i*/ : vid_fifo_almost_empty_i );
assign fifo_data_vld = ( aud_stream_en_r ? aud_fifo_data_vld_i : vid_fifo_data_vld_i );
assign fifo_rd_data  = ( aud_stream_en_r ? aud_fifo_rd_data_i : vid_fifo_rd_data_i );


// Simple flops
always @ (posedge clk_i or negedge rstn_i)
  begin
    if (~rstn_i)
      begin
        aud_stream_en_f1 <= 1'd0;
        aud_stream_en_f2 <= 1'd0;
      end
    else
      begin
        aud_stream_en_f1 <= aud_stream_en_r;
        aud_stream_en_f2 <= aud_stream_en_f1;
      end

  end

// Rising edge of the 'aud_stream_en_r'
assign aud_stream_en_pe_pl = ( (aud_stream_en_f1) & (~aud_stream_en_f2) );

// To check whether 'aud_fifo_rd_count_i' is higher that 'MIN_AUD_FRAME_LEN_TO_BE_SENT_W' or not.
assign aud_fifo_rd_count_o = ( aud_fifo_rd_count_i >= MIN_AUD_FRAME_LEN_TO_BE_SENT_W);


// Frame Size
// In case of video, frame size is decided by register value.
// In case of audio, frame end is decided by magic word.
always @ (posedge clk_i or negedge rstn_i)
  begin
    if (~rstn_i)
      begin
        frame_size <= 32'd0;
      end
    else if ( aud_stream_en_pe_pl ) // 1 clock cycle
      begin
        frame_size <= 32'd96; // Number of words in ping pong buffer.
      end
    else if ( vid_stream_en_r )
      begin
        frame_size <= frame_size_i;
      end
  end

gpif_interface_mod 
#
(
	.IS_U3V 					(IS_U3V)
)
gpif_interface_mod
(
	.clk_i				  (clk_i),
	.rstn_i				  (rstn_i),
	.en_i				  (gpif_en_r),
	.cam_app_en_i	      (cam_app_en_i),
	.send_leading_zlp_i	  (send_leading_zlp),
	.send_traling_zlp_i	  (send_traling_zlp),

	.flaga_i			  (flaga_i),
	.flagb_i			  (flagb_i),
	.fifo_pg_empty		  (fifo_ae),
	.data_vld_i			  (fifo_data_vld),
	.aud_data_f			  (aud_stream_en_r),
	.frame_size_i		  (frame_size),
	.vid_frame_width_i    (vid_frame_width_i),
	.data_i				  (fifo_rd_data),
	.watermark_i		  (WATERMARK),
	.cam_fifo_overflow_i  (pktend_frc_r),

	.vid_frame_line_end_o (vid_frame_line_end),
	.buf_done_o			  (buf_done_o),
	.pktend_g_o			  (pktend_g_o),
	.idle_st_f_o		  (idle_st_f_o),
	.fifo_rden_o		  (fifo_rd_req),
	.pktend_st_o		  (pktend_st),
	.sldata_o			  (sldata_o),
	.slwr_o				  (slwr_o),
	.slrd_o				  (slrd_o),
	.sloe_o				  (sloe_o),
	.slcs_o				  (slcs_o),
	.pktend_o			  (pktend_o),
	.full_frame_sent_o	  (full_frame_sent),
	.current_stream_in_state  (current_stream_in_state_o),
	.vid_fifo_rd_counter_check_o  (vid_fifo_rd_counter_check_o),
	.watermark_count_o            (watermark_count_o),
	.full_fx3_bufr_rd_o           (full_fx3_bufr_rd_o),
	.full_fx3_bufr_wr_o           (full_fx3_bufr_wr_o),
	.vid_frame_word_counter_max_value_o           (vid_frame_word_counter_max_value_o),
	.block_slwr_i (block_slwr),   
	.fifo_rden_rw                 (fifo_rden_rw)

);

endmodule
