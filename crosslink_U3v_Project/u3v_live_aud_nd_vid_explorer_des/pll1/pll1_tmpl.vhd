--VHDL instantiation template

component pll1 is
    port (pll1_ip_CLKI: in std_logic;
        pll1_ip_CLKOP: out std_logic;
        pll1_ip_LOCK: out std_logic
    );
    
end component pll1; -- sbp_module=true 
_inst: pll1 port map (pll1_ip_CLKI => __,pll1_ip_CLKOP => __,pll1_ip_LOCK => __);
