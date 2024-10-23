/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module pll
//
module pll (ram_dq_s_Address, ram_dq_s_Data, ram_dq_s_Q, pll_ip_CLKI, 
            pll_ip_CLKOP, pll_ip_LOCK, ram_dq_s_Clock, ram_dq_s_ClockEn, 
            ram_dq_s_Reset, ram_dq_s_WE) /* synthesis sbp_module=true */ ;
    input [9:0]ram_dq_s_Address;
    input [23:0]ram_dq_s_Data;
    output [23:0]ram_dq_s_Q;
    input pll_ip_CLKI;
    output pll_ip_CLKOP;
    output pll_ip_LOCK;
    input ram_dq_s_Clock;
    input ram_dq_s_ClockEn;
    input ram_dq_s_Reset;
    input ram_dq_s_WE;
    
    
    pll_ip pll_ip_inst (.CLKI(pll_ip_CLKI), .CLKOP(pll_ip_CLKOP), .LOCK(pll_ip_LOCK));
    ram_dq_s ram_dq_s_inst (.Address({ram_dq_s_Address}), .Data({ram_dq_s_Data}), 
            .Q({ram_dq_s_Q}), .Clock(ram_dq_s_Clock), .ClockEn(ram_dq_s_ClockEn), 
            .Reset(ram_dq_s_Reset), .WE(ram_dq_s_WE));
    
endmodule

