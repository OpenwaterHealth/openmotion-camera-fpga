//Verilog instantiation template

pll _inst (.pll_ip_CLKI(), .pll_ip_CLKOP(), .pll_ip_LOCK(), .ram_dq_s_Address(), 
    .ram_dq_s_Data(), .ram_dq_s_Q(), .ram_dq_s_Clock(), .ram_dq_s_ClockEn(), 
    .ram_dq_s_Reset(), .ram_dq_s_WE());