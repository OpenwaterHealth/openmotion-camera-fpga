--VHDL instantiation template

component rx_dphy_ip is
    port (csi_dphy_rx_bd_o: out std_logic_vector(15 downto 0);
        csi_dphy_rx_dt_o: out std_logic_vector(5 downto 0);
        csi_dphy_rx_ecc_o: out std_logic_vector(7 downto 0);
        csi_dphy_rx_lp_hs_state_clk_o: out std_logic_vector(1 downto 0);
        csi_dphy_rx_lp_hs_state_d_o: out std_logic_vector(1 downto 0);
        csi_dphy_rx_payload_o: out std_logic_vector(15 downto 0);
        csi_dphy_rx_ref_dt_i: in std_logic_vector(5 downto 0);
        csi_dphy_rx_vc_o: out std_logic_vector(1 downto 0);
        csi_dphy_rx_wc_o: out std_logic_vector(15 downto 0);
        csi_dphy_rx_cd_d0_o: out std_logic;
        csi_dphy_rx_clk_byte_fr_i: in std_logic;
        csi_dphy_rx_clk_byte_hs_o: out std_logic;
        csi_dphy_rx_clk_byte_o: out std_logic;
        csi_dphy_rx_clk_lp_ctrl_i: in std_logic;
        csi_dphy_rx_clk_n_i: inout std_logic;
        csi_dphy_rx_clk_p_i: inout std_logic;
        csi_dphy_rx_d0_n_i: inout std_logic;
        csi_dphy_rx_d0_p_i: inout std_logic;
        csi_dphy_rx_d1_n_i: inout std_logic;
        csi_dphy_rx_d1_p_i: inout std_logic;
        csi_dphy_rx_hs_d_en_o: out std_logic;
        csi_dphy_rx_hs_sync_o: out std_logic;
        csi_dphy_rx_lp_av_en_o: out std_logic;
        csi_dphy_rx_lp_d0_rx_n_o: out std_logic;
        csi_dphy_rx_lp_d0_rx_p_o: out std_logic;
        csi_dphy_rx_lp_d1_rx_n_o: out std_logic;
        csi_dphy_rx_lp_d1_rx_p_o: out std_logic;
        csi_dphy_rx_lp_en_o: out std_logic;
        csi_dphy_rx_payload_en_o: out std_logic;
        csi_dphy_rx_pd_dphy_i: in std_logic;
        csi_dphy_rx_pll_lock_i: in std_logic;
        csi_dphy_rx_reset_byte_fr_n_i: in std_logic;
        csi_dphy_rx_reset_byte_n_i: in std_logic;
        csi_dphy_rx_reset_lp_n_i: in std_logic;
        csi_dphy_rx_reset_n_i: in std_logic;
        csi_dphy_rx_sp_en_o: out std_logic;
        csi_dphy_rx_term_clk_en_o: out std_logic
    );
    
end component rx_dphy_ip; -- sbp_module=true 
_inst: rx_dphy_ip port map (csi_dphy_rx_bd_o => __,csi_dphy_rx_dt_o => __,
            csi_dphy_rx_ecc_o => __,csi_dphy_rx_lp_hs_state_clk_o => __,csi_dphy_rx_lp_hs_state_d_o => __,
            csi_dphy_rx_payload_o => __,csi_dphy_rx_ref_dt_i => __,csi_dphy_rx_vc_o => __,
            csi_dphy_rx_wc_o => __,csi_dphy_rx_cd_d0_o => __,csi_dphy_rx_clk_byte_fr_i => __,
            csi_dphy_rx_clk_byte_hs_o => __,csi_dphy_rx_clk_byte_o => __,csi_dphy_rx_clk_lp_ctrl_i => __,
            csi_dphy_rx_clk_n_i => __,csi_dphy_rx_clk_p_i => __,csi_dphy_rx_d0_n_i => __,
            csi_dphy_rx_d0_p_i => __,csi_dphy_rx_d1_n_i => __,csi_dphy_rx_d1_p_i => __,
            csi_dphy_rx_hs_d_en_o => __,csi_dphy_rx_hs_sync_o => __,csi_dphy_rx_lp_av_en_o => __,
            csi_dphy_rx_lp_d0_rx_n_o => __,csi_dphy_rx_lp_d0_rx_p_o => __,
            csi_dphy_rx_lp_d1_rx_n_o => __,csi_dphy_rx_lp_d1_rx_p_o => __,
            csi_dphy_rx_lp_en_o => __,csi_dphy_rx_payload_en_o => __,csi_dphy_rx_pd_dphy_i => __,
            csi_dphy_rx_pll_lock_i => __,csi_dphy_rx_reset_byte_fr_n_i => __,
            csi_dphy_rx_reset_byte_n_i => __,csi_dphy_rx_reset_lp_n_i => __,
            csi_dphy_rx_reset_n_i => __,csi_dphy_rx_sp_en_o => __,csi_dphy_rx_term_clk_en_o => __);
