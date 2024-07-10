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
//	Module Name:	gpif_interface_mod
//	Target Devices:	ALL
//	Description: 	gpif_interface_mod implements the basic Slave FIFO interface protocol.
// 					It controls all the SlaveFIFO interface signals and can be controlled by a top mod to send data to SX3 via SlaveFIFO interface.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module gpif_interface_mod
#
(
	parameter IS_U3V =1
)
(
	input			clk_i,
	input			rstn_i,
	input			en_i,
	input			cam_app_en_i,
	input			send_leading_zlp_i,
	input			send_traling_zlp_i,

	input			flaga_i,
	input			flagb_i,
	input			fifo_pg_empty,
	input			data_vld_i,
	input			aud_data_f,
	input [31:0]	frame_size_i,
	input [15:0]	vid_frame_width_i,
	input [15:0]	data_i,
	input [4:0]		watermark_i,
	input			cam_fifo_overflow_i,
	input 			block_slwr_i,    // signal to Block slwr from writing to GPIF Socket during app_stop notification 

	output reg		vid_frame_line_end_o,
	output			buf_done_o,
	output			pktend_g_o,
	output			idle_st_f_o,
	output			fifo_rden_o,
	output			pktend_st_o,
	output [15:0]	sldata_o,
	output			slwr_o,
	output			slrd_o,
	output			sloe_o,
	output			slcs_o,
	output			pktend_o,
	output [2:0]    current_stream_in_state,
	output          vid_fifo_rd_counter_check_o,
	output          watermark_count_o,
	output          fifo_rden_rw,
	output          full_fx3_bufr_rd_o,
	output          full_fx3_bufr_wr_o,
	output          vid_frame_word_counter_max_value_o,
	output reg		full_frame_sent_o
	
//	input assert_pktend
);
generate
if (IS_U3V) begin
//-----------------------------------------------------------------------------
//	Wire, Register and local parameter declarations
//-----------------------------------------------------------------------------

reg [2:0]current_stream_in_state;
reg [2:0]next_stream_in_state;

reg	flaga_r=1'd0;
reg	flagb_r=1'd0;

reg [4:0] wm_cnt=5'd0;

reg idle_st_r=1'd0;
reg slwr_rw;
reg [15:0] sldata_r=16'hffff;
reg [25:0] slwr_cnt=26'd0;
reg slwr_r=1'd1;
reg slwr_gen_r/* synthesis syn_keep = 1 */;
reg pktend_rw;
reg pktend_gr;
reg pktend_r=1'd1;
reg fifo_rden_rw;
reg fifo_rden_r=1'd0;
reg wr_xtra_data=1'd0;
reg buf_done_r=1'd0;
reg pktend_st_r=1'd0;
reg [ 4:0] watermark_r=1'd0;
reg [15:0] line_word_counter=16'd0;
reg [15:0] vid_fifo_rd_counter=16'd0;
reg [25:0] vid_frame_word_counter=26'd0;
reg [ 7:0] audio_word_counter=8'd0;
reg [ 2:0] flag_wait_counter =3'd0;
reg        incr_flag_status_counter = 1'd0;
reg        incr_wm_cnt = 1'd0;
reg [31:0] fx3_bufr_count;
reg [31:0] fx3_wr_bufr_count;

//	Parameters for StreamIN mode state machine
localparam [2:0] STREAM_IN_IDLE                          = 3'd0;
localparam [2:0] STREAM_IN_WAIT_FLAGB                    = 3'd1;
localparam [2:0] STREAM_IN_WRITE                         = 3'd2;
localparam [2:0] STREAM_IN_WRITE_WR_DELAY                = 3'd3;
localparam [2:0] STREAM_IN_PKTEND			             = 3'd4;
localparam [2:0] STREAM_IN_WAIT_FLAG_STATUS	             = 3'd5;
localparam [2:0] STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_1	 = 3'd6;
localparam [2:0] STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2	 = 3'd7;


// FX3 Buffer Size
localparam FX3_BUFFER_SIZE = 18 * 1024;   /////////////////////////

// Flag wait time for current thread (SX3)
localparam CURRENT_THREAD_FLAG_WAIT_TIME = 3'd4;

assign buf_done_o = buf_done_r;
assign pktend_g_o = pktend_gr;
assign fifo_rden_o = fifo_rden_r;
assign sldata_o = sldata_r;
assign slwr_o	= slwr_r ;
assign pktend_o	= pktend_r;
assign slrd_o	= 1'b1;
assign sloe_o	= 1'b1;
assign slcs_o	= 1'b0;

assign idle_st_f_o = idle_st_r;
assign pktend_st_o = pktend_st_r;


//register the input signals
always @(posedge clk_i) begin
	flaga_r <= flaga_i;
	flagb_r <= flagb_i;
end

