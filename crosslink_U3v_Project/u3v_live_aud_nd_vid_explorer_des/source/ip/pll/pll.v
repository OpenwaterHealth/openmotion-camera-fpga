/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module pll
//
module pll (pll_ip_CLKI, pll_ip_CLKOP, pll_ip_CLKOS, pll_ip_LOCK) /* synthesis sbp_module=true */ ;
    input pll_ip_CLKI;
    output pll_ip_CLKOP;
    output pll_ip_CLKOS;
    output pll_ip_LOCK;
    
    
    pll_ip pll_ip_inst (.CLKI(pll_ip_CLKI), .CLKOP(pll_ip_CLKOP), .CLKOS(pll_ip_CLKOS), 
           .LOCK(pll_ip_LOCK));
    
endmodule

