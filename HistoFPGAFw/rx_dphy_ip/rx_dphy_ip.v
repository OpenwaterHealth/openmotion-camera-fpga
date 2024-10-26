/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module rx_dphy_ip
//
module rx_dphy_ip (csi_dphy_rx_bd_o, csi_dphy_rx_dt_o, csi_dphy_rx_ecc_o, 
            csi_dphy_rx_lp_hs_state_clk_o, csi_dphy_rx_lp_hs_state_d_o, 
            csi_dphy_rx_payload_o, csi_dphy_rx_ref_dt_i, csi_dphy_rx_vc_o, 
            csi_dphy_rx_wc_o, csi_dphy_rx_cd_d0_o, csi_dphy_rx_clk_byte_fr_i, 
            csi_dphy_rx_clk_byte_hs_o, csi_dphy_rx_clk_byte_o, csi_dphy_rx_clk_lp_ctrl_i, 
            csi_dphy_rx_clk_n_i, csi_dphy_rx_clk_p_i, csi_dphy_rx_d0_n_i, 
            csi_dphy_rx_d0_p_i, csi_dphy_rx_d1_n_i, csi_dphy_rx_d1_p_i, 
            csi_dphy_rx_hs_d_en_o, csi_dphy_rx_hs_sync_o, csi_dphy_rx_lp_av_en_o, 
            csi_dphy_rx_lp_d0_rx_n_o, csi_dphy_rx_lp_d0_rx_p_o, csi_dphy_rx_lp_d1_rx_n_o, 
            csi_dphy_rx_lp_d1_rx_p_o, csi_dphy_rx_lp_en_o, csi_dphy_rx_payload_en_o, 
            csi_dphy_rx_pd_dphy_i, csi_dphy_rx_pll_lock_i, csi_dphy_rx_reset_byte_fr_n_i, 
            csi_dphy_rx_reset_byte_n_i, csi_dphy_rx_reset_lp_n_i, csi_dphy_rx_reset_n_i, 
            csi_dphy_rx_sp_en_o, csi_dphy_rx_term_clk_en_o) /* synthesis sbp_module=true */ ;
    output [15:0]csi_dphy_rx_bd_o;
    output [5:0]csi_dphy_rx_dt_o;
    output [7:0]csi_dphy_rx_ecc_o;
    output [1:0]csi_dphy_rx_lp_hs_state_clk_o;
    output [1:0]csi_dphy_rx_lp_hs_state_d_o;
    output [31:0]csi_dphy_rx_payload_o;
    input [5:0]csi_dphy_rx_ref_dt_i;
    output [1:0]csi_dphy_rx_vc_o;
    output [15:0]csi_dphy_rx_wc_o;
    output csi_dphy_rx_cd_d0_o;
    input csi_dphy_rx_clk_byte_fr_i;
    output csi_dphy_rx_clk_byte_hs_o;
    output csi_dphy_rx_clk_byte_o;
    input csi_dphy_rx_clk_lp_ctrl_i;
    inout csi_dphy_rx_clk_n_i;
    inout csi_dphy_rx_clk_p_i;
    inout csi_dphy_rx_d0_n_i;
    inout csi_dphy_rx_d0_p_i;
    inout csi_dphy_rx_d1_n_i;
    inout csi_dphy_rx_d1_p_i;
    output csi_dphy_rx_hs_d_en_o;
    output csi_dphy_rx_hs_sync_o;
    output csi_dphy_rx_lp_av_en_o;
    output csi_dphy_rx_lp_d0_rx_n_o;
    output csi_dphy_rx_lp_d0_rx_p_o;
    output csi_dphy_rx_lp_d1_rx_n_o;
    output csi_dphy_rx_lp_d1_rx_p_o;
    output csi_dphy_rx_lp_en_o;
    output csi_dphy_rx_payload_en_o;
    input csi_dphy_rx_pd_dphy_i;
    input csi_dphy_rx_pll_lock_i;
    input csi_dphy_rx_reset_byte_fr_n_i;
    input csi_dphy_rx_reset_byte_n_i;
    input csi_dphy_rx_reset_lp_n_i;
    input csi_dphy_rx_reset_n_i;
    output csi_dphy_rx_sp_en_o;
    output csi_dphy_rx_term_clk_en_o;
    
    
    csi_dphy_rx csi_dphy_rx_inst (.bd_o({csi_dphy_rx_bd_o}), .dt_o({csi_dphy_rx_dt_o}), 
            .ecc_o({csi_dphy_rx_ecc_o}), .lp_hs_state_clk_o({csi_dphy_rx_lp_hs_state_clk_o}), 
            .lp_hs_state_d_o({csi_dphy_rx_lp_hs_state_d_o}), .payload_o({csi_dphy_rx_payload_o}), 
            .ref_dt_i({csi_dphy_rx_ref_dt_i}), .vc_o({csi_dphy_rx_vc_o}), 
            .wc_o({csi_dphy_rx_wc_o}), .cd_d0_o(csi_dphy_rx_cd_d0_o), .clk_byte_fr_i(csi_dphy_rx_clk_byte_fr_i), 
            .clk_byte_hs_o(csi_dphy_rx_clk_byte_hs_o), .clk_byte_o(csi_dphy_rx_clk_byte_o), 
            .clk_lp_ctrl_i(csi_dphy_rx_clk_lp_ctrl_i), .clk_n_i(csi_dphy_rx_clk_n_i), 
            .clk_p_i(csi_dphy_rx_clk_p_i), .d0_n_i(csi_dphy_rx_d0_n_i), 
            .d0_p_i(csi_dphy_rx_d0_p_i), .d1_n_i(csi_dphy_rx_d1_n_i), .d1_p_i(csi_dphy_rx_d1_p_i), 
            .hs_d_en_o(csi_dphy_rx_hs_d_en_o), .hs_sync_o(csi_dphy_rx_hs_sync_o), 
            .lp_av_en_o(csi_dphy_rx_lp_av_en_o), .lp_d0_rx_n_o(csi_dphy_rx_lp_d0_rx_n_o), 
            .lp_d0_rx_p_o(csi_dphy_rx_lp_d0_rx_p_o), .lp_d1_rx_n_o(csi_dphy_rx_lp_d1_rx_n_o), 
            .lp_d1_rx_p_o(csi_dphy_rx_lp_d1_rx_p_o), .lp_en_o(csi_dphy_rx_lp_en_o), 
            .payload_en_o(csi_dphy_rx_payload_en_o), .pd_dphy_i(csi_dphy_rx_pd_dphy_i), 
            .pll_lock_i(csi_dphy_rx_pll_lock_i), .reset_byte_fr_n_i(csi_dphy_rx_reset_byte_fr_n_i), 
            .reset_byte_n_i(csi_dphy_rx_reset_byte_n_i), .reset_lp_n_i(csi_dphy_rx_reset_lp_n_i), 
            .reset_n_i(csi_dphy_rx_reset_n_i), .sp_en_o(csi_dphy_rx_sp_en_o), 
            .term_clk_en_o(csi_dphy_rx_term_clk_en_o));
    
endmodule

