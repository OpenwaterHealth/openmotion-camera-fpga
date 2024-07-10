//////////////////////////////////////////////////////////////////////////////////
//	(c) 2020-2021, Cypress Semiconductor Corporation (an Infineon company) or
// an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
//
//	This software, including source code, documentation and related materials
// ("Software") is owned by Cypress Semiconductor Corporation or one of its
// affiliates ("Cypress") and is protected by and subject to worldwide patent
// protection (United States and foreign), United States copyright laws and
// international treaty provisions.  Therefore, you may use this Software only
// as provided in the license agreement accompanying the software package from
// which you obtained this Software ("EULA"). If no EULA applies, Cypress hereby
// grants you a personal, non-exclusive, non-transferable license to copy, modify,
// and compile the Software source code solely for use in connection with Cypress's
// integrated circuit products.  Any reproduction, modification, translation,
// compilation, or representation of this Software except as specified above is
// prohibited without the express written permission of Cypress.
//
//	Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
// Cypress reserves the right to make changes to the Software without notice.
// Cypress does not assume any liability arising out of the application or use
// of the Software or any product or circuit described in the Software.
// Cypress does not authorize its products for use in any products where a
// malfunction or failure of the Cypress product may reasonably be expected to
// result in significant property damage, injury or death ("High Risk Product").
// By including Cypress's product in a High Risk Product, the manufacturer of
// such system or application assumes all risk of such use and in doing so agrees
// to indemnify Cypress against all liability.
//
// Design Name:		HDMI RX
// Module Name:		i2s_rx_mod
// Target Devices:	LFE5U-25F-8BG381I
// Tool Versions:
// Description: Input audio data recevied from the I2S receiver module is written
//              into a audio buffer. The audio buffer sends the data in 192 byte
//              bursts. This burst data is written in the 2 FIFOs alternately for
//              buffering.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

