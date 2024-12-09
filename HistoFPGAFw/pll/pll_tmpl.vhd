--VHDL instantiation template

component pll is
    port (pll_i_CLKI: in std_logic;
        pll_i_CLKOP: out std_logic;
        pll_i_CLKOS: out std_logic;
        pll_i_LOCK: out std_logic
    );
    
end component pll; -- sbp_module=true 
_inst: pll port map (pll_i_CLKI => __,pll_i_CLKOP => __,pll_i_CLKOS => __,
          pll_i_LOCK => __);
