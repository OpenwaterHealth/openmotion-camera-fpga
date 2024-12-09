--VHDL instantiation template

component ram_dp is
    port (ram_dp_s_Data: in std_logic_vector(23 downto 0);
        ram_dp_s_Q: out std_logic_vector(23 downto 0);
        ram_dp_s_RdAddress: in std_logic_vector(9 downto 0);
        ram_dp_s_WrAddress: in std_logic_vector(9 downto 0);
        ram_dp_s_RdClock: in std_logic;
        ram_dp_s_RdClockEn: in std_logic;
        ram_dp_s_Reset: in std_logic;
        ram_dp_s_WE: in std_logic;
        ram_dp_s_WrClock: in std_logic;
        ram_dp_s_WrClockEn: in std_logic
    );
    
end component ram_dp; -- sbp_module=true 
_inst: ram_dp port map (ram_dp_s_Data => __,ram_dp_s_Q => __,ram_dp_s_RdAddress => __,
            ram_dp_s_WrAddress => __,ram_dp_s_RdClock => __,ram_dp_s_RdClockEn => __,
            ram_dp_s_Reset => __,ram_dp_s_WE => __,ram_dp_s_WrClock => __,
            ram_dp_s_WrClockEn => __);
