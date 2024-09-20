--VHDL instantiation template

component byte_pixel is
    port (byte2pix_dt_i: in std_logic_vector(5 downto 0);
        byte2pix_p_odd_o: out std_logic_vector(1 downto 0);
        byte2pix_payload_i: in std_logic_vector(31 downto 0);
        byte2pix_pd_o: out std_logic_vector(9 downto 0);
        byte2pix_wc_i: in std_logic_vector(15 downto 0);
        byte2pix_clk_byte_i: in std_logic;
        byte2pix_clk_pixel_i: in std_logic;
        byte2pix_fv_o: out std_logic;
        byte2pix_lp_av_en_i: in std_logic;
        byte2pix_lv_o: out std_logic;
        byte2pix_payload_en_i: in std_logic;
        byte2pix_reset_byte_n_i: in std_logic;
        byte2pix_reset_pixel_n_i: in std_logic;
        byte2pix_sp_en_i: in std_logic
    );
    
end component byte_pixel; -- sbp_module=true 
_inst: byte_pixel port map (byte2pix_dt_i => __,byte2pix_p_odd_o => __,byte2pix_payload_i => __,
            byte2pix_pd_o => __,byte2pix_wc_i => __,byte2pix_clk_byte_i => __,
            byte2pix_clk_pixel_i => __,byte2pix_fv_o => __,byte2pix_lp_av_en_i => __,
            byte2pix_lv_o => __,byte2pix_payload_en_i => __,byte2pix_reset_byte_n_i => __,
            byte2pix_reset_pixel_n_i => __,byte2pix_sp_en_i => __);