//streamIN mode state machine
always @(posedge clk_i, negedge rstn_i)begin
	if(!rstn_i)begin
		current_stream_in_state <= STREAM_IN_IDLE;
	end else if (~en_i) begin
		current_stream_in_state <= STREAM_IN_IDLE;
    end else begin
		current_stream_in_state <= next_stream_in_state;
	end
end
 
reg cam_fifo_overflow_r1;
reg cam_fifo_overflow_r2;
reg cam_fifo_overflow_ris;
reg cam_fifo_overflow_fal;

always @ (posedge clk_i) begin
cam_fifo_overflow_r1 <= cam_fifo_overflow_i;
cam_fifo_overflow_r2 <= cam_fifo_overflow_r1;

end

always @ (posedge clk_i) begin
	if (!cam_fifo_overflow_r2 && cam_fifo_overflow_r1) begin
		cam_fifo_overflow_ris <= 1'b1;
	end else
		cam_fifo_overflow_ris <= 1'b0;

end

always @ (posedge clk_i) begin
	if (cam_fifo_overflow_r2 && !cam_fifo_overflow_r1) begin
		cam_fifo_overflow_fal <= 1'b1;
	end else
		cam_fifo_overflow_fal <= 1'b0;

end

//StreamIN mode state machine comb
always @(*)begin

	next_stream_in_state     = current_stream_in_state;
	fifo_rden_rw             = 1'b0;
	pktend_rw                = 1'b1;
    incr_flag_status_counter = 1'b0;
    incr_wm_cnt              = 1'b0;

