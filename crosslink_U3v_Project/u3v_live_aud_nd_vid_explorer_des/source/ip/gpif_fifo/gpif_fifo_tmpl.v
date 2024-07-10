//Verilog instantiation template

gpif_fifo _inst (.gpif_fifo_ip_Data(), .gpif_fifo_ip_Q(), .gpif_fifo_ip_AlmostEmpty(), 
          .gpif_fifo_ip_AlmostFull(), .gpif_fifo_ip_Empty(), .gpif_fifo_ip_Full(), 
          .gpif_fifo_ip_RPReset(), .gpif_fifo_ip_RdClock(), .gpif_fifo_ip_RdEn(), 
          .gpif_fifo_ip_Reset(), .gpif_fifo_ip_WrClock(), .gpif_fifo_ip_WrEn());