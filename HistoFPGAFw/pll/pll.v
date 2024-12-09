/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module pll
//
module pll (pll_i_CLKI, pll_i_CLKOP, pll_i_CLKOS, pll_i_LOCK) /* synthesis sbp_module=true */ ;
    input pll_i_CLKI;
    output pll_i_CLKOP;
    output pll_i_CLKOS;
    output pll_i_LOCK;
    
    
    pll_i pll_i_inst (.CLKI(pll_i_CLKI), .CLKOP(pll_i_CLKOP), .CLKOS(pll_i_CLKOS), 
          .LOCK(pll_i_LOCK));
    
endmodule

