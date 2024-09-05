--VHDL instantiation template

component pll is
    port (pll_ip_CLKI: in std_logic;
        pll_ip_CLKOP: out std_logic;
        pll_ip_LOCK: out std_logic
    );
    
end component pll; -- sbp_module=true 
_inst: pll port map (pll_ip_CLKI => __,pll_ip_CLKOP => __,pll_ip_LOCK => __);
