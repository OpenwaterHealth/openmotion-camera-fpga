--VHDL instantiation template

component vid_buf_fifo is
    port (vid_fifo_Data: in std_logic_vector(31 downto 0);
        vid_fifo_Q: out std_logic_vector(31 downto 0);
        vid_fifo_AlmostEmpty: out std_logic;
        vid_fifo_AlmostFull: out std_logic;
        vid_fifo_Empty: out std_logic;
        vid_fifo_Full: out std_logic;
        vid_fifo_RPReset: in std_logic;
        vid_fifo_RdClock: in std_logic;
        vid_fifo_RdEn: in std_logic;
        vid_fifo_Reset: in std_logic;
        vid_fifo_WrClock: in std_logic;
        vid_fifo_WrEn: in std_logic
    );
    
end component vid_buf_fifo; -- sbp_module=true 
_inst: vid_buf_fifo port map (vid_fifo_Data => __,vid_fifo_Q => __,vid_fifo_AlmostEmpty => __,
            vid_fifo_AlmostFull => __,vid_fifo_Empty => __,vid_fifo_Full => __,
            vid_fifo_RPReset => __,vid_fifo_RdClock => __,vid_fifo_RdEn => __,
            vid_fifo_Reset => __,vid_fifo_WrClock => __,vid_fifo_WrEn => __);
