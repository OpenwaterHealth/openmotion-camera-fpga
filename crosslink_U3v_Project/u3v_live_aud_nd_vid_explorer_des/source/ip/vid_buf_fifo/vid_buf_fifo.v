/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module vid_buf_fifo
//
module vid_buf_fifo (vid_fifo_Data, vid_fifo_Q, vid_fifo_AlmostEmpty, 
            vid_fifo_AlmostFull, vid_fifo_Empty, vid_fifo_Full, vid_fifo_RPReset, 
            vid_fifo_RdClock, vid_fifo_RdEn, vid_fifo_Reset, vid_fifo_WrClock, 
            vid_fifo_WrEn) /* synthesis sbp_module=true */ ;
    input [31:0]vid_fifo_Data;
    output [31:0]vid_fifo_Q;
    output vid_fifo_AlmostEmpty;
    output vid_fifo_AlmostFull;
    output vid_fifo_Empty;
    output vid_fifo_Full;
    input vid_fifo_RPReset;
    input vid_fifo_RdClock;
    input vid_fifo_RdEn;
    input vid_fifo_Reset;
    input vid_fifo_WrClock;
    input vid_fifo_WrEn;
    
    
    vid_fifo vid_fifo_inst (.Data({vid_fifo_Data}), .Q({vid_fifo_Q}), .AlmostEmpty(vid_fifo_AlmostEmpty), 
            .AlmostFull(vid_fifo_AlmostFull), .Empty(vid_fifo_Empty), .Full(vid_fifo_Full), 
            .RPReset(vid_fifo_RPReset), .RdClock(vid_fifo_RdClock), .RdEn(vid_fifo_RdEn), 
            .Reset(vid_fifo_Reset), .WrClock(vid_fifo_WrClock), .WrEn(vid_fifo_WrEn));
    
endmodule

