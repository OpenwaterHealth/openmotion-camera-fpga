// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.13.0.56.2
// Netlist written on Thu Sep 05 13:35:40 2024
//
// Verilog Description of module pll_ip
//

module pll_ip (CLKI, CLKOP, CLKOS2, LOCK) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // c:/users/ethanhead/desktop/gen3-cam-fw/crosslink_u3v_project/u3v_live_aud_nd_vid_explorer_des/source/ip/pll/pll_ip/pll_ip.v(8[8:14])
    input CLKI;   // c:/users/ethanhead/desktop/gen3-cam-fw/crosslink_u3v_project/u3v_live_aud_nd_vid_explorer_des/source/ip/pll/pll_ip/pll_ip.v(9[16:20])
    output CLKOP;   // c:/users/ethanhead/desktop/gen3-cam-fw/crosslink_u3v_project/u3v_live_aud_nd_vid_explorer_des/source/ip/pll/pll_ip/pll_ip.v(10[17:22])
    output CLKOS2;   // c:/users/ethanhead/desktop/gen3-cam-fw/crosslink_u3v_project/u3v_live_aud_nd_vid_explorer_des/source/ip/pll/pll_ip/pll_ip.v(11[17:23])
    output LOCK;   // c:/users/ethanhead/desktop/gen3-cam-fw/crosslink_u3v_project/u3v_live_aud_nd_vid_explorer_des/source/ip/pll/pll_ip/pll_ip.v(12[17:21])
    
    wire CLKI /* synthesis is_clock=1 */ ;   // c:/users/ethanhead/desktop/gen3-cam-fw/crosslink_u3v_project/u3v_live_aud_nd_vid_explorer_des/source/ip/pll/pll_ip/pll_ip.v(9[16:20])
    wire CLKOP /* synthesis is_clock=1 */ ;   // c:/users/ethanhead/desktop/gen3-cam-fw/crosslink_u3v_project/u3v_live_aud_nd_vid_explorer_des/source/ip/pll/pll_ip/pll_ip.v(10[17:22])
    
    wire scuba_vlo, VCC_net;
    
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    EHXPLLM PLLInst_0 (.CLKI(CLKI), .CLKFB(CLKOP), .PHASESEL0(scuba_vlo), 
            .PHASESEL1(scuba_vlo), .PHASEDIR(scuba_vlo), .PHASESTEP(scuba_vlo), 
            .PHASELOADREG(scuba_vlo), .USRSTDBY(scuba_vlo), .PLLWAKESYNC(scuba_vlo), 
            .RST(scuba_vlo), .ENCLKOP(scuba_vlo), .ENCLKOS(scuba_vlo), 
            .ENCLKOS2(scuba_vlo), .ENCLKOS3(scuba_vlo), .CLKOP(CLKOP), 
            .CLKOS2(CLKOS2), .LOCK(LOCK)) /* synthesis FREQUENCY_PIN_CLKOS2="249.000000", FREQUENCY_PIN_CLKOP="83.000000", FREQUENCY_PIN_CLKI="83.000000", ICP_CURRENT="9", LPF_RESISTOR="32", syn_instantiated=1 */ ;
    defparam PLLInst_0.FIN = "100.0000";
    defparam PLLInst_0.CLKI_DIV = 1;
    defparam PLLInst_0.CLKFB_DIV = 1;
    defparam PLLInst_0.CLKOP_DIV = 12;
    defparam PLLInst_0.CLKOS_DIV = 1;
    defparam PLLInst_0.CLKOS2_DIV = 4;
    defparam PLLInst_0.CLKOS3_DIV = 1;
    defparam PLLInst_0.CLKOP_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS_ENABLE = "DISABLED";
    defparam PLLInst_0.CLKOS2_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS3_ENABLE = "DISABLED";
    defparam PLLInst_0.CLKOP_CPHASE = 11;
    defparam PLLInst_0.CLKOS_CPHASE = 0;
    defparam PLLInst_0.CLKOS2_CPHASE = 3;
    defparam PLLInst_0.CLKOS3_CPHASE = 0;
    defparam PLLInst_0.CLKOP_FPHASE = 0;
    defparam PLLInst_0.CLKOS_FPHASE = 0;
    defparam PLLInst_0.CLKOS2_FPHASE = 0;
    defparam PLLInst_0.CLKOS3_FPHASE = 0;
    defparam PLLInst_0.FEEDBK_PATH = "CLKOP";
    defparam PLLInst_0.CLKOP_TRIM_POL = "FALLING";
    defparam PLLInst_0.CLKOP_TRIM_DELAY = 0;
    defparam PLLInst_0.CLKOS_TRIM_POL = "FALLING";
    defparam PLLInst_0.CLKOS_TRIM_DELAY = 0;
    defparam PLLInst_0.OUTDIVIDER_MUXA = "DIVA";
    defparam PLLInst_0.OUTDIVIDER_MUXB = "DIVB";
    defparam PLLInst_0.OUTDIVIDER_MUXC = "DIVC";
    defparam PLLInst_0.OUTDIVIDER_MUXD = "DIVD";
    defparam PLLInst_0.PLL_LOCK_MODE = 0;
    defparam PLLInst_0.PLL_LOCK_DELAY = 200;
    defparam PLLInst_0.REFIN_RESET = "DISABLED";
    defparam PLLInst_0.SYNC_ENABLE = "DISABLED";
    defparam PLLInst_0.INT_LOCK_STICKY = "ENABLED";
    defparam PLLInst_0.DPHASE_SOURCE = "DISABLED";
    defparam PLLInst_0.STDBY_ENABLE = "DISABLED";
    defparam PLLInst_0.PLLRST_ENA = "DISABLED";
    defparam PLLInst_0.INTFB_WAKE = "DISABLED";
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    GSR GSR_INST (.GSR(VCC_net));
    VHI i83 (.Z(VCC_net));
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

