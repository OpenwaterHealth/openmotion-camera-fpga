//Verilog instantiation template

byte_pixel _inst (.byte2pix_dt_i(), .byte2pix_p_odd_o(), .byte2pix_payload_i(), 
           .byte2pix_pd_o(), .byte2pix_wc_i(), .byte2pix_clk_byte_i(), 
           .byte2pix_clk_pixel_i(), .byte2pix_fv_o(), .byte2pix_lp_av_en_i(), 
           .byte2pix_lv_o(), .byte2pix_payload_en_i(), .byte2pix_reset_byte_n_i(), 
           .byte2pix_reset_pixel_n_i(), .byte2pix_sp_en_i());