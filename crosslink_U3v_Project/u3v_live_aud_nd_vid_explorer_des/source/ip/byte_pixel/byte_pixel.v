/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module byte_pixel
//
module byte_pixel (byte2pix_dt_i, byte2pix_p_odd_o, byte2pix_payload_i, 
            byte2pix_pd_o, byte2pix_wc_i, byte2pix_clk_byte_i, byte2pix_clk_pixel_i, 
            byte2pix_fv_o, byte2pix_lp_av_en_i, byte2pix_lv_o, byte2pix_payload_en_i, 
            byte2pix_reset_byte_n_i, byte2pix_reset_pixel_n_i, byte2pix_sp_en_i) /* synthesis sbp_module=true */ ;
    input [5:0]byte2pix_dt_i;
    output [1:0]byte2pix_p_odd_o;
    input [31:0]byte2pix_payload_i;
    output [9:0]byte2pix_pd_o;
    input [15:0]byte2pix_wc_i;
    input byte2pix_clk_byte_i;
    input byte2pix_clk_pixel_i;
    output byte2pix_fv_o;
    input byte2pix_lp_av_en_i;
    output byte2pix_lv_o;
    input byte2pix_payload_en_i;
    input byte2pix_reset_byte_n_i;
    input byte2pix_reset_pixel_n_i;
    input byte2pix_sp_en_i;
    
    
    byte2pix byte2pix_inst (.dt_i({byte2pix_dt_i}), .p_odd_o({byte2pix_p_odd_o}), 
            .payload_i({byte2pix_payload_i}), .pd_o({byte2pix_pd_o}), .wc_i({byte2pix_wc_i}), 
            .clk_byte_i(byte2pix_clk_byte_i), .clk_pixel_i(byte2pix_clk_pixel_i), 
            .fv_o(byte2pix_fv_o), .lp_av_en_i(byte2pix_lp_av_en_i), .lv_o(byte2pix_lv_o), 
            .payload_en_i(byte2pix_payload_en_i), .reset_byte_n_i(byte2pix_reset_byte_n_i), 
            .reset_pixel_n_i(byte2pix_reset_pixel_n_i), .sp_en_i(byte2pix_sp_en_i));
    
endmodule