/*

		STREAM_IN_IDLE:begin
            incr_flag_status_counter = 1'b0;
			//pktend_rw    = 1'b1;
			fifo_rden_rw = 1'b0;
			if ( cam_fifo_overflow_i) begin 
				pktend_rw = 1'd0;
			end else begin
				pktend_rw = 1'd1;
			end
			
			if(flaga_r/*&en_i*\/)begin
				next_stream_in_state = STREAM_IN_WAIT_FLAGB;
			end else begin
				next_stream_in_state = STREAM_IN_IDLE;
			end
		end
		*/



	case(current_stream_in_state)
	/*	STREAM_IN_IDLE:begin
            incr_flag_status_counter = 1'b0;
			//pktend_rw    = 1'b1;
			fifo_rden_rw = 1'b0;
		if(flaga_r /*&en_i*\/)begin
			if ( cam_fifo_overflow_ris) begin  //cam_fifo_overflow_i
				pktend_rw = 1'd0;
			end else begin
				pktend_rw = 1'd1;
			end
			
			if(cam_fifo_overflow_ris) begin
				next_stream_in_state = STREAM_IN_PKTEND;
			end else begin
				next_stream_in_state = STREAM_IN_WAIT_FLAGB;
			end 
		end
		else begin
				next_stream_in_state = STREAM_IN_IDLE;
				end
			end */
			
		STREAM_IN_IDLE:begin
            incr_flag_status_counter = 1'b0;
			//pktend_rw    = 1'b1;
			fifo_rden_rw = 1'b0;
			if ( cam_fifo_overflow_ris) begin 
				pktend_rw = 1'd0;
			end 
			/*else if ( cam_fifo_overflow_fal) begin 
				pktend_rw = 1'd0;
			end  */else begin
				pktend_rw = 1'd1;
			end
			if(cam_fifo_overflow_ris ) begin
				next_stream_in_state = STREAM_IN_PKTEND;
			end 
			/*else if( cam_fifo_overflow_fal) begin
				next_stream_in_state = STREAM_IN_PKTEND;
			end */
			else if(flaga_r/*&en_i*/)begin
				next_stream_in_state = STREAM_IN_WAIT_FLAGB;
			end else begin
				next_stream_in_state = STREAM_IN_IDLE;
			end
		end
		STREAM_IN_WAIT_FLAGB :begin
            incr_flag_status_counter = 1'b0;
			pktend_rw    = 1'b1;
			fifo_rden_rw = 1'b0;
            next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_1;
		end

        STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_1 :begin

            incr_flag_status_counter = 1'b0;
			pktend_rw                = 1'b1;
			fifo_rden_rw             = 1'b0;

			if (flagb_r)begin
				next_stream_in_state = STREAM_IN_WRITE;
			end else begin
				next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2;
			end
        end

        STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2 :
          begin
            incr_flag_status_counter = 1'b0;
            pktend_rw                = 1'd1;

			if (
                 ((wm_cnt<(watermark_r)) /*| ( fx3_bufr_count < FX3_BUFFER_SIZE )*/) &
                 (vid_fifo_rd_counter < vid_frame_width_i) &
                 ( ~fifo_pg_empty )
               )
              begin
				fifo_rden_rw = 1'b1;
                incr_wm_cnt  = 1'b1;
              end
			else
              begin
				fifo_rden_rw = 1'b0;
                incr_wm_cnt  = 1'b0;
              end

			if (!flaga_r)
				next_stream_in_state = STREAM_IN_IDLE;
            else
				next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2;
          end

		STREAM_IN_WRITE:begin
            incr_flag_status_counter = 1'b0;
			if (
                 ((((vid_frame_word_counter >= (frame_size_i-2'd2)) & data_vld_i) | (cam_fifo_overflow_i) ) & !aud_data_f) |
                   ((audio_word_counter     >= (frame_size_i-2'd2)) & data_vld_i) |
                   ( send_leading_zlp_i ) |
                   ( send_traling_zlp_i )
               )
				pktend_rw = 1'd0;
			else
				pktend_rw = 1'd1;

			if (!flaga_r | send_leading_zlp_i | send_traling_zlp_i) begin  // When flaga_r is low, stop reading data from buffer.
              fifo_rden_rw = 1'b0;
            end else if(fifo_rden_r&aud_data_f) begin
			  fifo_rden_rw = 1'b1;
			end
			else begin
				if(fifo_pg_empty | ( (vid_fifo_rd_counter >= vid_frame_width_i) & (~aud_data_f) )/*| (wm_cnt>=(watermark_r))*/) // Control the number of read words
					fifo_rden_rw = 1'd0;
				else
					fifo_rden_rw = 1'd1;
			end
			if((!flagb_r) & flaga_r)begin
				next_stream_in_state = STREAM_IN_WRITE_WR_DELAY;
			end else if((!flagb_r) & (!flaga_r))begin
				next_stream_in_state = STREAM_IN_IDLE;
			end else if(
                         ((((vid_frame_word_counter >= (frame_size_i-2'd2)) & data_vld_i) | (cam_fifo_overflow_i) ) & !aud_data_f) |
                           ((audio_word_counter     >= (frame_size_i-2'd2)) & data_vld_i) |
                           ( send_leading_zlp_i ) |
                           ( send_traling_zlp_i )
                       ) begin
				next_stream_in_state = STREAM_IN_PKTEND;
            end else if((line_word_counter >= (vid_frame_width_i-1'b1))) begin
                next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS ;
			end else begin
				next_stream_in_state = STREAM_IN_WRITE;
			end
		end
		STREAM_IN_WRITE_WR_DELAY:begin

            incr_flag_status_counter = 1'b0;

			if (
                 ((((vid_frame_word_counter >= (frame_size_i-2'd2)) & data_vld_i) | (cam_fifo_overflow_i) ) & !aud_data_f) |
                   ((audio_word_counter     >= (frame_size_i-2'd2)) & data_vld_i)|
                   ( send_leading_zlp_i ) |
                   ( send_traling_zlp_i )
               )
				pktend_rw = 1'd0;
			else
				pktend_rw = 1'd1;
			if((wm_cnt<(watermark_r)) & ((vid_fifo_rd_counter < vid_frame_width_i) | (aud_data_f)))
				fifo_rden_rw = 1'b1;
			else
				fifo_rden_rw = 1'b0;
			if(!flaga_r) begin
				next_stream_in_state = STREAM_IN_IDLE;
			end else if(
                         ((((vid_frame_word_counter >= (frame_size_i-2'd2)) & data_vld_i) | (cam_fifo_overflow_i) ) & !aud_data_f) |
                           ((audio_word_counter     >= (frame_size_i-2'd2)) & data_vld_i)|
                           ( send_leading_zlp_i ) |
                           ( send_traling_zlp_i )
                       ) begin
				next_stream_in_state = STREAM_IN_PKTEND;
            end else if((line_word_counter >= (vid_frame_width_i-1'b1)) /* & data_vld_i */ /* & (wm_cnt<(watermark_r)) */ ) begin
                next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS /* STREAM_IN_IDLE */;
			end else begin
				next_stream_in_state = STREAM_IN_WRITE_WR_DELAY;
			end
		end
		STREAM_IN_PKTEND:begin
			pktend_rw = 1'd1;
            incr_flag_status_counter = 1'b0;
			if(!flaga_r)
				next_stream_in_state = STREAM_IN_IDLE;
		end

		STREAM_IN_WAIT_FLAG_STATUS:begin

			pktend_rw    = 1'd1; // No packet end
			fifo_rden_rw = 1'b0; // No FIFO Read Request
            incr_flag_status_counter = 1'b1;

			if ( (!flaga_r) | ( flag_wait_counter == 3'd5 )
                 // (line_word_counter >= (vid_frame_width_i + CURRENT_THREAD_FLAG_WAIT_TIME - 1'b1))
               )
		      next_stream_in_state = STREAM_IN_IDLE;
            else
              next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS;

		end
	endcase
end

//	'buf_done_r' is asserted once every full buffer is commited to SLFIFO interface
// Added a condition when SX3 buffer is full and 'line_word_counter' reaches to 'vid_frame_width_i'
// at the same time. It is happening in 1080p resolution only.
always @(posedge clk_i) begin
	if  ( ( (current_stream_in_state == STREAM_IN_WRITE_WR_DELAY) & (!flaga_r) ) |
	      ( (current_stream_in_state == STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2) & (!flaga_r) ) |
          ( ( incr_flag_status_counter ) & (!flaga_r) & ( !flagb_r ) )
        )
		buf_done_r <= 1'd1;
	else
		buf_done_r <= 1'd0;
end

assign fsm_in_wait_state_o = ( current_stream_in_state == STREAM_IN_WAIT_FLAG_STATUS );
assign vid_fifo_rd_counter_check_o = (vid_fifo_rd_counter < vid_frame_width_i);
assign watermark_count_o = (wm_cnt<(watermark_r));

always @(posedge clk_i)begin
	idle_st_r <= (current_stream_in_state == STREAM_IN_IDLE);
end

always @(posedge clk_i) begin	// When slwr is not LOW during flagb_i negedge is asserted
	if((current_stream_in_state==STREAM_IN_IDLE) & (flagb_r))
		watermark_r <= watermark_i-5'd4; //	1 Clock each for the flagb_reg, rd_en generation delays. 2cycle for slwr generation.
	else if((!flagb_i) & flagb_r & slwr_gen_r)
		watermark_r <= watermark_i-5'd3; 
end

assign wm_val_4_o = (watermark_r == 3'd4);

always @(posedge clk_i) begin	// When slwr is not LOW during flagb_i negedge is asserted
	if(current_stream_in_state==STREAM_IN_IDLE)
		wr_xtra_data <= 1'd0;
	else if((!flagb_i) & flagb_r & slwr_gen_r)
		wr_xtra_data <= 1'd1;
end

//	Note :
//		Read from the FIFO is enabled by the almost full as there has to be a enough data in the FIFO to be read when the FSM goes to the STREAM_IN_WRITE_WR_DELAY state. Almost Empty value set - 11
always @(posedge clk_i)
  fifo_rden_r <= fifo_rden_rw;

//	Register output data
always @(posedge clk_i) begin
	if(data_vld_i)
		sldata_r <= data_i;
end
reg slwr_w;
//	Registering slwr and packet end signals
always @(posedge clk_i) begin
	pktend_st_r <= (current_stream_in_state==STREAM_IN_PKTEND);
	pktend_gr   <= ((current_stream_in_state==STREAM_IN_PKTEND)&(!flaga_r));
	pktend_r    <= (pktend_rw /*|| assert_pktend*/);
	slwr_r      <= ((((((current_stream_in_state==STREAM_IN_WRITE_WR_DELAY)||(current_stream_in_state==STREAM_IN_WRITE)||(current_stream_in_state==STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2)) ) ? ((!data_vld_i) || block_slwr_i) : 1'd1) & ( pktend_rw | send_leading_zlp_i | send_traling_zlp_i ) ) | ( ~flaga_r )) /*& !cam_fifo_overflow_ris  */ ;
	slwr_gen_r  <= (((((current_stream_in_state==STREAM_IN_WRITE_WR_DELAY)||(current_stream_in_state==STREAM_IN_WRITE)||(current_stream_in_state==STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2)) ) ? ((!data_vld_i) || block_slwr_i) : 1'd1) & ( pktend_rw | send_leading_zlp_i | send_traling_zlp_i ) )   ;
	//slwr_w		<= (slwr_r | ( ~flaga_r )) & !cam_fifo_overflow_ris;
end

// Signal to find out whether all audio data is read or not.
// assign all_audio_words_rd_o = ( slwr_cnt == 12'd1918 ) & (aud_data_f);
// assign slwr_cnt_zero_o      = ( slwr_cnt == 1'b0 );

//	Incrementing watermark count register
 always @(posedge clk_i) begin
 	if((current_stream_in_state==STREAM_IN_IDLE) & (flagb_r))
 		wm_cnt <= 3'd0;
 	else if (( (!slwr_gen_r) & (!flagb_r) & flaga_r & fifo_rden_rw ) | (incr_wm_cnt & fifo_rden_rw) )// Added as the flaga and flagb goes low inbetween buffers too.
 		wm_cnt <= wm_cnt + 1'd1;
 end


// -------------------------------------
//
// Counter to count video frame words
//
// -------------------------------------

always @ (posedge clk_i)
  begin
    if ( ( (current_stream_in_state==STREAM_IN_PKTEND) & (!aud_data_f) ) | ( ~cam_app_en_i ) ) // Video Packet End
      begin
        vid_frame_word_counter <= 26'd0;
      end
    else if ( (!slwr_gen_r) & (!aud_data_f) & ( flaga_r ) )
      begin
        vid_frame_word_counter <= vid_frame_word_counter + 1'b1;
      end
  end

assign vid_frame_word_counter_max_value_o = ( vid_frame_word_counter >= 32'd921598 );
// -------------------------------------
//
// Counter to count line words
//
// -------------------------------------

always @ (posedge clk_i)
  begin
    if ( (~en_i) | (aud_data_f) | 
         ( ( ( flag_wait_counter == 3'd5 ) | ( ~flaga_r ) ) & ( incr_flag_status_counter ) )
       )
    begin
      vid_fifo_rd_counter <= 16'd0;
    end
    else if (fifo_rden_rw)
      begin
        vid_fifo_rd_counter <= vid_fifo_rd_counter + 1'b1;
      end
  end

always @ (posedge clk_i)
  begin
    if ( (~en_i) | (aud_data_f) | (line_word_counter == vid_frame_width_i - 1'b1) )
      begin
        line_word_counter <= 16'd0;
      end
    else if ( (!slwr_gen_r) & ( flaga_r ) )
      begin
        line_word_counter <= line_word_counter + 1'b1;
      end
  end

always @ (posedge clk_i or negedge rstn_i)
  begin
    if (~rstn_i)
      begin
        flag_wait_counter <= 3'd0;
      end
    else if (~incr_flag_status_counter)
      begin
        flag_wait_counter <= 3'd0;
      end
    else
      begin
        flag_wait_counter <= flag_wait_counter + 1'b1;
      end

  end

// Line End. Usefull in switching from Video to Audio mode.
always @ (posedge clk_i)
  begin
    vid_frame_line_end_o <= ( ( ( ( flag_wait_counter == 3'd5 ) & ( flagb_r ) ) | ( ~flaga_r ) ) &
                              ( incr_flag_status_counter )
                            );
  end


// -------------------------------------
//
// Counter to count audio words
//
// -------------------------------------

always @ (posedge clk_i)
  begin
    if ( (~en_i) | (!aud_data_f) | (current_stream_in_state==STREAM_IN_PKTEND) )
      begin
        audio_word_counter <= 8'd0;
      end
    else if ( (!slwr_gen_r) & ( flaga_r ) )
      begin
        audio_word_counter <= audio_word_counter + 1'b1;
      end
  end


always @ (posedge clk_i)
  begin
    if ( ~rstn_i )
      begin
        full_frame_sent_o <= 1'd0;
      end
    else if ( pktend_g_o )
      begin
        full_frame_sent_o <= 1'b0;
      end
    else if ( ( !pktend_o ) & ( !slwr_o ) )
      begin
        full_frame_sent_o <= 1'b1;
      end
  end

always @ (posedge clk_i)
  begin
    if ( ~rstn_i )
      begin
        fx3_bufr_count <= 32'd0;
      end
    else if ( flaga_r == 1'b0 )
      begin
        fx3_bufr_count <= 32'd0;
      end
    else if ( fifo_rden_rw )
      begin
        fx3_bufr_count <= fx3_bufr_count + 1'b1;
      end
  end


  assign full_fx3_bufr_rd_o = (fx3_bufr_count >= FX3_BUFFER_SIZE);

always @ (posedge clk_i)
  begin
    if ( ~rstn_i )
      begin
        fx3_wr_bufr_count <= 32'd0;
      end
    else if ( flaga_r == 1'b0 )
      begin
        fx3_wr_bufr_count <= 32'd0;
      end
    else if ( !slwr_o )
      begin
        fx3_wr_bufr_count <= fx3_wr_bufr_count + 1'b1;
      end
  end

  assign full_fx3_bufr_wr_o = (fx3_wr_bufr_count >= FX3_BUFFER_SIZE);

end

else 
	begin

//-----------------------------------------------------------------------------
//	Wire, Register and local parameter declarations
//-----------------------------------------------------------------------------

reg [2:0]current_stream_in_state;
reg [2:0]next_stream_in_state;

reg	flaga_r=1'd0;
reg	flagb_r=1'd0;

reg [4:0] wm_cnt=5'd0;

reg idle_st_r=1'd0;
reg slwr_rw;
reg [15:0] sldata_r=16'hffff;
reg [25:0] slwr_cnt=26'd0;
reg slwr_r=1'd1;
reg slwr_gen_r/* synthesis syn_keep = 1 */;
reg pktend_rw;
reg pktend_gr;
reg pktend_r=1'd1;
reg fifo_rden_rw;
reg fifo_rden_r=1'd0;
reg wr_xtra_data=1'd0;
reg buf_done_r=1'd0;
reg pktend_st_r=1'd0;
reg [ 4:0] watermark_r=1'd0;
reg [15:0] line_word_counter=16'd0;
reg [15:0] vid_fifo_rd_counter=16'd0;
reg [25:0] vid_frame_word_counter=26'd0;
reg [ 7:0] audio_word_counter=8'd0;
reg [ 2:0] flag_wait_counter =3'd0;
reg        incr_flag_status_counter = 1'd0;
reg        incr_wm_cnt = 1'd0;

//	Parameters for StreamIN mode state machine
localparam [2:0] STREAM_IN_IDLE                          = 3'd0;
localparam [2:0] STREAM_IN_WAIT_FLAGB                    = 3'd1;
localparam [2:0] STREAM_IN_WRITE                         = 3'd2;
localparam [2:0] STREAM_IN_WRITE_WR_DELAY                = 3'd3;
localparam [2:0] STREAM_IN_PKTEND			             = 3'd4;
localparam [2:0] STREAM_IN_WAIT_FLAG_STATUS	             = 3'd5;
localparam [2:0] STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_1	 = 3'd6;
localparam [2:0] STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2	 = 3'd7;

// Local parameter for Magic Word
// localparam MAGIC_WORD = 16'hA5A5;

// Default Video Frame Size
// localparam DEFAULT_VIDEO_FRAME_SIZE = 32'd2073600;

// Flag wait time for current thread (SX3)
localparam CURRENT_THREAD_FLAG_WAIT_TIME = 3'd4;

assign buf_done_o = buf_done_r;
assign pktend_g_o = pktend_gr;
assign fifo_rden_o = fifo_rden_r;
assign sldata_o = sldata_r;
assign slwr_o	= slwr_r | ( ~flaga_r );
assign pktend_o	= pktend_r;
assign slrd_o	= 1'b1;
assign sloe_o	= 1'b1;
assign slcs_o	= 1'b0;

assign idle_st_f_o = idle_st_r;
assign pktend_st_o = pktend_st_r;


//register the input signals
always @(posedge clk_i) begin
	flaga_r <= flaga_i;
	flagb_r <= flagb_i;
end

//streamIN mode state machine
always @(posedge clk_i, negedge rstn_i)begin
	if(!rstn_i)begin
		current_stream_in_state <= STREAM_IN_IDLE;
	end else if (~en_i) begin
		current_stream_in_state <= STREAM_IN_IDLE;
    end else begin
		current_stream_in_state <= next_stream_in_state;
	end
end

//StreamIN mode state machine comb
always @(*)begin

	next_stream_in_state     = current_stream_in_state;
	fifo_rden_rw             = 1'b0;
	pktend_rw                = 1'b1;
    incr_flag_status_counter = 1'b0;
    incr_wm_cnt              = 1'b0;

	case(current_stream_in_state)
		STREAM_IN_IDLE:begin
            incr_flag_status_counter = 1'b0;
			//pktend_rw    = 1'b1;
			fifo_rden_rw = 1'b0;
			if ( cam_fifo_overflow_i) begin 
				pktend_rw = 1'd0;
			end else begin
				pktend_rw = 1'd1;
			end
			
			if(flaga_r/*&en_i*/)begin
				next_stream_in_state = STREAM_IN_WAIT_FLAGB;
			end else begin
				next_stream_in_state = STREAM_IN_IDLE;
			end
		end
		STREAM_IN_WAIT_FLAGB :begin
            incr_flag_status_counter = 1'b0;
			pktend_rw    = 1'b1;
			fifo_rden_rw = 1'b0;

            next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_1;
		end

        STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_1 :begin

            incr_flag_status_counter = 1'b0;
			pktend_rw                = 1'b1;
			fifo_rden_rw             = 1'b0;

			if (flagb_r)begin
				next_stream_in_state = STREAM_IN_WRITE;
			end else begin
				next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2;
			end

        end

        STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2 :
          begin
            incr_flag_status_counter = 1'b0;
            pktend_rw                = 1'd1;

			if((wm_cnt<(watermark_r)) & (vid_fifo_rd_counter < vid_frame_width_i) & ( ~fifo_pg_empty ) )
              begin
				fifo_rden_rw = 1'b1;
                incr_wm_cnt  = 1'b1;
              end
			else
              begin
				fifo_rden_rw = 1'b0;
                incr_wm_cnt  = 1'b0;
              end

			if (!flaga_r)
				next_stream_in_state = STREAM_IN_IDLE;
            else
				next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2;
          end

		STREAM_IN_WRITE:begin
            incr_flag_status_counter = 1'b0;
			if (
                 ((((vid_frame_word_counter >= (frame_size_i-2'd2)) & data_vld_i) | (cam_fifo_overflow_i) ) & !aud_data_f) |
                   ((audio_word_counter     >= (frame_size_i-2'd2)) & data_vld_i)
               )
				pktend_rw = 1'd0;
			else
				pktend_rw = 1'd1;

			if (!flaga_r) begin  // When flaga_r is low, stop reading data from buffer.
              fifo_rden_rw = 1'b0;
            end else if(fifo_rden_r&aud_data_f) begin
			  fifo_rden_rw = 1'b1;
			end
			else begin
				// if(fifo_pg_empty)
				if(fifo_pg_empty | ( (vid_fifo_rd_counter >= vid_frame_width_i) & (~aud_data_f) )/*| (wm_cnt>=(watermark_r))*/) // Control the number of read words
					fifo_rden_rw = 1'd0;
				else
					fifo_rden_rw = 1'd1;
			end
			if((!flagb_r) & flaga_r)begin
				next_stream_in_state = STREAM_IN_WRITE_WR_DELAY;
			end else if((!flagb_r) & (!flaga_r))begin
				next_stream_in_state = STREAM_IN_IDLE;
			end else if(
                         ((((vid_frame_word_counter >= (frame_size_i-2'd2)) & data_vld_i) | (cam_fifo_overflow_i) ) & !aud_data_f) |
                           ((audio_word_counter     >= (frame_size_i-2'd2)) & data_vld_i)
                       ) begin
				next_stream_in_state = STREAM_IN_PKTEND;
            end else if((line_word_counter >= (vid_frame_width_i-1'b1)) /* & data_vld_i */ ) begin
                next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS /* STREAM_IN_IDLE */;
			end else begin
				next_stream_in_state = STREAM_IN_WRITE;
			end
		end
		STREAM_IN_WRITE_WR_DELAY:begin

            incr_flag_status_counter = 1'b0;

			if (
                 ((((vid_frame_word_counter >= (frame_size_i-2'd2)) & data_vld_i) | (cam_fifo_overflow_i) ) & !aud_data_f) |
                   ((audio_word_counter     >= (frame_size_i-2'd2)) & data_vld_i)
               )
				pktend_rw = 1'd0;
			else
				pktend_rw = 1'd1;
			if((wm_cnt<(watermark_r)) & ((vid_fifo_rd_counter < vid_frame_width_i) | (aud_data_f)))
				fifo_rden_rw = 1'b1;
			else
				fifo_rden_rw = 1'b0;
			if(!flaga_r) begin
				next_stream_in_state = STREAM_IN_IDLE;
			end else if(
                         ((((vid_frame_word_counter >= (frame_size_i-2'd2)) & data_vld_i) | (cam_fifo_overflow_i) ) & !aud_data_f) |
                           ((audio_word_counter     >= (frame_size_i-2'd2)) & data_vld_i)
                       ) begin
				next_stream_in_state = STREAM_IN_PKTEND;
            end else if((line_word_counter >= (vid_frame_width_i-1'b1)) /* & data_vld_i */ /* & (wm_cnt<(watermark_r)) */ ) begin
                next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS /* STREAM_IN_IDLE */;
			end else begin
				next_stream_in_state = STREAM_IN_WRITE_WR_DELAY;
			end
		end
		STREAM_IN_PKTEND:begin
			pktend_rw = 1'd1;
            incr_flag_status_counter = 1'b0;
			if(!flaga_r)
				next_stream_in_state = STREAM_IN_IDLE;
		end

		STREAM_IN_WAIT_FLAG_STATUS:begin

			pktend_rw    = 1'd1; // No packet end
			fifo_rden_rw = 1'b0; // No FIFO Read Request
            incr_flag_status_counter = 1'b1;

			if ( (!flaga_r) | ( flag_wait_counter == 3'd5 )
               )
		      next_stream_in_state = STREAM_IN_IDLE;
            else
              next_stream_in_state = STREAM_IN_WAIT_FLAG_STATUS;

		end
	endcase
end

//	'buf_done_r' is asserted once every full buffer is commited to SLFIFO interface
// Added a condition when SX3 buffer is full and 'line_word_counter' reaches to 'vid_frame_width_i'
// at the same time. It is happening in 1080p resolution only.
always @(posedge clk_i) begin
	if  ( ( (current_stream_in_state == STREAM_IN_WRITE_WR_DELAY) & (!flaga_r) ) |
	      ( (current_stream_in_state == STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2) & (!flaga_r) ) |
          ( ( incr_flag_status_counter ) & (!flaga_r) & ( !flagb_r ) )
        )
		buf_done_r <= 1'd1;
	else
		buf_done_r <= 1'd0;
end

assign fsm_in_wait_state_o = ( current_stream_in_state == STREAM_IN_WAIT_FLAG_STATUS );
assign vid_fifo_rd_counter_check_o = (vid_fifo_rd_counter < vid_frame_width_i);
assign watermark_count_o = (wm_cnt<(watermark_r));

always @(posedge clk_i)begin
	idle_st_r <= (current_stream_in_state == STREAM_IN_IDLE);
end

always @(posedge clk_i) begin	// When slwr is not LOW during flagb_i negedge is asserted
	if((current_stream_in_state==STREAM_IN_IDLE) & (flagb_r))
		watermark_r <= watermark_i-5'd4; //	1 Clock each for the flagb_reg, rd_en generation delays. 2cycle for slwr generation.
	else if((!flagb_i) & flagb_r & slwr_gen_r)
		watermark_r <= watermark_i;
end
always @(posedge clk_i) begin	// When slwr is not LOW during flagb_i negedge is asserted
	if(current_stream_in_state==STREAM_IN_IDLE)
		wr_xtra_data <= 1'd0;
	else if((!flagb_i) & flagb_r & slwr_gen_r)
		wr_xtra_data <= 1'd1;
end

//	Note :
//		Read from the FIFO is enabled by the almost full as there has to be a enough data in the FIFO to be read when the FSM goes to the STREAM_IN_WRITE_WR_DELAY state. Almost Empty value set - 11
always @(posedge clk_i)
  fifo_rden_r <= fifo_rden_rw;

//	Register output data
always @(posedge clk_i) begin
	if(data_vld_i)
		sldata_r <= data_i;
end

//	Registering slwr and packet end signals
always @(posedge clk_i) begin
	pktend_st_r <= (current_stream_in_state==STREAM_IN_PKTEND);
	pktend_gr   <= ((current_stream_in_state==STREAM_IN_PKTEND)&(!flaga_r));
	pktend_r    <= pktend_rw;
	slwr_r      <= (((((current_stream_in_state==STREAM_IN_WRITE_WR_DELAY)||(current_stream_in_state==STREAM_IN_WRITE)||(current_stream_in_state==STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2)) ) ? (!data_vld_i) : 1'd1) & pktend_rw ) /* | ( ~flaga_r ) */ ;
	slwr_gen_r  <= (((((current_stream_in_state==STREAM_IN_WRITE_WR_DELAY)||(current_stream_in_state==STREAM_IN_WRITE)||(current_stream_in_state==STREAM_IN_WAIT_FLAG_STATUS_BEFORE_WR_2)) ) ? (!data_vld_i) : 1'd1) & pktend_rw ) /* | ( ~flaga_r ) */ ;
end


//	Incrementing watermark count register
 always @(posedge clk_i) begin
 	if((current_stream_in_state==STREAM_IN_IDLE) & (flagb_r))
 		wm_cnt <= 3'd0;
 	else if (( (!slwr_gen_r) & (!flagb_r) & flaga_r & fifo_rden_rw ) | (incr_wm_cnt & fifo_rden_rw) )// Added as the flaga and flagb goes low inbetween buffers too.
 		wm_cnt <= wm_cnt + 1'd1;
 end


// -------------------------------------
//
// Counter to count video frame words
//
// -------------------------------------

always @ (posedge clk_i)
  begin
    if ( ( (current_stream_in_state==STREAM_IN_PKTEND) & (!aud_data_f) ) | ( ~cam_app_en_i ) ) // Video Packet End
      begin
        vid_frame_word_counter <= 26'd0;
      end
    else if ( (!slwr_gen_r) & (!aud_data_f) & ( flaga_r ) )
      begin
        vid_frame_word_counter <= vid_frame_word_counter + 1'b1;
      end
  end


// -------------------------------------
//
// Counter to count line words
//
// -------------------------------------

always @ (posedge clk_i)
  begin
    if ( (~en_i) | (aud_data_f) | /* (vid_fifo_rd_counter == vid_frame_width_i)  */  /* vid_frame_line_end_o */
         ( ( ( flag_wait_counter == 3'd5 ) | ( ~flaga_r ) ) & ( incr_flag_status_counter ) )
       )

    begin
      vid_fifo_rd_counter <= 16'd0;
    end
    else if (fifo_rden_rw)
      begin
        vid_fifo_rd_counter <= vid_fifo_rd_counter + 1'b1;
      end
  end

always @ (posedge clk_i)
  begin
    if ( (~en_i) | (aud_data_f) | (line_word_counter == vid_frame_width_i - 1'b1) )
      begin
        line_word_counter <= 16'd0;
      end
    else if ( (!slwr_gen_r) & ( flaga_r ) )
      begin
        line_word_counter <= line_word_counter + 1'b1;
      end
  end

always @ (posedge clk_i or negedge rstn_i)
  begin
    if (~rstn_i)
      begin
        flag_wait_counter <= 3'd0;
      end
    else if (~incr_flag_status_counter)
      begin
        flag_wait_counter <= 3'd0;
      end
    else
      begin
        flag_wait_counter <= flag_wait_counter + 1'b1;
      end

  end

// Line End. Usefull in switching from Video to Audio mode.
always @ (posedge clk_i)
  begin
    vid_frame_line_end_o <= ( ( ( ( flag_wait_counter == 3'd5 ) & ( flagb_r ) ) | ( ~flaga_r ) ) &
                              ( incr_flag_status_counter )
                            );
  end


// -------------------------------------
//
// Counter to count audio words
//
// -------------------------------------

always @ (posedge clk_i)
  begin
    if ( (~en_i) | (!aud_data_f) | (current_stream_in_state==STREAM_IN_PKTEND) )
      begin
        audio_word_counter <= 8'd0;
      end
    else if ( (!slwr_gen_r) & ( flaga_r ) )
      begin
        audio_word_counter <= audio_word_counter + 1'b1;
      end
  end
 
end
endgenerate
endmodule