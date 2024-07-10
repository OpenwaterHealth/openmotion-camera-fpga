/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module pll1
//
module pll1 (pll1_ip_CLKI, pll1_ip_CLKOP, pll1_ip_LOCK) /* synthesis sbp_module=true */ ;
    input pll1_ip_CLKI;
    output pll1_ip_CLKOP;
    output pll1_ip_LOCK;
    
    
    pll1_ip pll1_ip_inst (.CLKI(pll1_ip_CLKI), .CLKOP(pll1_ip_CLKOP), .LOCK(pll1_ip_LOCK));
    
endmodule

