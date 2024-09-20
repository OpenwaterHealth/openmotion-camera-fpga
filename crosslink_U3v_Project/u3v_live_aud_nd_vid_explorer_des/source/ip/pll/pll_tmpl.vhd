--VHDL instantiation template

component pll is
    port (ram_dq_s_Address: in std_logic_vector(9 downto 0);
        ram_dq_s_Data: in std_logic_vector(23 downto 0);
        ram_dq_s_Q: out std_logic_vector(23 downto 0);
        pll_ip_CLKI: in std_logic;
        pll_ip_CLKOP: out std_logic;
        pll_ip_LOCK: out std_logic;
        ram_dq_s_Clock: in std_logic;
        ram_dq_s_ClockEn: in std_logic;
        ram_dq_s_Reset: in std_logic;
        ram_dq_s_WE: in std_logic
    );
    
end component pll; -- sbp_module=true 
_inst: pll port map (pll_ip_CLKI => __,pll_ip_CLKOP => __,pll_ip_LOCK => __,
          ram_dq_s_Address => __,ram_dq_s_Data => __,ram_dq_s_Q => __,ram_dq_s_Clock => __,
          ram_dq_s_ClockEn => __,ram_dq_s_Reset => __,ram_dq_s_WE => __);
