// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.13.0.56.2
// Netlist written on Tue Oct 29 15:20:46 2024
//
// Verilog Description of module ram_dp_s
//

module ram_dp_s (WrAddress, RdAddress, Data, WE, RdClock, RdClockEn, 
            Reset, WrClock, WrClockEn, Q) /* synthesis NGD_DRC_MASK=1, syn_module_defined=1 */ ;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(8[8:16])
    input [9:0]WrAddress;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(10[22:31])
    input [9:0]RdAddress;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(11[22:31])
    input [23:0]Data;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(12[23:27])
    input WE;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(13[16:18])
    input RdClock;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(14[16:23])
    input RdClockEn;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(15[16:25])
    input Reset;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(16[16:21])
    input WrClock;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(17[16:23])
    input WrClockEn;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(18[16:25])
    output [23:0]Q;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(19[24:25])
    
    wire RdClock /* synthesis is_clock=1 */ ;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(14[16:23])
    wire WrClock /* synthesis is_clock=1 */ ;   // c:/users/ethanhead/desktop/gen3-cam-fw/histofpgafw/ram_dp/ram_dp_s/ram_dp_s.v(17[16:23])
    
    wire scuba_vlo, VCC_net;
    
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    DP8KE ram_dp_s_0_2_0 (.DIA0(Data[18]), .DIA1(Data[19]), .DIA2(Data[20]), 
          .DIA3(Data[21]), .DIA4(Data[22]), .DIA5(Data[23]), .DIA6(scuba_vlo), 
          .DIA7(scuba_vlo), .DIA8(scuba_vlo), .ADA0(VCC_net), .ADA1(scuba_vlo), 
          .ADA2(scuba_vlo), .ADA3(WrAddress[0]), .ADA4(WrAddress[1]), 
          .ADA5(WrAddress[2]), .ADA6(WrAddress[3]), .ADA7(WrAddress[4]), 
          .ADA8(WrAddress[5]), .ADA9(WrAddress[6]), .ADA10(WrAddress[7]), 
          .ADA11(WrAddress[8]), .ADA12(WrAddress[9]), .CEA(WrClockEn), 
          .OCEA(WrClockEn), .CLKA(WrClock), .WEA(WE), .CSA0(scuba_vlo), 
          .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
          .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
          .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
          .ADB0(scuba_vlo), .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(RdAddress[0]), 
          .ADB4(RdAddress[1]), .ADB5(RdAddress[2]), .ADB6(RdAddress[3]), 
          .ADB7(RdAddress[4]), .ADB8(RdAddress[5]), .ADB9(RdAddress[6]), 
          .ADB10(RdAddress[7]), .ADB11(RdAddress[8]), .ADB12(RdAddress[9]), 
          .CEB(RdClockEn), .OCEB(RdClockEn), .CLKB(RdClock), .WEB(scuba_vlo), 
          .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
          .DOB0(Q[18]), .DOB1(Q[19]), .DOB2(Q[20]), .DOB3(Q[21]), .DOB4(Q[22]), 
          .DOB5(Q[23])) /* synthesis MEM_LPC_FILE="ram_dp_s.lpc", MEM_INIT_FILE="INIT_ALL_0s", syn_instantiated=1 */ ;
    defparam ram_dp_s_0_2_0.DATA_WIDTH_A = 9;
    defparam ram_dp_s_0_2_0.DATA_WIDTH_B = 9;
    defparam ram_dp_s_0_2_0.REGMODE_A = "NOREG";
    defparam ram_dp_s_0_2_0.REGMODE_B = "NOREG";
    defparam ram_dp_s_0_2_0.CSDECODE_A = "0b000";
    defparam ram_dp_s_0_2_0.CSDECODE_B = "0b000";
    defparam ram_dp_s_0_2_0.WRITEMODE_A = "NORMAL";
    defparam ram_dp_s_0_2_0.WRITEMODE_B = "NORMAL";
    defparam ram_dp_s_0_2_0.GSR = "ENABLED";
    defparam ram_dp_s_0_2_0.RESETMODE = "ASYNC";
    defparam ram_dp_s_0_2_0.ASYNC_RESET_RELEASE = "SYNC";
    defparam ram_dp_s_0_2_0.INIT_DATA = "STATIC";
    defparam ram_dp_s_0_2_0.INITVAL_00 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_01 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_02 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_03 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_04 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_05 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_06 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_07 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_10 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_11 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_12 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_13 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_14 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_15 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_16 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_17 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_2_0.INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    DP8KE ram_dp_s_0_0_2 (.DIA0(Data[0]), .DIA1(Data[1]), .DIA2(Data[2]), 
          .DIA3(Data[3]), .DIA4(Data[4]), .DIA5(Data[5]), .DIA6(Data[6]), 
          .DIA7(Data[7]), .DIA8(Data[8]), .ADA0(VCC_net), .ADA1(scuba_vlo), 
          .ADA2(scuba_vlo), .ADA3(WrAddress[0]), .ADA4(WrAddress[1]), 
          .ADA5(WrAddress[2]), .ADA6(WrAddress[3]), .ADA7(WrAddress[4]), 
          .ADA8(WrAddress[5]), .ADA9(WrAddress[6]), .ADA10(WrAddress[7]), 
          .ADA11(WrAddress[8]), .ADA12(WrAddress[9]), .CEA(WrClockEn), 
          .OCEA(WrClockEn), .CLKA(WrClock), .WEA(WE), .CSA0(scuba_vlo), 
          .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
          .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
          .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
          .ADB0(scuba_vlo), .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(RdAddress[0]), 
          .ADB4(RdAddress[1]), .ADB5(RdAddress[2]), .ADB6(RdAddress[3]), 
          .ADB7(RdAddress[4]), .ADB8(RdAddress[5]), .ADB9(RdAddress[6]), 
          .ADB10(RdAddress[7]), .ADB11(RdAddress[8]), .ADB12(RdAddress[9]), 
          .CEB(RdClockEn), .OCEB(RdClockEn), .CLKB(RdClock), .WEB(scuba_vlo), 
          .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
          .DOB0(Q[0]), .DOB1(Q[1]), .DOB2(Q[2]), .DOB3(Q[3]), .DOB4(Q[4]), 
          .DOB5(Q[5]), .DOB6(Q[6]), .DOB7(Q[7]), .DOB8(Q[8])) /* synthesis MEM_LPC_FILE="ram_dp_s.lpc", MEM_INIT_FILE="INIT_ALL_0s", syn_instantiated=1 */ ;
    defparam ram_dp_s_0_0_2.DATA_WIDTH_A = 9;
    defparam ram_dp_s_0_0_2.DATA_WIDTH_B = 9;
    defparam ram_dp_s_0_0_2.REGMODE_A = "NOREG";
    defparam ram_dp_s_0_0_2.REGMODE_B = "NOREG";
    defparam ram_dp_s_0_0_2.CSDECODE_A = "0b000";
    defparam ram_dp_s_0_0_2.CSDECODE_B = "0b000";
    defparam ram_dp_s_0_0_2.WRITEMODE_A = "NORMAL";
    defparam ram_dp_s_0_0_2.WRITEMODE_B = "NORMAL";
    defparam ram_dp_s_0_0_2.GSR = "ENABLED";
    defparam ram_dp_s_0_0_2.RESETMODE = "ASYNC";
    defparam ram_dp_s_0_0_2.ASYNC_RESET_RELEASE = "SYNC";
    defparam ram_dp_s_0_0_2.INIT_DATA = "STATIC";
    defparam ram_dp_s_0_0_2.INITVAL_00 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_01 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_02 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_03 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_04 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_05 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_06 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_07 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_10 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_11 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_12 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_13 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_14 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_15 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_16 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_17 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_0_2.INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    DP8KE ram_dp_s_0_1_1 (.DIA0(Data[9]), .DIA1(Data[10]), .DIA2(Data[11]), 
          .DIA3(Data[12]), .DIA4(Data[13]), .DIA5(Data[14]), .DIA6(Data[15]), 
          .DIA7(Data[16]), .DIA8(Data[17]), .ADA0(VCC_net), .ADA1(scuba_vlo), 
          .ADA2(scuba_vlo), .ADA3(WrAddress[0]), .ADA4(WrAddress[1]), 
          .ADA5(WrAddress[2]), .ADA6(WrAddress[3]), .ADA7(WrAddress[4]), 
          .ADA8(WrAddress[5]), .ADA9(WrAddress[6]), .ADA10(WrAddress[7]), 
          .ADA11(WrAddress[8]), .ADA12(WrAddress[9]), .CEA(WrClockEn), 
          .OCEA(WrClockEn), .CLKA(WrClock), .WEA(WE), .CSA0(scuba_vlo), 
          .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
          .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
          .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
          .ADB0(scuba_vlo), .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(RdAddress[0]), 
          .ADB4(RdAddress[1]), .ADB5(RdAddress[2]), .ADB6(RdAddress[3]), 
          .ADB7(RdAddress[4]), .ADB8(RdAddress[5]), .ADB9(RdAddress[6]), 
          .ADB10(RdAddress[7]), .ADB11(RdAddress[8]), .ADB12(RdAddress[9]), 
          .CEB(RdClockEn), .OCEB(RdClockEn), .CLKB(RdClock), .WEB(scuba_vlo), 
          .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
          .DOB0(Q[9]), .DOB1(Q[10]), .DOB2(Q[11]), .DOB3(Q[12]), .DOB4(Q[13]), 
          .DOB5(Q[14]), .DOB6(Q[15]), .DOB7(Q[16]), .DOB8(Q[17])) /* synthesis MEM_LPC_FILE="ram_dp_s.lpc", MEM_INIT_FILE="INIT_ALL_0s", syn_instantiated=1 */ ;
    defparam ram_dp_s_0_1_1.DATA_WIDTH_A = 9;
    defparam ram_dp_s_0_1_1.DATA_WIDTH_B = 9;
    defparam ram_dp_s_0_1_1.REGMODE_A = "NOREG";
    defparam ram_dp_s_0_1_1.REGMODE_B = "NOREG";
    defparam ram_dp_s_0_1_1.CSDECODE_A = "0b000";
    defparam ram_dp_s_0_1_1.CSDECODE_B = "0b000";
    defparam ram_dp_s_0_1_1.WRITEMODE_A = "NORMAL";
    defparam ram_dp_s_0_1_1.WRITEMODE_B = "NORMAL";
    defparam ram_dp_s_0_1_1.GSR = "ENABLED";
    defparam ram_dp_s_0_1_1.RESETMODE = "ASYNC";
    defparam ram_dp_s_0_1_1.ASYNC_RESET_RELEASE = "SYNC";
    defparam ram_dp_s_0_1_1.INIT_DATA = "STATIC";
    defparam ram_dp_s_0_1_1.INITVAL_00 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_01 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_02 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_03 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_04 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_05 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_06 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_07 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_10 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_11 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_12 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_13 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_14 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_15 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_16 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_17 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam ram_dp_s_0_1_1.INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    GSR GSR_INST (.GSR(VCC_net));
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    VHI i82 (.Z(VCC_net));
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

