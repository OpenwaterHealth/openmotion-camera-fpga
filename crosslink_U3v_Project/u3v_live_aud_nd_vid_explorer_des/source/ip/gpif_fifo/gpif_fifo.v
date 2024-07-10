/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module gpif_fifo
//
module gpif_fifo (gpif_fifo_ip_Data, gpif_fifo_ip_Q, gpif_fifo_ip_AlmostEmpty, 
            gpif_fifo_ip_AlmostFull, gpif_fifo_ip_Empty, gpif_fifo_ip_Full, 
            gpif_fifo_ip_RPReset, gpif_fifo_ip_RdClock, gpif_fifo_ip_RdEn, 
            gpif_fifo_ip_Reset, gpif_fifo_ip_WrClock, gpif_fifo_ip_WrEn) /* synthesis sbp_module=true */ ;
    input [15:0]gpif_fifo_ip_Data;
    output [15:0]gpif_fifo_ip_Q;
    output gpif_fifo_ip_AlmostEmpty;
    output gpif_fifo_ip_AlmostFull;
    output gpif_fifo_ip_Empty;
    output gpif_fifo_ip_Full;
    input gpif_fifo_ip_RPReset;
    input gpif_fifo_ip_RdClock;
    input gpif_fifo_ip_RdEn;
    input gpif_fifo_ip_Reset;
    input gpif_fifo_ip_WrClock;
    input gpif_fifo_ip_WrEn;
    
    
    gpif_fifo_ip gpif_fifo_ip_inst (.Data({gpif_fifo_ip_Data}), .Q({gpif_fifo_ip_Q}), 
            .AlmostEmpty(gpif_fifo_ip_AlmostEmpty), .AlmostFull(gpif_fifo_ip_AlmostFull), 
            .Empty(gpif_fifo_ip_Empty), .Full(gpif_fifo_ip_Full), .RPReset(gpif_fifo_ip_RPReset), 
            .RdClock(gpif_fifo_ip_RdClock), .RdEn(gpif_fifo_ip_RdEn), .Reset(gpif_fifo_ip_Reset), 
            .WrClock(gpif_fifo_ip_WrClock), .WrEn(gpif_fifo_ip_WrEn));
    
endmodule