// Timescale
`timescale 1 ns / 100 ps

module aud_buffer_manager
(
	input	clk_i,
	input	rstn_i,	// Active LOW Reset

	// Control signals
	// input	       vsync_fal_i,
	input	       cam_fv_i,
	input	       i2s_fifo_rd_en_i,
	output [15:0]  i2s_fifo_data_o,
	output [15:0]  i2s_fifo_data_pre,
	output [11:0]  i2s_fifo_rcnt_o,
	output	       i2s_fifo_empty_o,
	output reg     i2s_fifo_data_vld_o,
	output	       i2s_fifo_almostempty_o,
	input	       aud_pktend_i, //	Indicates audio data's packetend in GPIF interface
	output [15:0]  wr_fifo_cnt_o,

	input             cam_app_en_i,
	input             mic_pdm_data_i,
	input             mic_clk_i,
    input             sync_bclk_reset_n_i,

    input             change_rd_bufr_idx_pl_i
    // output            aud_rdidx_r,
    // output [9:0]      ping_pong_bufr_rd_words
);

wire	[15:0]	i2s_data;

reg		wr_fifo_idx_r='d0;
reg		wr_fifo_idx='d0;
reg [5:0]	mg_byte_wr_cnt='d0;
reg		mg_byte_wr_en='d0;
reg		mg_byte_wr_en_f1;

reg		aud_rdidx_r='d0;
wire 	aud_rd_idx;
reg [15:0]	i2s_wr_data_r='d0;
reg [15:0]	i2s_wr_data_rr='d0;
reg		i2s_wr_en_r='d0;

wire	[15:0]	i2s_fifo_dout[1:0];
wire	[11:0]	i2s_fifo_wcnt[1:0];
reg	    [1:0]	i2s_wr_en;
wire	[1:0]	i2s_fifo_empty;
wire	[1:0]	i2s_fifo_full;
wire	[1:0]	i2s_fifo_rden;
wire	[1:0]	i2s_almostempty;
wire	[1:0]	i2s_almostfull;

reg	    [1:0]	rst='d3;
genvar gi;

reg [1:0]	wr_state='d0;
reg			rst_fifo='d0;
reg [31:0]	wr_aud_frm_cnt_r='d0;
reg 		init_r='d1;
reg 		rst_fifo1='d0;
reg 		rst_fifo2='d0;
reg 		ping_pong_bufr_not_avail='d0;

wire [7:0] aud_buf_rd_count;

reg aud_buf_rden='d0;
reg aud_buf_rden_r='d0;
reg aud_buf_rdvld='d0;

reg buf_sw_trig='d0;
reg sw_trig_st='d0;
reg [7:0] aud_buf_cnt='d0;
reg [1:0] au_rd_st='d0;
reg [1:0] au_rd_st_n='d0;
reg [15:0] wr_cnt_f0='d0;
reg [15:0] wr_cnt_f1='d0;

wire mic_pdm_data_l;
wire mic_pdm_data_r;
reg  pcm_mic_dout_valid_l_pl_mc;
wire pcm_mic_dout_valid_r_pl_mc;
reg  pcm_mic_dout_valid_r_pl_mc_f1;
reg  pcm_mic_dout_valid_r_pl_mc_f2;
reg  mic_fifo_wr_req;
reg  cam_fv_f1;
reg  cam_fv_f2;

wire [23:0] pcm_data_l;
wire [23:0] pcm_data_r;
reg  [15:0] mic_data_r;
reg  [15:0] mic_fifo_wr_data;

reg         sel_ping_pong_bufr_avail;
wire        aud_buf_full;
wire        sel_ping_pong_bufr_avail_ne_pl;
wire        cam_fv_pe_pl;

reg         sel_ping_pong_bufr_avail_f1;
reg         sel_ping_pong_bufr_avail_f2;
reg         i2s_fifo_rden_f1;

reg  [10:0]  ping_pong_bufr_wr_words;
reg  [10:0]  ping_pong_bufr_rd_words;
reg  [7:0]  pdm_clk_counter;

assign aud_rd_idx = aud_rdidx_r;

// Local Parameters

localparam SW_VSYNC_TRIG = 1'd0;
localparam DELAYED_TRIG  = 1'd1;
localparam RD_IDLE       = 2'd0;
localparam RD_HOLD       = 2'd1;
localparam RD_ACTIVE     = 2'd2;

localparam IDLE_ST       = 'd0;
localparam VLD_DATA_ST   = 'd1;

localparam BIT_MODE_16   = 'd1;
localparam WR_IDLE	     = 2'd0;
localparam WR_RST	     = 2'd1;

localparam MAGIC_WORD    = 16'hA5A5;

// Ping Pong Buffer Related Parameters

// Depth in words
localparam PING_PONG_BUFR_DEPTH = 16'd2048;

// Width
localparam PING_PONG_BUFR_WIDTH = 5'd16;

// Number of Magic Words at the end of each buffer
localparam NO_OF_MAGIC_WORDS_IN_EACH_BUFR = 6'd54;

// Availabile space for audio data
localparam NO_OF_WORDS_AVAILABLE_FOR_AUDIO = ( PING_PONG_BUFR_DEPTH - NO_OF_MAGIC_WORDS_IN_EACH_BUFR );

// Audio Data chunk: Data in 1 ms. At 48 KHz, it is 192 bytes.
localparam AUDIO_DATA_CHUNK_IN_WORDS = 8'd96;

// Total chunks in single ping pong buffer.
localparam MAX_WORDS_IN_SINGLE_PING_PONG_BUFR = ( NO_OF_WORDS_AVAILABLE_FOR_AUDIO / AUDIO_DATA_CHUNK_IN_WORDS );

// Total chunks in single ping pong buffer.
localparam LAST_WORD_IN_SINGLE_PING_PONG_BUFR = 11'd1920;
// localparam LAST_WORD_IN_SINGLE_PING_PONG_BUFR = ( MAX_WORDS_IN_SINGLE_PING_PONG_BUFR * AUDIO_DATA_CHUNK_IN_WORDS );


always @ ( posedge clk_i /* or negedge rstn_i */ ) begin
	if(!rstn_i)
		aud_rdidx_r <= 'd0;
else if ( aud_pktend_i | change_rd_bufr_idx_pl_i )
		aud_rdidx_r <= wr_fifo_idx_r;
end

always @ ( posedge clk_i /* or negedge rstn_i */ )
  begin
	   if(!rstn_i)
      begin
		i2s_wr_data_rr <= 'd0;
      end
	   else
      begin
	   	i2s_wr_data_rr <= i2s_wr_data_r;
	  end
  end

always @ ( posedge clk_i /* or negedge rstn_i */ )
  begin
	   if(!rstn_i)
      begin
		      mg_byte_wr_en_f1 <= 'd0;
      end
	   else
      begin
	   	   mg_byte_wr_en_f1 <= mg_byte_wr_en;
	     end
  end

// Read data valid from intermediate_dc_fifo
 always @ ( posedge clk_i /* or negedge rstn_i */ )
   begin
     if ( ~rstn_i )
       begin
         i2s_wr_en_r   <= 1'b0;
       end
     else
       begin
         i2s_wr_en_r   <= aud_buf_rdvld;
       end
   end

 // Ping pong buffer write request
 always @ ( posedge clk_i /* or negedge rstn_i */ )
   begin
     if ( ~rstn_i )
       begin
         i2s_wr_data_r   <= 16'b0;
       end
     else if ( aud_buf_rdvld )
       begin
         i2s_wr_data_r   <= i2s_data;
       end
   end

// Simple Flops
always @ ( posedge clk_i /* or negedge rstn_i */ )
  begin
    if ( ~rstn_i )
      begin
        cam_fv_f1 <= 1'b0;
        cam_fv_f2 <= 1'b0;
      end
    else
      begin
        cam_fv_f1   <= cam_fv_i;
        cam_fv_f2   <= cam_fv_f1;
      end
  end

  // Rising Edge of 'cam_fv_i'
  assign cam_fv_pe_pl = ( ( cam_fv_f1 ) & ( ~cam_fv_f2 ) );



reg overwrite='d0;
always @ ( posedge clk_i /* or negedge rstn_i */ ) begin
	if(!rstn_i) begin
		wr_state <= WR_IDLE;
		mg_byte_wr_en <= 'd0;
		rst_fifo <= 'd0;
		wr_fifo_idx <= 'd0;
		wr_fifo_idx_r <= 'd0;
		mg_byte_wr_cnt <= 'd0;
		wr_aud_frm_cnt_r <= 'd0;
		// init_r <= 'd1;
		// init_r <= cam_app_en_i;
		overwrite <= 'd0;
	end
	else begin
		case(wr_state)
			WR_IDLE :	begin
				rst_fifo <= 1'd0;
				if(buf_sw_trig) begin
					wr_aud_frm_cnt_r <= wr_aud_frm_cnt_r + 1'd1;
					if(aud_rdidx_r /* || init_r */ ) begin
						wr_fifo_idx   <= 1'd0;
						wr_fifo_idx_r <= 1'd0;
					end
					else begin
						wr_fifo_idx   <= 1'd1;
						wr_fifo_idx_r <= 1'd1;
					end
					overwrite     <= ((!wr_fifo_idx)&aud_rdidx_r) || ((wr_fifo_idx)&(!aud_rdidx_r));
					wr_state      <= WR_RST;
					mg_byte_wr_en <= 1'd1;
				end
				else begin
					mg_byte_wr_en <= 1'd0;
				end
			end
			WR_RST :	begin
				overwrite <= 'd0;
				// init_r <= 'd0;
				if(mg_byte_wr_cnt=='d62) begin
					mg_byte_wr_en <= 'd0;
					rst_fifo <= 'd0;
					mg_byte_wr_cnt <= 'd0;
					wr_state <= WR_IDLE;
				end
				else if(mg_byte_wr_cnt>'d52) begin
					mg_byte_wr_en <= 'd0;
					rst_fifo <= 'd0;
					mg_byte_wr_cnt <= mg_byte_wr_cnt + 'd1;
				end
				else begin
					mg_byte_wr_en <= 'd1;
					rst_fifo <= 'd1;
					mg_byte_wr_cnt <= mg_byte_wr_cnt + 'd1;
				end
			end

		endcase
	end
end

reg aud_buf_rdhold1='d0;
reg aud_buf_rdhold2='d0;
reg aud_buf_rdhold3='d0;

always @ ( posedge clk_i /* or negedge rstn_i */ )
	if(!rstn_i)
		au_rd_st <= RD_IDLE;
	else
		au_rd_st <= au_rd_st_n;

always @ ( posedge clk_i /* or negedge rstn_i */ )
  if (!rstn_i)
    begin
    	aud_buf_rdhold1 <= 'b0;
    	aud_buf_rdhold2 <= 'b0;
    	aud_buf_rdhold3 <= 'b0;
    	aud_buf_rden    <= 'b0;
    	aud_buf_rden_r  <= 'b0;
    	aud_buf_rdvld   <= 'b0;
    end
  else
    begin
    	aud_buf_rdhold1 <= (au_rd_st==RD_IDLE);
    	aud_buf_rdhold2 <= aud_buf_rdhold1;
    	aud_buf_rdhold3 <= aud_buf_rdhold2;
    	aud_buf_rden <= (au_rd_st==RD_ACTIVE);
    	aud_buf_rden_r <= aud_buf_rden;
    	aud_buf_rdvld <= aud_buf_rden_r;
    end

always @ ( posedge clk_i /* or negedge rstn_i */ )
  begin
    if ( ~rstn_i )
      begin
        aud_buf_cnt <= 'd0;
      end
	   else if(au_rd_st==RD_ACTIVE)
      begin
		      aud_buf_cnt <= aud_buf_cnt + 8'd1;
	     end
    else
      begin
		      aud_buf_cnt <= 'd0;
      end
  end

always @ ( posedge clk_i /* or negedge rstn_i */ ) begin
	if(!rstn_i) begin
		buf_sw_trig <= 'd0;
		sw_trig_st <= SW_VSYNC_TRIG;
	end
	else begin
		case(sw_trig_st)
			SW_VSYNC_TRIG : begin
                if ( sel_ping_pong_bufr_avail_ne_pl /* cam_fv_pe_pl */) begin
					if((au_rd_st==RD_IDLE)) begin
						buf_sw_trig <= 1'b1;
						sw_trig_st <= SW_VSYNC_TRIG;
					end
					else begin
						buf_sw_trig <= 1'd0;
						sw_trig_st <= DELAYED_TRIG;
					end
				end
				else begin
					buf_sw_trig <= 1'd0;
					sw_trig_st <= SW_VSYNC_TRIG;
				end
			end
			DELAYED_TRIG : begin
				if((au_rd_st==RD_IDLE)&(aud_buf_rdhold3)) begin
					sw_trig_st <= SW_VSYNC_TRIG;
					buf_sw_trig <= 1'd1;
				end
				else begin
					sw_trig_st <= DELAYED_TRIG;
					buf_sw_trig <= 1'd0;
				end
			end
		endcase
	end
end

always @* begin
	au_rd_st_n = au_rd_st;
	case(au_rd_st)
	RD_IDLE : begin
		if ( aud_buf_rd_count > 8'd96 ) // 16 bit FIFO. 96 * 2 = 192 bytes.
        begin
			au_rd_st_n = RD_HOLD;
		end
		else
			au_rd_st_n = RD_IDLE;
	end
	RD_HOLD : begin
		if ( buf_sw_trig | ( wr_state != WR_IDLE ) | ( ~sel_ping_pong_bufr_avail ) )
			au_rd_st_n = RD_HOLD;
		else
			au_rd_st_n = RD_ACTIVE;
	end
	RD_ACTIVE : begin
		// if(aud_buf_cnt>=8'd47) // because of 32 bit width of intermediate_dc_fifo
		if(aud_buf_cnt>=8'd95)
			au_rd_st_n = RD_IDLE;
		else
			au_rd_st_n = RD_ACTIVE;
	end
	endcase
end

  // This is the error case.
  // When there are 192 bytes available in Intermediate buffer and
  // Ping pong buffer is not available.
  always @ (posedge clk_i)
    begin
      if (~rstn_i)
        begin
          ping_pong_bufr_not_avail <= 1'b0;
        end
      else
        begin
          ping_pong_bufr_not_avail <= ( ( aud_buf_rd_count >= 6'd48 ) & ( ~sel_ping_pong_bufr_avail ) );
        end
    end


/*
//	Input Audio buffer
aud_buf
aud_buf_inst
(
	//.aud_buffer_Data(test_aud_data),
	// .aud_buffer_Data(i2s_rx_data),
	.aud_buffer_Data(pcm_data_r[15:0]),
	.aud_buffer_Q({i2s_data}),
	.aud_buffer_AlmostFull(aud_buf_AlmostFull),
	.aud_buffer_Clock(clk_i),
	.aud_buffer_Empty(),
	.aud_buffer_Full(),
	.aud_buffer_RdEn(aud_buf_rden),
	.aud_buffer_Reset(!rstn_i),
	// .aud_buffer_WrEn(i2s_data_vld&(!init_r))
	.aud_buffer_WrEn(pcm_mic_dout_valid_r_pl&(!init_r))
	);
*/

//----------------------------------------
//
// FIFO for Mic data
//
//----------------------------------------

  intermediate_dc_fifo
    mic_fifo
      (
       .Q            ( i2s_data ),
       .Empty        (  ),
       .Full         ( aud_buf_full ),
       .RCNT         ( aud_buf_rd_count ),
       .WCNT         (  ),

       .Data         ( mic_fifo_wr_data ),
       .WrClock      ( mic_clk_i ),
       .RdClock      ( clk_i ),
       .WrEn         ( mic_fifo_wr_req ),
       .RdEn         ( aud_buf_rden ),
       .Reset        ( ~sync_bclk_reset_n_i),
       .RPReset      ( ~sync_bclk_reset_n_i)
      );

always @(posedge clk_i /* or negedge rstn_i */) begin
	if(!rstn_i)
		rst <= 2'b11;
	else begin
		rst[0] <= ((rst_fifo) & (!wr_fifo_idx));
		rst[1] <= ((rst_fifo) & (wr_fifo_idx));
	end
end

always @(posedge clk_i /* or negedge rstn_i */)
  begin
    if (~rstn_i)
      begin
	       rst_fifo1 <= 'd0;
	       rst_fifo2 <= 'd0;
      end
    else
      begin
	       rst_fifo1 <= rst_fifo;
	       rst_fifo2 <= rst_fifo1;
      end
  end

assign wr_fifo_cnt_o = aud_rd_idx ? wr_cnt_f1 : wr_cnt_f0;

//always @ (posedge clk_i /* or negedge rstn_i */)
//  begin
//    if ( ~rstn_i )
//      begin
//        i2s_fifo_data_r <= 'd0;
//      end
//    else if ( aud_rd_idx )
//      begin
//        i2s_fifo_data_r <= i2s_fifo_dout[1];
//      end
//    else
//      begin
//        i2s_fifo_data_r <= i2s_fifo_dout[0];
//      end
//  end

always @ (posedge clk_i /* or negedge rstn_i */)
  begin
    if ( ~rstn_i )
      begin
      	i2s_wr_en[0] <= 1'b0;
      	i2s_wr_en[1] <= 1'b0;
      end
    else
      begin
      	i2s_wr_en[0] <= (i2s_wr_en_r & (!wr_fifo_idx)) || (mg_byte_wr_en & wr_fifo_idx);
      	i2s_wr_en[1] <= (i2s_wr_en_r & wr_fifo_idx)  || (mg_byte_wr_en & (!wr_fifo_idx));
      end
  end

// assign	i2s_fifo_data_o = i2s_fifo_data_r;
assign	i2s_fifo_data_o = aud_rd_idx ? i2s_fifo_dout[1] : i2s_fifo_dout[0];
assign	i2s_fifo_data_pre = aud_rd_idx ? i2s_fifo_dout[1] : i2s_fifo_dout[0];
// assign	i2s_fifo_rcnt_o = aud_rd_idx ? i2s_fifo_rcnt[1] : i2s_fifo_rcnt[0];
assign	i2s_fifo_rcnt_o = aud_rd_idx ? i2s_fifo_wcnt[1] : i2s_fifo_wcnt[0];
assign	i2s_fifo_empty_o = aud_rd_idx ? i2s_fifo_empty[1] : i2s_fifo_empty[0];
assign	i2s_fifo_almostempty_o = aud_rd_idx ? i2s_almostempty[1] : i2s_almostempty[0];
assign	i2s_fifo_rden[0] =  i2s_fifo_rd_en_i & (!aud_rd_idx);
assign	i2s_fifo_rden[1] =  i2s_fifo_rd_en_i & (aud_rd_idx);


//	Audio Buffers
// Size: 4KB * 2     = 8 KB
// Magic Bytes       = 54 * 4 = 216 Bytes
// Available Space   = 4096 - 216 = 3880 Bytes
// Total chunk of 192 bytes can be written = 3880/192 = 20
// 192 * 20          = 3840 Bytes = 3840/4 = 960 Words
// Almost Full Limit = 960 + 54 = 1014 Words

generate
  for (gi = 0; gi < 2; gi = gi + 1)
    begin : PING_PONG_BUFFERS
      ping_pong_buffer
        ping_pong_bufr
          (
           .Q             (i2s_fifo_dout[gi]),
           .WCNT          (i2s_fifo_wcnt[gi]),
           .Empty         (i2s_fifo_empty[gi]),
           .AlmostEmpty   (i2s_almostempty[gi]),
           .AlmostFull    (i2s_almostfull[gi]),
           .Full          (i2s_fifo_full[gi]),

           .Clock         (clk_i),
           .RdEn          (i2s_fifo_rden[gi]),
           .Reset         (rst[gi]),
           .WrEn          (i2s_wr_en[gi]),
           .Data          (mg_byte_wr_en_f1 ? MAGIC_WORD : i2s_wr_data_rr)

          );
    end
endgenerate

always @ (posedge clk_i /* or negedge rstn_i */)
  begin
    if ( ~rstn_i )
      begin
        wr_cnt_f0 <= 'd0;
      end
    else if (rst[0])
      begin
        wr_cnt_f0 <= 'd0;
      end
	   else if (i2s_wr_en_r & (!wr_fifo_idx))
      begin
	   	   wr_cnt_f0 <= wr_cnt_f0 + 1'd1;
      end
  end

always @ (posedge clk_i /* or negedge rstn_i */)
  begin
    if ( ~rstn_i )
      begin
        wr_cnt_f1 <= 'd0;
      end
    else if (rst[1])
      begin
        wr_cnt_f1 <= 'd0;
      end
	   else if (i2s_wr_en_r & wr_fifo_idx)
      begin
	   	   wr_cnt_f1 <= wr_cnt_f1 + 1'd1;
      end
  end



//----------------------------------
//
// PDM to PCM IP
//
//----------------------------------

always @ (posedge mic_clk_i)
  begin
    if ( ~sync_bclk_reset_n_i )
      begin
        pdm_clk_counter <= 8'd0;
      end
    else if ( pdm_clk_counter == 8'd63 )
      begin
        pdm_clk_counter <= 8'd0;
      end
    else
      begin
        pdm_clk_counter <= pdm_clk_counter + 1'b1;
      end
  end

always @ (posedge mic_clk_i)
  begin
    if ( ~sync_bclk_reset_n_i )
      begin
        pcm_mic_dout_valid_l_pl_mc <= 8'd0;
      end
    else
      begin
        pcm_mic_dout_valid_l_pl_mc <= ( pdm_clk_counter == 8'd63 );
      end
  end

  assign pcm_mic_dout_valid_r_pl_mc = pcm_mic_dout_valid_l_pl_mc;

  // Simple Flop
  always @ (posedge mic_clk_i)
    begin
      if ( ~sync_bclk_reset_n_i )
        begin
          pcm_mic_dout_valid_r_pl_mc_f1 <= 1'd0;
          pcm_mic_dout_valid_r_pl_mc_f2 <= 1'd0;
        end
      else
        begin
          pcm_mic_dout_valid_r_pl_mc_f1 <= pcm_mic_dout_valid_r_pl_mc;
          pcm_mic_dout_valid_r_pl_mc_f2 <= pcm_mic_dout_valid_r_pl_mc_f1;
        end
    end

  // Register the R mic data
  always @ (posedge mic_clk_i)
    begin
      if ( ~sync_bclk_reset_n_i )
        begin
          mic_data_r <= 16'd0;
        end
      else if (pcm_mic_dout_valid_r_pl_mc)
        begin
          mic_data_r <= pcm_data_r[15:0];
        end
    end

  // Write Request to Mic FIFO
  always @ (posedge mic_clk_i)
    begin
      if ( ~sync_bclk_reset_n_i )
        begin
          mic_fifo_wr_req <= 1'd0;
        end
      else
        begin
          mic_fifo_wr_req <= ((pcm_mic_dout_valid_l_pl_mc | pcm_mic_dout_valid_r_pl_mc_f2) & (~aud_buf_full));
        end
    end

  // Write Data
  always @ (posedge mic_clk_i)
    begin
      if ( ~sync_bclk_reset_n_i )
        begin
          mic_fifo_wr_data <= 16'd0;
        end
      else if (pcm_mic_dout_valid_l_pl_mc)
        begin
          mic_fifo_wr_data <= 16'h1111;
        end
      else if (pcm_mic_dout_valid_r_pl_mc_f2)
        begin
          mic_fifo_wr_data <= 16'h2222;
        end
    end

//----------------------------------------
//
// Ping Pong Buffer Availability
//
//----------------------------------------

  always @ ( posedge clk_i )
    begin
      if ( ~rstn_i )
        begin
          i2s_fifo_rden_f1    <= 1'b0;
          i2s_fifo_data_vld_o <= 1'b0;
        end
      else
        begin
          i2s_fifo_rden_f1    <= (i2s_fifo_rden[0] | i2s_fifo_rden[1]);
          i2s_fifo_data_vld_o <= i2s_fifo_rden_f1;
        end
    end

  // Counter for counting how many words are written in ping pong buffer
  always @ ( posedge clk_i )
    begin
      if ( ~rstn_i )
        begin
          ping_pong_bufr_wr_words <= 12'b0;
        end
      else if ( sel_ping_pong_bufr_avail_ne_pl )
        begin
          ping_pong_bufr_wr_words <= 12'b0;
        end
      else if ( i2s_wr_en_r )
        begin
          ping_pong_bufr_wr_words <= ( ping_pong_bufr_wr_words + 1'b1 );
        end
    end

  // After writing 96x20 = 1920 words, it will be unavailable.
  always @ ( posedge clk_i )
    begin
      if ( ~rstn_i )
        begin
          sel_ping_pong_bufr_avail <= 1'b0;
        end
      else
        begin
          sel_ping_pong_bufr_avail <= ( ping_pong_bufr_wr_words < 10'd960 );
        end
    end


// Simple flop signals
always @ (posedge clk_i /* or negedge rstn_i */)
  begin
    if ( ~rstn_i )
      begin
        sel_ping_pong_bufr_avail_f1 <= 1'b0;
        sel_ping_pong_bufr_avail_f2 <= 1'b0;
      end
    else
      begin
        sel_ping_pong_bufr_avail_f1 <= sel_ping_pong_bufr_avail;
        sel_ping_pong_bufr_avail_f2 <= sel_ping_pong_bufr_avail_f1;
      end
  end

// Falling edge of the 'sel_ping_pong_bufr_avail'
  assign sel_ping_pong_bufr_avail_ne_pl = ( ( ~sel_ping_pong_bufr_avail_f1 ) & ( sel_ping_pong_bufr_avail_f2 ) );

  always @ ( posedge clk_i )
    begin
      if ( ~rstn_i )
        begin
          ping_pong_bufr_rd_words <= 10'b0;
        end
      else if ( aud_rd_idx )
        begin
          ping_pong_bufr_rd_words <= 10'b0;
        end
      else if ( i2s_fifo_rden[0] )
        begin
          ping_pong_bufr_rd_words <= ( ping_pong_bufr_rd_words + 1'b1 );
        end
    end

endmodule

