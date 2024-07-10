--VHDL instantiation template

component gpif_fifo is
    port (gpif_fifo_ip_Data: in std_logic_vector(15 downto 0);
        gpif_fifo_ip_Q: out std_logic_vector(15 downto 0);
        gpif_fifo_ip_AlmostEmpty: out std_logic;
        gpif_fifo_ip_AlmostFull: out std_logic;
        gpif_fifo_ip_Empty: out std_logic;
        gpif_fifo_ip_Full: out std_logic;
        gpif_fifo_ip_RPReset: in std_logic;
        gpif_fifo_ip_RdClock: in std_logic;
        gpif_fifo_ip_RdEn: in std_logic;
        gpif_fifo_ip_Reset: in std_logic;
        gpif_fifo_ip_WrClock: in std_logic;
        gpif_fifo_ip_WrEn: in std_logic
    );
    
end component gpif_fifo; -- sbp_module=true 
_inst: gpif_fifo port map (gpif_fifo_ip_Data => __,gpif_fifo_ip_Q => __,gpif_fifo_ip_AlmostEmpty => __,
            gpif_fifo_ip_AlmostFull => __,gpif_fifo_ip_Empty => __,gpif_fifo_ip_Full => __,
            gpif_fifo_ip_RPReset => __,gpif_fifo_ip_RdClock => __,gpif_fifo_ip_RdEn => __,
            gpif_fifo_ip_Reset => __,gpif_fifo_ip_WrClock => __,gpif_fifo_ip_WrEn => __);
