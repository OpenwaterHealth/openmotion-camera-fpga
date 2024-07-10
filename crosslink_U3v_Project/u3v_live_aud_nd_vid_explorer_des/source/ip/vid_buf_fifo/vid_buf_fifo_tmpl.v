//Verilog instantiation template

vid_buf_fifo _inst (.vid_fifo_Data(), .vid_fifo_Q(), .vid_fifo_AlmostEmpty(), 
            .vid_fifo_AlmostFull(), .vid_fifo_Empty(), .vid_fifo_Full(), 
            .vid_fifo_RPReset(), .vid_fifo_RdClock(), .vid_fifo_RdEn(), 
            .vid_fifo_Reset(), .vid_fifo_WrClock(), .vid_fifo_WrEn());