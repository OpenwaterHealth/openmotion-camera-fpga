/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module ram_dp
//
module ram_dp (ram_dp_s_Data, ram_dp_s_Q, ram_dp_s_RdAddress, ram_dp_s_WrAddress, 
            ram_dp_s_RdClock, ram_dp_s_RdClockEn, ram_dp_s_Reset, ram_dp_s_WE, 
            ram_dp_s_WrClock, ram_dp_s_WrClockEn) /* synthesis sbp_module=true */ ;
    input [23:0]ram_dp_s_Data;
    output [23:0]ram_dp_s_Q;
    input [9:0]ram_dp_s_RdAddress;
    input [9:0]ram_dp_s_WrAddress;
    input ram_dp_s_RdClock;
    input ram_dp_s_RdClockEn;
    input ram_dp_s_Reset;
    input ram_dp_s_WE;
    input ram_dp_s_WrClock;
    input ram_dp_s_WrClockEn;
    
    
    ram_dp_s ram_dp_s_inst (.Data({ram_dp_s_Data}), .Q({ram_dp_s_Q}), .RdAddress({ram_dp_s_RdAddress}), 
            .WrAddress({ram_dp_s_WrAddress}), .RdClock(ram_dp_s_RdClock), 
            .RdClockEn(ram_dp_s_RdClockEn), .Reset(ram_dp_s_Reset), .WE(ram_dp_s_WE), 
            .WrClock(ram_dp_s_WrClock), .WrClockEn(ram_dp_s_WrClockEn));
    
endmodule

