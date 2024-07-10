// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2021 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                      408-826-6000 (other locations)
// Hillsboro, OR 97124                      web  : http://www.latticesemi.com/
// U.S.A                                    email: techsupport@latticesemi.com
// =============================================================================
// Project     : PDM-PCM converter core
// File        : pdm_pcm_core.v
// Title       : 
// 
// Description : pdm to pcm converter
//                    
// =============================================================================

`timescale 100 ps/100 ps
module pdm_pcm_core (
  pdm_rst,
  pdm_clk,
  pdm_data,
  pcm_dvalid,
  pcm_data
)
;

input pdm_rst ;
input pdm_clk ;
input pdm_data ;
output pcm_dvalid ;
output [23:0] pcm_data ;
wire pdm_rst ;
wire pdm_clk ;
wire pdm_data ;
wire pcm_dvalid ;
wire [21:0] cic_data;
wire [24:1] \u_dcc.un1_sum ;
wire [24:0] \u_dcc.sum ;
wire [1:0] \u_dcc.dvalid_r ;
wire [22:0] \u_dcc.dout_4 ;
wire [23:0] \u_dcc.subo ;
wire [24:0] \u_dcc.subi ;
wire [5:5] \u_comps.un2_raddr_L ;
wire [4:1] \u_comps.un1_caddr ;
wire [6:0] \u_comps.waddr ;
wire [11:0] \u_comps.din_w ;
wire [5:0] \u_comps.raddr_L ;
wire [15:0] \u_comps.data_L ;
wire [5:0] \u_comps.raddr_R ;
wire [15:0] \u_comps.data_R ;
wire [4:0] \u_comps.caddr_r ;
wire [15:0] \u_comps.cdata ;
wire [3:0] \u_comps.run_even_r ;
wire [3:0] \u_comps.run_en_r ;
wire [0:0] \u_comps.dstart_r_2 ;
wire [5:4] \u_comps.dstart_r ;
wire [0:0] \u_comps.dout_en_2 ;
wire [4:4] \u_comps.dout_en ;
wire [27:1] \u_comps.mac_T ;
wire [4:0] \u_comps.caddr_3 ;
wire [27:2] \u_comps.mac_sum ;
wire [31:0] \u_comps.mac_B ;
wire [27:0] \u_comps.mac_T_4 ;
wire [31:0] \u_comps.mac_B_4 ;
wire [15:0] \u_comps.u_mult.DATAA_R ;
wire [15:0] \u_comps.u_mult.DATAB_R ;
wire [7:0] \u_comps.u_mult.PRODUCT_R_2 ;
wire [4:0] \u_cic.dcnt ;
wire [21:0] \u_cic.INTA[0].din_r[0] ;
wire [14:0] \u_comps.data_Lff ;
wire [15:0] \u_comps.data_Lf ;
wire [14:0] \u_comps.un3_data_Mf ;
wire [15:0] \u_comps.data_Rf ;
wire [15:0] \u_comps.un3_data_M ;
wire [15:15] \u_comps.data_M ;
wire [22:8] \u_comps.u_mult.PRODUCT_R_2.madd_3 ;
wire [20:6] \u_comps.u_mult.PRODUCT_R_2.madd_2 ;
wire [18:5] \u_comps.u_mult.PRODUCT_R_2.madd_1 ;
wire [26:12] \u_comps.u_mult.PRODUCT_R_2.madd_5 ;
wire [24:10] \u_comps.u_mult.PRODUCT_R_2.madd_4 ;
wire [23:7] \u_comps.u_mult.PRODUCT_R_2.madd_9 ;
wire [17:2] \u_comps.u_mult.PRODUCT_R_2.madd_0 ;
wire [28:14] \u_comps.u_mult.PRODUCT_R_2.madd_6 ;
wire [30:16] \u_comps.u_mult.PRODUCT_R_2.madd_7 ;
wire [27:10] \u_comps.u_mult.PRODUCT_R_2.madd_10 ;
wire [30:15] \u_comps.u_mult.PRODUCT_R_2.madd_11 ;
wire [24:8] \u_comps.u_mult.PRODUCT_R_2.madd_12 ;
wire [19:4] \u_comps.u_mult.PRODUCT_R_2.madd_8 ;
wire [30:12] \u_comps.u_mult.PRODUCT_R_2.madd_13 ;
wire [30:15] \u_comps.u_mult.PRODUCT_R_2.madd_11f ;
wire [24:9] \u_comps.u_mult.PRODUCT_R_2.madd_12f ;
wire [30:9] \u_comps.u_mult.PRODUCT_R_2.madd_13f ;
wire [30:0] \u_comps.mult_result ;
wire [30:16] \u_comps.u_mult.PRODUCT_R_2.madd_14 ;
wire [23:0] \u_dcc.prevo ;
wire [16:1] \u_dcc.prevo_256_3 ;
wire [22:0] \u_comps.dout_4 ;
wire [23:0] \u_dcc.previ ;
wire [23:0] dec_data;
wire [4:0] \u_comps.caddr ;
wire [21:0] \u_cic.un5_din_r ;
wire [21:1] \u_cic.INTA[1].din_r[1] ;
wire [21:0] \u_cic.un8_din_r ;
wire [21:1] \u_cic.INTA[2].din_r[2] ;
wire [21:0] \u_cic.un11_din_r ;
wire [21:1] \u_cic.INTA[3].din_r[3] ;
wire [21:0] \u_cic.PP.PL[0].dout_r[0] ;
wire [3:0] \u_cic.samp_en ;
wire [21:0] \u_cic.PP.PL[1].dout_r[1] ;
wire [21:1] \u_cic.PP.PL[0].dout_p[0] ;
wire [21:0] \u_cic.PP.PL[2].dout_r[2] ;
wire [21:1] \u_cic.PP.PL[1].dout_p[1] ;
wire [21:0] \u_cic.PP.PL[3].dout_r[3] ;
wire [21:1] \u_cic.PP.PL[2].dout_p[2] ;
wire [21:1] \u_cic.un13_dout_p ;
wire [21:1] \u_cic.un9_dout_p ;
wire [21:1] \u_cic.un5_dout_p ;
wire [21:1] \u_cic.un1_dout_p ;
wire [4:0] \u_comps.raddr_R_cry ;
wire [5:0] \u_comps.raddr_R_s ;
wire [5:0] \u_comps.raddr_R_lm ;
wire [4:0] \u_comps.raddr_L_cry ;
wire [5:0] \u_comps.raddr_L_s ;
wire [5:0] \u_comps.raddr_L_lm ;
wire [4:0] \u_comps.waddr_cry ;
wire [6:0] \u_comps.waddr_s ;
wire [20:0] \u_cic.INTA[0].din_r[0]_cry ;
wire [21:0] \u_cic.INTA[0].din_r[0]_s ;
wire [2:0] \u_cic.dcnt_cry ;
wire [4:0] \u_cic.dcnt_s ;
wire cic_dvalid ;
wire dec_dvalid ;
wire \u_comps.un13_dout_en  ;
wire \u_comps.un1_run_even_r_2  ;
wire \u_comps.un1_dstart_r  ;
wire \u_comps.un1_run_en_r_1  ;
wire \u_comps.un1_dstart_r_1  ;
wire \u_comps.din_we  ;
wire \u_comps.run_even  ;
wire \u_comps.din_even  ;
wire \u_comps.dvalid_r  ;
wire \u_comps.run_en  ;
wire \u_comps.data_M7  ;
wire \u_comps.run_even_3  ;
wire \u_comps.mac_sum_scalar  ;
wire \u_comps.raddr_Le  ;
wire \u_comps.L_data.mem_N_1  ;
wire \u_comps.L_data.mem_N_2  ;
wire \u_comps.R_data.mem_N_1  ;
wire \u_comps.R_data.mem_N_2  ;
wire N_1103 ;
wire \u_comps.data_M7f_0f  ;
wire \u_comps.data_M7f  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_scalar  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_scalar  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_scalar  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_11_scalar  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_scalar  ;
wire \u_comps.mac_B_4_scalar  ;
wire \u_comps.mac_B_4_0  ;
wire \u_comps.mac_B_4_2  ;
wire \u_comps.mac_B_4_1  ;
wire \u_cic.un5_din_r_scalar  ;
wire \u_cic.un8_din_r_scalar  ;
wire \u_cic.un11_din_r_scalar  ;
wire \u_cic.un5_dout_p_scalar  ;
wire \u_cic.un9_dout_p_scalar  ;
wire \u_cic.un13_dout_p_scalar  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_cry_0  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_cry_2  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_cry_4  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_cry_6  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_cry_8  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_cry_10  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_cry_12  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_cry_14  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_0  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_2  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_4  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_6  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_8  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_10  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_12  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_14  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_16  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_18  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_20  ;
wire N_1108 ;
wire N_1110 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_1  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_3  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_5  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_7  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_9  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_11  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_13  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_2  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_4  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_6  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_8  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_10  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_12  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_14  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_16  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_2  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_4  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_6  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_8  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_10  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_12  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_14  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_16  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_0  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_2  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_4  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_6  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_8  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_10  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_12  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_14  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_16  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_18  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_0  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_2  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_4  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_6  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_8  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_10  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_12  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_14  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_0  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_2  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_4  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_6  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_8  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_10  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_12  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_14  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_4  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_6  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_8  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_10  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_12  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_14  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_16  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_18  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_20  ;
wire \u_comps.un3_data_M_cry_0  ;
wire \u_comps.un3_data_M_cry_2  ;
wire \u_comps.un3_data_M_cry_4  ;
wire \u_comps.un3_data_M_cry_6  ;
wire \u_comps.un3_data_M_cry_8  ;
wire \u_comps.un3_data_M_cry_10  ;
wire \u_comps.un3_data_M_cry_12  ;
wire \u_comps.un3_data_M_cry_14  ;
wire N_1219 ;
wire N_1221 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_1  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_3  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_5  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_7  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_9  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_11  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_13  ;
wire N_1265 ;
wire N_1267 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_1  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_3  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_5  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_7  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_9  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_11  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_13  ;
wire N_1311 ;
wire N_1313 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_1  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_3  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_5  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_7  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_9  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_11  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_13  ;
wire N_1357 ;
wire N_1359 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_1  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_3  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_5  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_7  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_9  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_11  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_13  ;
wire N_1403 ;
wire N_1405 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_1  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_3  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_5  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_7  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_9  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_11  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_13  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_2  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_4  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_6  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_8  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_10  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_12  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_14  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_16  ;
wire N_1451 ;
wire N_1453 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_1  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_3  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_5  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_7  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_9  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_11  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_13  ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_15  ;
wire \u_dcc.prevo_256_3_cry_0  ;
wire \u_dcc.prevo_256_3_cry_2  ;
wire \u_dcc.prevo_256_3_cry_4  ;
wire \u_dcc.prevo_256_3_cry_6  ;
wire \u_dcc.prevo_256_3_cry_8  ;
wire \u_dcc.prevo_256_3_cry_10  ;
wire \u_dcc.prevo_256_3_cry_12  ;
wire \u_dcc.prevo_256_3_cry_14  ;
wire N_1494 ;
wire N_1495 ;
wire N_1496 ;
wire N_1497 ;
wire N_1498 ;
wire N_1499 ;
wire N_1500 ;
wire N_1501 ;
wire N_1502 ;
wire N_1503 ;
wire N_1504 ;
wire N_1505 ;
wire N_1506 ;
wire N_1507 ;
wire N_1508 ;
wire N_1509 ;
wire N_1510 ;
wire N_1511 ;
wire N_1512 ;
wire N_1513 ;
wire N_1514 ;
wire N_1515 ;
wire N_1516 ;
wire \u_dcc.un1_subo_cry_0  ;
wire \u_dcc.un1_subo_cry_2  ;
wire \u_dcc.un1_subo_cry_4  ;
wire \u_dcc.un1_subo_cry_6  ;
wire \u_dcc.un1_subo_cry_8  ;
wire \u_dcc.un1_subo_cry_10  ;
wire \u_dcc.un1_subo_cry_12  ;
wire \u_dcc.un1_subo_cry_14  ;
wire \u_dcc.un1_subo_cry_16  ;
wire \u_dcc.un1_subo_cry_18  ;
wire \u_dcc.un1_subo_cry_20  ;
wire \u_dcc.un1_subo_cry_22  ;
wire N_1518 ;
wire N_1519 ;
wire N_1520 ;
wire N_1521 ;
wire N_1522 ;
wire N_1523 ;
wire N_1524 ;
wire N_1525 ;
wire N_1526 ;
wire N_1527 ;
wire N_1528 ;
wire N_1529 ;
wire N_1530 ;
wire N_1531 ;
wire N_1532 ;
wire N_1533 ;
wire N_1534 ;
wire N_1535 ;
wire N_1536 ;
wire N_1537 ;
wire N_1538 ;
wire N_1539 ;
wire N_1540 ;
wire N_1541 ;
wire \u_dcc.un2_subi_cry_0  ;
wire \u_dcc.un2_subi_cry_2  ;
wire \u_dcc.un2_subi_cry_4  ;
wire \u_dcc.un2_subi_cry_6  ;
wire \u_dcc.un2_subi_cry_8  ;
wire \u_dcc.un2_subi_cry_10  ;
wire \u_dcc.un2_subi_cry_12  ;
wire \u_dcc.un2_subi_cry_14  ;
wire \u_dcc.un2_subi_cry_16  ;
wire \u_dcc.un2_subi_cry_18  ;
wire \u_dcc.un2_subi_cry_20  ;
wire \u_dcc.un2_subi_cry_22  ;
wire \u_comps.mac_sum_cry_0  ;
wire \u_comps.mac_sum_cry_2  ;
wire \u_comps.mac_sum_cry_4  ;
wire \u_comps.mac_sum_cry_6  ;
wire \u_comps.mac_sum_cry_8  ;
wire \u_comps.mac_sum_cry_10  ;
wire \u_comps.mac_sum_cry_12  ;
wire \u_comps.mac_sum_cry_14  ;
wire \u_comps.mac_sum_cry_16  ;
wire \u_comps.mac_sum_cry_18  ;
wire \u_comps.mac_sum_cry_20  ;
wire \u_comps.mac_sum_cry_22  ;
wire \u_comps.mac_sum_cry_24  ;
wire \u_comps.mac_sum_cry_26  ;
wire \u_comps.un1_caddr_cry_0  ;
wire \u_comps.un1_caddr_cry_2  ;
wire \u_cic.un13_dout_p_cry_0  ;
wire \u_cic.un13_dout_p_cry_2  ;
wire \u_cic.un13_dout_p_cry_4  ;
wire \u_cic.un13_dout_p_cry_6  ;
wire \u_cic.un13_dout_p_cry_8  ;
wire \u_cic.un13_dout_p_cry_10  ;
wire \u_cic.un13_dout_p_cry_12  ;
wire \u_cic.un13_dout_p_cry_14  ;
wire \u_cic.un13_dout_p_cry_16  ;
wire \u_cic.un13_dout_p_cry_18  ;
wire \u_cic.un13_dout_p_cry_20  ;
wire \u_cic.un9_dout_p_cry_0  ;
wire \u_cic.un9_dout_p_cry_2  ;
wire \u_cic.un9_dout_p_cry_4  ;
wire \u_cic.un9_dout_p_cry_6  ;
wire \u_cic.un9_dout_p_cry_8  ;
wire \u_cic.un9_dout_p_cry_10  ;
wire \u_cic.un9_dout_p_cry_12  ;
wire \u_cic.un9_dout_p_cry_14  ;
wire \u_cic.un9_dout_p_cry_16  ;
wire \u_cic.un9_dout_p_cry_18  ;
wire \u_cic.un9_dout_p_cry_20  ;
wire \u_cic.un5_dout_p_cry_0  ;
wire \u_cic.un5_dout_p_cry_2  ;
wire \u_cic.un5_dout_p_cry_4  ;
wire \u_cic.un5_dout_p_cry_6  ;
wire \u_cic.un5_dout_p_cry_8  ;
wire \u_cic.un5_dout_p_cry_10  ;
wire \u_cic.un5_dout_p_cry_12  ;
wire \u_cic.un5_dout_p_cry_14  ;
wire \u_cic.un5_dout_p_cry_16  ;
wire \u_cic.un5_dout_p_cry_18  ;
wire \u_cic.un5_dout_p_cry_20  ;
wire \u_cic.un1_dout_p_cry_0  ;
wire \u_cic.un1_dout_p_cry_2  ;
wire \u_cic.un1_dout_p_cry_4  ;
wire \u_cic.un1_dout_p_cry_6  ;
wire \u_cic.un1_dout_p_cry_8  ;
wire \u_cic.un1_dout_p_cry_10  ;
wire \u_cic.un1_dout_p_cry_12  ;
wire \u_cic.un1_dout_p_cry_14  ;
wire \u_cic.un1_dout_p_cry_16  ;
wire \u_cic.un1_dout_p_cry_18  ;
wire \u_cic.un1_dout_p_cry_20  ;
wire \u_cic.un11_din_r_cry_0  ;
wire \u_cic.un11_din_r_cry_2  ;
wire \u_cic.un11_din_r_cry_4  ;
wire \u_cic.un11_din_r_cry_6  ;
wire \u_cic.un11_din_r_cry_8  ;
wire \u_cic.un11_din_r_cry_10  ;
wire \u_cic.un11_din_r_cry_12  ;
wire \u_cic.un11_din_r_cry_14  ;
wire \u_cic.un11_din_r_cry_16  ;
wire \u_cic.un11_din_r_cry_18  ;
wire \u_cic.un11_din_r_cry_20  ;
wire \u_cic.un8_din_r_cry_0  ;
wire \u_cic.un8_din_r_cry_2  ;
wire \u_cic.un8_din_r_cry_4  ;
wire \u_cic.un8_din_r_cry_6  ;
wire \u_cic.un8_din_r_cry_8  ;
wire \u_cic.un8_din_r_cry_10  ;
wire \u_cic.un8_din_r_cry_12  ;
wire \u_cic.un8_din_r_cry_14  ;
wire \u_cic.un8_din_r_cry_16  ;
wire \u_cic.un8_din_r_cry_18  ;
wire \u_cic.un8_din_r_cry_20  ;
wire \u_cic.un5_din_r_cry_0  ;
wire \u_cic.un5_din_r_cry_2  ;
wire \u_cic.un5_din_r_cry_4  ;
wire \u_cic.un5_din_r_cry_6  ;
wire \u_cic.un5_din_r_cry_8  ;
wire \u_cic.un5_din_r_cry_10  ;
wire \u_cic.un5_din_r_cry_12  ;
wire \u_cic.un5_din_r_cry_14  ;
wire \u_cic.un5_din_r_cry_16  ;
wire \u_cic.un5_din_r_cry_18  ;
wire \u_cic.un5_din_r_cry_20  ;
wire \u_dcc.un1_sum_axb_0  ;
wire \u_dcc.un1_sum_cry_0  ;
wire \u_dcc.un1_sum_cry_2  ;
wire \u_dcc.un1_sum_cry_4  ;
wire \u_dcc.un1_sum_cry_6  ;
wire \u_dcc.un1_sum_cry_8  ;
wire \u_dcc.un1_sum_cry_10  ;
wire \u_dcc.un1_sum_cry_12  ;
wire \u_dcc.un1_sum_cry_14  ;
wire \u_dcc.un1_sum_cry_16  ;
wire \u_dcc.un1_sum_cry_18  ;
wire \u_dcc.un1_sum_cry_20  ;
wire \u_dcc.un1_sum_cry_22  ;
wire \u_comps.un2_raddr_L_c2  ;
wire \u_comps.un2_raddr_L_c3  ;
wire \u_comps.un2_raddr_L_c4  ;
wire \u_cic.un13_dout_p_axb_0_i  ;
wire \u_cic.un9_dout_p_axb_0_i  ;
wire \u_cic.un5_dout_p_axb_0_i  ;
wire \u_cic.un1_dout_p_axb_0_i  ;
wire \u_dcc.un1_subo_axb_0_i  ;
wire \u_dcc.un2_subi_axb_0_i  ;
wire N_1686 ;
wire N_1687 ;
wire \u_comps.mac_B_4_cry_0  ;
wire \u_comps.mac_B_4_cry_2  ;
wire \u_comps.mac_B_4_cry_4  ;
wire \u_comps.mac_B_4_cry_6  ;
wire \u_comps.mac_B_4_cry_8  ;
wire \u_comps.mac_B_4_cry_10  ;
wire \u_comps.mac_B_4_cry_12  ;
wire \u_comps.mac_B_4_cry_14  ;
wire \u_comps.mac_B_4_cry_16  ;
wire \u_comps.mac_B_4_cry_18  ;
wire \u_comps.mac_B_4_cry_20  ;
wire \u_comps.mac_B_4_cry_22  ;
wire \u_comps.mac_B_4_cry_24  ;
wire \u_comps.mac_B_4_cry_26  ;
wire \u_comps.mac_B_4_cry_28  ;
wire \u_comps.mac_B_4_cry_30  ;
wire \u_comps.mac_T_4_cry_0  ;
wire \u_comps.mac_T_4_cry_2  ;
wire \u_comps.mac_T_4_cry_4  ;
wire \u_comps.mac_T_4_cry_6  ;
wire \u_comps.mac_T_4_cry_8  ;
wire \u_comps.mac_T_4_cry_10  ;
wire \u_comps.mac_T_4_cry_12  ;
wire \u_comps.mac_T_4_cry_14  ;
wire \u_comps.mac_T_4_cry_16  ;
wire \u_comps.mac_T_4_cry_18  ;
wire \u_comps.mac_T_4_cry_20  ;
wire \u_comps.mac_T_4_cry_22  ;
wire \u_comps.mac_T_4_cry_24  ;
wire \u_comps.mac_T_4_cry_26  ;
wire \u_comps.data_M7_3  ;
wire \u_cic.un10_sample_point_1  ;
wire \u_comps.un13_dout_en_1  ;
wire N_2155 ;
wire N_2217 ;
wire N_2262 ;
wire N_2283 ;
wire N_2304 ;
wire N_2325 ;
wire N_2417 ;
wire N_2444 ;
wire N_2513 ;
wire N_2542 ;
wire N_2559 ;
wire N_2589 ;
wire N_2619 ;
wire N_2649 ;
wire N_2679 ;
wire N_2709 ;
wire N_2724 ;
wire N_2740 ;
wire N_2772 ;
wire N_2800 ;
wire N_2818 ;
wire N_2834 ;
wire N_2851 ;
wire N_2881 ;
wire N_2898 ;
wire N_2913 ;
wire N_2915 ;
wire N_2942 ;
wire N_2943 ;
wire N_2946 ;
wire N_2977 ;
wire N_2978 ;
wire N_2982 ;
wire N_2987 ;
wire N_2990 ;
wire N_3012 ;
wire N_3013 ;
wire N_3017 ;
wire N_3024 ;
wire N_3027 ;
wire N_3033 ;
wire N_3034 ;
wire N_3037 ;
wire N_3042 ;
wire N_3043 ;
wire N_3046 ;
wire N_3070 ;
wire N_3072 ;
wire N_3093 ;
wire N_3094 ;
wire N_3097 ;
wire N_3118 ;
wire N_3119 ;
wire N_3122 ;
wire N_3143 ;
wire N_3144 ;
wire N_3148 ;
wire N_3149 ;
wire N_3170 ;
wire N_3171 ;
wire N_3175 ;
wire N_3176 ;
wire N_3197 ;
wire N_3198 ;
wire N_3202 ;
wire N_3203 ;
wire N_3224 ;
wire N_3225 ;
wire N_3229 ;
wire N_3230 ;
wire N_3251 ;
wire N_3252 ;
wire N_3255 ;
wire N_3259 ;
wire N_3261 ;
wire N_3262 ;
wire N_3288 ;
wire N_3289 ;
wire N_3293 ;
wire N_3294 ;
wire N_3318 ;
wire N_3321 ;
wire N_3322 ;
wire N_3345 ;
wire N_3346 ;
wire N_3349 ;
wire N_3365 ;
wire N_3368 ;
wire N_3383 ;
wire N_3384 ;
wire N_3387 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_18_cry  ;
wire N_3405 ;
wire N_3406 ;
wire N_3408 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_15_cry  ;
wire N_3424 ;
wire N_3425 ;
wire N_3427 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_15_cry  ;
wire N_3443 ;
wire N_3444 ;
wire N_3446 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_15_cry  ;
wire N_3462 ;
wire N_3463 ;
wire N_3465 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_15_cry  ;
wire N_3481 ;
wire N_3482 ;
wire N_3484 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_15_cry  ;
wire N_3500 ;
wire N_3501 ;
wire N_3503 ;
wire N_3518 ;
wire N_3519 ;
wire N_3522 ;
wire N_3540 ;
wire N_3542 ;
wire N_3558 ;
wire N_3561 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_16_cry  ;
wire N_3579 ;
wire N_3580 ;
wire N_3582 ;
wire N_3602 ;
wire N_3605 ;
wire N_3621 ;
wire N_3623 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_18_cry  ;
wire N_3641 ;
wire N_3642 ;
wire N_3644 ;
wire \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_15_cry  ;
wire N_3660 ;
wire N_3661 ;
wire N_3663 ;
wire N_3685 ;
wire N_3687 ;
wire N_3702 ;
wire N_3703 ;
wire \u_comps.data_M7f_0f_fast  ;
wire \u_comps.data_M7f_0f_rep1  ;
wire GND ;
wire VCC ;
wire N_4486 ;
wire N_4892 ;
wire N_4893 ;
wire N_4894 ;
wire N_4895 ;
wire N_4900 ;
wire N_4901 ;
wire N_4902 ;
wire N_4903 ;
wire N_4905 ;
wire N_4906 ;
wire N_4907 ;
wire N_4908 ;
wire N_4909 ;
wire N_4910 ;
wire N_4911 ;
wire N_4912 ;
wire N_4913 ;
wire N_4914 ;
wire N_4915 ;
wire N_4916 ;
wire N_4917 ;
wire N_4918 ;
wire N_4919 ;
wire N_4920 ;
wire N_4921 ;
wire N_4922 ;
wire N_4923 ;
wire N_4924 ;
wire N_4925 ;
wire N_4926 ;
wire N_4927 ;
wire N_4928 ;
wire N_4929 ;
wire N_4930 ;
wire N_4931 ;
wire N_4932 ;
wire N_4933 ;
wire N_4934 ;
wire N_4935 ;
wire N_4936 ;
wire N_4937 ;
wire N_4938 ;
wire N_4939 ;
wire N_4940 ;
wire N_4941 ;
wire N_4942 ;
wire N_4943 ;
wire N_4944 ;
wire N_4945 ;
wire N_4946 ;
wire N_4947 ;
wire N_4948 ;
wire N_4949 ;
wire N_4950 ;
wire N_4951 ;
wire N_4952 ;
wire N_4953 ;
wire N_4954 ;
wire N_4955 ;
wire N_4956 ;
wire N_4957 ;
wire N_4958 ;
wire N_4959 ;
wire N_4960 ;
wire N_4961 ;
wire N_4962 ;
wire N_4963 ;
wire N_4964 ;
wire N_4965 ;
wire N_4966 ;
wire N_4967 ;
wire N_4968 ;
wire N_4969 ;
wire N_4970 ;
wire N_4971 ;
wire N_4972 ;
wire N_4973 ;
wire N_4974 ;
wire N_4975 ;
wire N_4976 ;
wire N_4977 ;
wire N_4978 ;
wire N_4979 ;
wire N_4980 ;
wire N_4981 ;
wire N_4982 ;
wire N_4983 ;
wire N_4984 ;
wire N_4985 ;
wire N_4986 ;
wire N_4987 ;
wire N_4988 ;
wire N_4989 ;
wire N_4990 ;
wire N_4991 ;
wire N_4992 ;
wire N_4993 ;
wire N_4995 ;
wire N_4997 ;
wire N_4999 ;
wire N_5001 ;
wire N_5003 ;
wire N_5005 ;
wire N_5007 ;
wire N_5009 ;
wire N_5011 ;
wire N_5013 ;
wire N_5015 ;
wire N_5017 ;
wire N_5019 ;
wire N_5021 ;
wire N_5023 ;
wire N_5025 ;
wire N_5027 ;
wire N_5029 ;
wire N_5031 ;
wire N_5033 ;
wire N_5035 ;
wire N_5037 ;
wire N_5039 ;
wire N_5041 ;
wire N_5043 ;
wire N_5045 ;
wire N_5047 ;
wire N_5049 ;
wire N_5051 ;
wire N_5053 ;
wire N_5055 ;
wire N_5057 ;
wire N_5059 ;
wire N_5061 ;
wire N_5063 ;
wire N_5065 ;
wire N_5067 ;
wire N_5069 ;
wire N_5071 ;
wire N_5073 ;
wire N_5075 ;
wire N_5077 ;
wire N_5079 ;
wire N_5081 ;
wire N_5083 ;
wire N_5085 ;
wire N_5087 ;
wire N_5089 ;
wire N_5091 ;
wire N_5093 ;
wire N_5095 ;
wire N_5097 ;
wire N_5099 ;
wire N_5101 ;
wire N_5103 ;
wire N_5105 ;
wire N_5107 ;
wire N_5109 ;
wire N_5111 ;
wire N_5113 ;
wire N_5115 ;
wire N_5117 ;
wire N_5119 ;
wire N_5121 ;
wire N_5123 ;
wire N_5125 ;
wire N_5127 ;
wire N_5129 ;
wire N_5131 ;
wire N_5133 ;
wire N_5135 ;
wire N_5137 ;
wire N_5139 ;
wire N_5141 ;
wire N_5143 ;
wire N_5145 ;
wire N_5147 ;
wire N_5149 ;
wire N_5151 ;
wire N_5153 ;
wire N_5155 ;
wire N_5157 ;
wire N_5159 ;
wire N_5161 ;
wire N_5163 ;
wire N_5165 ;
wire N_5167 ;
wire N_5169 ;
wire N_5171 ;
wire N_5173 ;
wire N_5175 ;
wire N_5177 ;
wire N_5179 ;
wire N_5181 ;
wire N_5183 ;
wire N_5185 ;
wire N_5187 ;
wire N_5189 ;
wire N_5191 ;
wire N_5193 ;
wire N_5195 ;
wire N_5197 ;
wire N_5199 ;
wire N_5201 ;
wire N_5203 ;
wire N_5205 ;
wire N_5207 ;
wire N_5209 ;
wire N_5211 ;
wire N_5213 ;
wire N_5215 ;
wire N_5217 ;
wire N_5219 ;
wire N_5221 ;
wire N_5223 ;
wire N_5225 ;
wire N_5227 ;
wire N_5229 ;
wire N_5231 ;
wire N_5233 ;
wire N_5235 ;
wire N_5237 ;
wire N_5239 ;
wire N_5241 ;
wire N_5243 ;
wire N_5245 ;
wire N_5247 ;
wire N_5249 ;
wire N_5251 ;
wire N_5253 ;
wire N_5255 ;
wire N_5257 ;
wire N_5259 ;
wire N_5261 ;
wire N_5263 ;
wire N_5265 ;
wire N_5267 ;
wire N_5269 ;
wire N_5271 ;
wire N_5273 ;
wire N_5275 ;
wire N_5277 ;
wire N_5279 ;
wire N_5281 ;
wire N_5283 ;
wire N_5285 ;
wire N_5287 ;
wire N_5289 ;
wire N_5291 ;
wire N_5293 ;
wire N_5295 ;
wire N_5297 ;
wire N_5299 ;
wire N_5301 ;
wire N_5303 ;
wire N_5305 ;
wire N_5307 ;
wire N_5309 ;
wire N_5311 ;
wire N_5313 ;
wire N_5315 ;
wire N_5317 ;
wire N_5319 ;
wire N_5321 ;
wire N_5323 ;
wire N_5325 ;
wire N_5327 ;
wire N_5329 ;
wire N_5331 ;
wire N_5333 ;
wire N_5335 ;
wire N_5337 ;
wire N_5339 ;
wire N_5341 ;
wire N_5343 ;
wire N_5345 ;
wire N_5346 ;
wire N_5347 ;
wire N_5348 ;
wire N_5349 ;
wire N_5350 ;
wire N_5351 ;
wire N_5352 ;
wire N_5353 ;
wire N_5354 ;
wire N_5355 ;
wire N_5356 ;
wire N_5357 ;
wire N_5358 ;
wire N_5359 ;
wire N_5360 ;
wire N_5361 ;
wire N_5362 ;
wire N_5363 ;
wire N_5364 ;
wire N_5365 ;
wire N_5366 ;
wire N_5367 ;
wire N_5368 ;
wire N_5369 ;
wire N_5370 ;
wire N_5371 ;
wire N_5372 ;
wire N_5373 ;
wire N_5374 ;
wire N_5375 ;
wire N_5376 ;
wire N_5377 ;
wire N_5378 ;
wire N_5379 ;
wire N_5380 ;
wire N_5381 ;
wire N_5382 ;
wire N_5383 ;
wire N_5384 ;
wire N_5385 ;
wire N_5386 ;
wire N_5387 ;
wire N_5388 ;
wire N_5389 ;
wire N_5390 ;
wire N_5391 ;
wire N_5392 ;
wire N_5393 ;
wire N_5394 ;
wire N_5395 ;
wire N_5396 ;
wire N_5397 ;
wire N_5398 ;
wire N_5399 ;
wire N_5400 ;
wire N_5401 ;
wire N_5402 ;
wire N_5403 ;
wire N_5404 ;
wire N_5405 ;
wire N_5406 ;
wire N_5407 ;
wire N_5408 ;
wire N_5409 ;
wire N_5410 ;
wire N_5411 ;
wire N_5412 ;
wire N_5413 ;
wire N_5414 ;
wire N_5415 ;
wire N_5416 ;
wire N_5417 ;
wire N_5418 ;
wire N_5419 ;
wire N_5420 ;
wire N_5421 ;
wire N_5422 ;
wire N_5423 ;
wire N_5424 ;
wire N_5425 ;
wire N_5426 ;
wire N_5427 ;
wire N_5428 ;
wire N_5429 ;
wire N_5430 ;
wire N_5431 ;
wire N_5432 ;
wire N_5434 ;
wire N_5436 ;
wire N_5438 ;
wire N_5440 ;
wire N_5442 ;
wire N_5444 ;
wire N_5446 ;
wire N_5448 ;
wire N_5450 ;
wire N_5452 ;
wire N_5454 ;
wire N_5456 ;
wire N_5458 ;
wire N_5460 ;
wire N_5462 ;
wire N_5464 ;
wire N_5466 ;
wire N_5468 ;
wire N_5470 ;
wire N_5471 ;
wire N_5472 ;
wire N_5474 ;
wire N_5475 ;
wire N_5477 ;
wire N_5478 ;
wire N_5480 ;
wire N_5481 ;
wire N_5483 ;
wire N_5485 ;
wire N_5486 ;
wire N_5487 ;
wire N_5488 ;
wire N_5489 ;
wire N_5490 ;
wire N_5491 ;
wire N_5492 ;
wire N_5493 ;
wire N_5495 ;
wire N_5497 ;
wire N_5499 ;
wire N_5501 ;
wire N_5503 ;
wire N_5505 ;
wire N_5507 ;
wire N_5509 ;
wire N_5511 ;
wire N_5513 ;
wire N_5515 ;
wire N_5517 ;
wire N_5519 ;
wire N_5521 ;
wire N_5523 ;
wire N_5525 ;
wire N_5527 ;
wire N_5529 ;
wire N_5531 ;
wire N_5533 ;
wire N_5535 ;
wire N_5537 ;
wire N_5539 ;
wire N_5541 ;
wire N_5543 ;
wire N_5545 ;
wire N_5547 ;
wire N_5549 ;
wire N_5551 ;
wire N_5553 ;
wire N_5555 ;
wire N_5557 ;
wire N_5559 ;
wire N_5561 ;
wire N_5563 ;
wire N_5565 ;
wire N_5567 ;
wire N_5569 ;
wire N_5571 ;
wire N_5573 ;
wire N_5575 ;
wire N_5577 ;
wire N_5579 ;
wire N_5581 ;
wire N_5583 ;
wire N_5585 ;
wire N_5587 ;
wire N_5589 ;
wire N_5591 ;
wire N_5593 ;
wire N_5595 ;
wire N_5597 ;
wire N_5599 ;
wire N_5601 ;
wire N_5603 ;
wire N_5605 ;
wire N_5607 ;
wire N_5609 ;
wire N_5611 ;
wire N_5613 ;
wire N_5615 ;
wire N_5617 ;
wire N_5619 ;
wire N_5621 ;
wire N_5623 ;
wire N_5625 ;
wire N_5627 ;
wire N_5629 ;
wire N_5631 ;
wire N_5633 ;
wire N_5635 ;
wire N_5637 ;
wire N_5639 ;
wire N_5640 ;
wire N_5641 ;
wire N_5642 ;
wire N_5643 ;
wire N_5645 ;
wire N_5646 ;
wire N_5647 ;
wire N_5648 ;
wire N_5649 ;
wire N_5650 ;
wire N_5651 ;
wire N_5652 ;
wire N_5653 ;
wire N_5654 ;
wire N_5655 ;
wire N_5656 ;
wire N_5657 ;
wire N_5658 ;
wire N_5659 ;
wire N_5660 ;
wire N_5661 ;
wire N_5662 ;
wire N_5663 ;
wire N_5664 ;
wire N_5665 ;
wire N_5666 ;
wire N_5667 ;
wire N_5668 ;
wire N_5669 ;
wire N_5670 ;
wire N_5671 ;
wire N_5672 ;
wire N_5673 ;
wire N_5674 ;
wire N_5675 ;
wire N_5676 ;
wire N_5677 ;
wire N_5678 ;
wire N_5679 ;
wire N_5680 ;
wire N_5681 ;
wire N_5682 ;
wire N_5683 ;
wire N_5684 ;
wire N_5685 ;
wire N_5686 ;
wire N_5687 ;
wire N_5688 ;
wire N_5689 ;
wire N_5690 ;
wire N_5691 ;
wire N_5692 ;
wire N_5693 ;
wire N_5694 ;
wire N_5695 ;
wire N_5696 ;
wire N_5697 ;
wire N_5698 ;
wire N_5699 ;
wire N_5700 ;
wire N_5701 ;
wire N_5702 ;
wire N_5703 ;
wire N_5704 ;
wire N_5705 ;
wire N_5706 ;
wire N_5707 ;
wire N_5708 ;
wire N_5709 ;
wire N_5710 ;
wire N_5711 ;
wire N_5712 ;
wire N_5713 ;
wire N_5714 ;
wire N_5715 ;
wire N_5716 ;
wire N_5717 ;
wire N_5718 ;
wire N_5719 ;
wire N_5720 ;
wire N_5721 ;
wire N_5722 ;
wire N_5723 ;
wire N_5724 ;
wire N_5725 ;
wire N_5726 ;
wire N_5727 ;
wire N_5728 ;
wire N_5729 ;
wire N_5730 ;
wire N_5732 ;
wire N_5734 ;
wire N_5736 ;
wire N_5738 ;
wire N_5740 ;
wire N_5742 ;
wire N_5744 ;
wire N_5746 ;
wire N_5748 ;
wire N_5750 ;
wire N_5752 ;
wire N_5754 ;
wire N_5756 ;
wire N_5758 ;
wire N_5760 ;
wire N_5762 ;
wire N_5764 ;
wire N_5766 ;
wire N_5768 ;
wire N_5770 ;
wire N_5772 ;
wire N_5774 ;
wire N_5776 ;
wire N_5778 ;
wire N_5780 ;
wire N_5782 ;
wire N_5784 ;
wire N_5786 ;
wire N_5788 ;
wire N_5790 ;
wire N_5792 ;
wire N_5793 ;
wire N_5794 ;
wire N_5795 ;
wire N_5797 ;
wire N_5799 ;
wire N_5801 ;
wire N_5803 ;
wire N_5805 ;
wire N_5807 ;
wire N_5809 ;
wire N_5811 ;
wire N_5813 ;
wire N_5815 ;
wire N_5817 ;
wire N_5819 ;
wire N_5821 ;
wire N_5823 ;
wire N_5825 ;
wire N_5827 ;
wire N_5829 ;
wire N_5831 ;
wire N_5833 ;
wire N_5835 ;
wire N_5837 ;
wire N_5839 ;
wire N_5841 ;
wire N_5843 ;
wire N_5845 ;
wire N_5847 ;
wire N_5849 ;
wire N_5851 ;
wire N_5853 ;
wire N_5855 ;
wire N_5857 ;
wire N_5859 ;
wire N_5861 ;
wire N_5863 ;
wire N_5865 ;
wire N_5867 ;
wire N_5869 ;
wire N_5871 ;
wire N_5873 ;
wire N_5875 ;
wire N_5877 ;
wire N_5879 ;
wire N_5881 ;
wire N_5883 ;
wire N_5885 ;
wire N_5887 ;
wire N_5889 ;
wire N_5891 ;
wire N_5893 ;
wire N_5895 ;
wire N_5897 ;
wire N_5899 ;
wire N_5901 ;
wire N_5903 ;
wire N_5905 ;
wire N_5907 ;
wire N_5909 ;
wire N_5911 ;
wire N_5913 ;
wire N_5915 ;
wire N_5917 ;
wire N_5919 ;
wire N_5921 ;
wire N_5923 ;
wire N_5925 ;
wire N_5927 ;
wire N_5929 ;
wire N_5931 ;
wire N_5933 ;
wire N_5935 ;
wire N_5937 ;
wire N_5939 ;
wire N_5941 ;
wire N_5943 ;
wire N_5945 ;
wire N_5947 ;
wire N_5949 ;
wire N_5951 ;
wire N_5953 ;
wire N_5955 ;
wire N_5957 ;
wire N_5959 ;
wire N_5961 ;
wire N_5963 ;
wire N_5965 ;
wire N_5967 ;
wire N_5969 ;
wire N_5971 ;
wire N_5973 ;
wire N_5975 ;
wire N_5977 ;
wire N_5979 ;
wire N_5981 ;
wire N_5983 ;
wire N_5985 ;
wire N_5987 ;
wire N_5989 ;
wire N_5991 ;
wire N_5993 ;
wire N_5995 ;
wire N_5997 ;
wire N_5999 ;
wire N_6001 ;
wire N_6003 ;
wire N_6005 ;
wire N_6007 ;
wire N_6009 ;
wire N_6011 ;
wire N_6013 ;
wire N_6015 ;
wire N_6017 ;
wire N_6019 ;
wire N_6021 ;
wire N_6023 ;
wire N_6025 ;
wire N_6027 ;
wire N_6029 ;
wire N_6031 ;
wire N_6033 ;
wire N_6035 ;
wire N_6037 ;
wire N_1 ;
wire N_2 ;
wire N_3 ;
wire N_4 ;
wire N_5 ;
wire N_6 ;
wire N_7 ;
wire N_8 ;
wire N_9 ;
wire N_10 ;
wire N_11 ;
wire N_12 ;
wire N_13 ;
wire N_14 ;
wire N_15 ;
wire N_16 ;
wire N_17 ;
wire N_18 ;
wire N_19 ;
wire N_20 ;
wire N_21 ;
wire N_22 ;
wire N_23 ;
wire N_24 ;
wire N_25 ;
wire N_26 ;
wire N_27 ;
wire N_28 ;
wire N_29 ;
wire N_30 ;
wire N_31 ;
wire N_32 ;
wire N_33 ;
wire N_34 ;
wire N_35 ;
wire N_36 ;
wire N_37 ;
// @11:77
  PDPW8KE \u_comps.R_data.mem_mem_0_0  (
	.DO0(\u_comps.data_R [9]),
	.DO1(\u_comps.data_R [10]),
	.DO2(\u_comps.data_R [11]),
	.DO3(\u_comps.data_R [12]),
	.DO4(\u_comps.data_R [13]),
	.DO5(\u_comps.data_R [14]),
	.DO6(\u_comps.data_R [15]),
	.DO7(\u_comps.R_data.mem_N_1 ),
	.DO8(\u_comps.R_data.mem_N_2 ),
	.DO9(\u_comps.data_R [0]),
	.DO10(\u_comps.data_R [1]),
	.DO11(\u_comps.data_R [2]),
	.DO12(\u_comps.data_R [3]),
	.DO13(\u_comps.data_R [4]),
	.DO14(\u_comps.data_R [5]),
	.DO15(\u_comps.data_R [6]),
	.DO16(\u_comps.data_R [7]),
	.DO17(\u_comps.data_R [8]),
	.DI0(\u_comps.din_w [0]),
	.DI1(\u_comps.din_w [1]),
	.DI2(\u_comps.din_w [2]),
	.DI3(\u_comps.din_w [3]),
	.DI4(\u_comps.din_w [4]),
	.DI5(\u_comps.din_w [5]),
	.DI6(\u_comps.din_w [6]),
	.DI7(\u_comps.din_w [7]),
	.DI8(\u_comps.din_w [8]),
	.DI9(\u_comps.din_w [9]),
	.DI10(\u_comps.din_w [10]),
	.DI11(\u_comps.din_w [11]),
	.DI12(\u_comps.din_w [11]),
	.DI13(\u_comps.din_w [11]),
	.DI14(\u_comps.din_w [11]),
	.DI15(\u_comps.din_w [11]),
	.DI16(GND),
	.DI17(GND),
	.ADR0(GND),
	.ADR1(GND),
	.ADR2(GND),
	.ADR3(GND),
	.ADR4(\u_comps.run_even ),
	.ADR5(\u_comps.raddr_R [0]),
	.ADR6(\u_comps.raddr_R [1]),
	.ADR7(\u_comps.raddr_R [2]),
	.ADR8(\u_comps.raddr_R [3]),
	.ADR9(\u_comps.raddr_R [4]),
	.ADR10(\u_comps.raddr_R [5]),
	.ADR11(GND),
	.ADR12(GND),
	.ADW0(\u_comps.waddr [0]),
	.ADW1(\u_comps.waddr [1]),
	.ADW2(\u_comps.waddr [2]),
	.ADW3(\u_comps.waddr [3]),
	.ADW4(\u_comps.waddr [4]),
	.ADW5(\u_comps.waddr [5]),
	.ADW6(\u_comps.waddr [6]),
	.ADW7(GND),
	.ADW8(GND),
	.BE1(VCC),
	.BE0(VCC),
	.RST(GND),
	.CSR0(GND),
	.CSR1(GND),
	.CSR2(GND),
	.CSW0(GND),
	.CSW1(GND),
	.CSW2(GND),
	.CLKW(pdm_clk),
	.CLKR(pdm_clk),
	.CEW(\u_comps.din_we ),
	.CER(VCC),
	.OCER(VCC)
);
defparam \u_comps.R_data.mem_mem_0_0 .DATA_WIDTH_R=18;
// @11:77
  PDPW8KE \u_comps.L_data.mem_mem_0_0  (
	.DO0(\u_comps.data_L [9]),
	.DO1(\u_comps.data_L [10]),
	.DO2(\u_comps.data_L [11]),
	.DO3(\u_comps.data_L [12]),
	.DO4(\u_comps.data_L [13]),
	.DO5(\u_comps.data_L [14]),
	.DO6(\u_comps.data_L [15]),
	.DO7(\u_comps.L_data.mem_N_1 ),
	.DO8(\u_comps.L_data.mem_N_2 ),
	.DO9(\u_comps.data_L [0]),
	.DO10(\u_comps.data_L [1]),
	.DO11(\u_comps.data_L [2]),
	.DO12(\u_comps.data_L [3]),
	.DO13(\u_comps.data_L [4]),
	.DO14(\u_comps.data_L [5]),
	.DO15(\u_comps.data_L [6]),
	.DO16(\u_comps.data_L [7]),
	.DO17(\u_comps.data_L [8]),
	.DI0(\u_comps.din_w [0]),
	.DI1(\u_comps.din_w [1]),
	.DI2(\u_comps.din_w [2]),
	.DI3(\u_comps.din_w [3]),
	.DI4(\u_comps.din_w [4]),
	.DI5(\u_comps.din_w [5]),
	.DI6(\u_comps.din_w [6]),
	.DI7(\u_comps.din_w [7]),
	.DI8(\u_comps.din_w [8]),
	.DI9(\u_comps.din_w [9]),
	.DI10(\u_comps.din_w [10]),
	.DI11(\u_comps.din_w [11]),
	.DI12(\u_comps.din_w [11]),
	.DI13(\u_comps.din_w [11]),
	.DI14(\u_comps.din_w [11]),
	.DI15(\u_comps.din_w [11]),
	.DI16(GND),
	.DI17(GND),
	.ADR0(GND),
	.ADR1(GND),
	.ADR2(GND),
	.ADR3(GND),
	.ADR4(\u_comps.run_even ),
	.ADR5(\u_comps.raddr_L [0]),
	.ADR6(\u_comps.raddr_L [1]),
	.ADR7(\u_comps.raddr_L [2]),
	.ADR8(\u_comps.raddr_L [3]),
	.ADR9(\u_comps.raddr_L [4]),
	.ADR10(\u_comps.raddr_L [5]),
	.ADR11(GND),
	.ADR12(GND),
	.ADW0(\u_comps.waddr [0]),
	.ADW1(\u_comps.waddr [1]),
	.ADW2(\u_comps.waddr [2]),
	.ADW3(\u_comps.waddr [3]),
	.ADW4(\u_comps.waddr [4]),
	.ADW5(\u_comps.waddr [5]),
	.ADW6(\u_comps.waddr [6]),
	.ADW7(GND),
	.ADW8(GND),
	.BE1(VCC),
	.BE0(VCC),
	.RST(GND),
	.CSR0(GND),
	.CSR1(GND),
	.CSR2(GND),
	.CSW0(GND),
	.CSW1(GND),
	.CSW2(GND),
	.CLKW(pdm_clk),
	.CLKR(pdm_clk),
	.CEW(\u_comps.din_we ),
	.CER(VCC),
	.OCER(VCC)
);
defparam \u_comps.L_data.mem_mem_0_0 .DATA_WIDTH_R=18;
// @12:64
  PDPW8KE \u_comps.u_coeff.Data_r_2_0_0  (
	.DO0(\u_comps.cdata [9]),
	.DO1(\u_comps.cdata [10]),
	.DO2(\u_comps.cdata [11]),
	.DO3(\u_comps.cdata [12]),
	.DO4(\u_comps.cdata [13]),
	.DO5(\u_comps.cdata [14]),
	.DO6(\u_comps.cdata [15]),
	.DO7(N_1686),
	.DO8(N_1687),
	.DO9(\u_comps.cdata [0]),
	.DO10(\u_comps.cdata [1]),
	.DO11(\u_comps.cdata [2]),
	.DO12(\u_comps.cdata [3]),
	.DO13(\u_comps.cdata [4]),
	.DO14(\u_comps.cdata [5]),
	.DO15(\u_comps.cdata [6]),
	.DO16(\u_comps.cdata [7]),
	.DO17(\u_comps.cdata [8]),
	.DI0(GND),
	.DI1(GND),
	.DI2(GND),
	.DI3(GND),
	.DI4(GND),
	.DI5(GND),
	.DI6(GND),
	.DI7(GND),
	.DI8(GND),
	.DI9(GND),
	.DI10(GND),
	.DI11(GND),
	.DI12(GND),
	.DI13(GND),
	.DI14(GND),
	.DI15(GND),
	.DI16(GND),
	.DI17(GND),
	.ADR0(GND),
	.ADR1(GND),
	.ADR2(GND),
	.ADR3(GND),
	.ADR4(\u_comps.caddr_r [0]),
	.ADR5(\u_comps.caddr_r [1]),
	.ADR6(\u_comps.caddr_r [2]),
	.ADR7(\u_comps.caddr_r [3]),
	.ADR8(\u_comps.caddr_r [4]),
	.ADR9(GND),
	.ADR10(GND),
	.ADR11(GND),
	.ADR12(GND),
	.ADW0(GND),
	.ADW1(GND),
	.ADW2(GND),
	.ADW3(GND),
	.ADW4(GND),
	.ADW5(GND),
	.ADW6(GND),
	.ADW7(GND),
	.ADW8(GND),
	.BE1(GND),
	.BE0(GND),
	.RST(GND),
	.CSR0(GND),
	.CSR1(GND),
	.CSR2(GND),
	.CSW0(GND),
	.CSW1(GND),
	.CSW2(GND),
	.CLKW(GND),
	.CLKR(pdm_clk),
	.CEW(GND),
	.CER(VCC),
	.OCER(VCC)
);
defparam \u_comps.u_coeff.Data_r_2_0_0 .DATA_WIDTH_R=18;
defparam \u_comps.u_coeff.Data_r_2_0_0 .DATA_WIDTH_W=18;
defparam \u_comps.u_coeff.Data_r_2_0_0 .GSR="DISABLED";
defparam \u_comps.u_coeff.Data_r_2_0_0 .INITVAL_00="0x0FE190FFCD00159000600FF180FF930008E000610FFAF0FFB0000270003B0FFEE0FFD20000400026";
defparam \u_comps.u_coeff.Data_r_2_0_0 .INITVAL_01="0x0441002BDD0FFA30EDE40FC21009FC004720FA0C0FBBE00380003C20FE170FCD8000DA002820FFCF";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_s_15_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [30]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [30]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_cry_14 ),
	.COUT(N_3703),
	.S0(\u_comps.mult_result [30]),
	.S1(N_3702)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_s_15_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_s_15_0 .INIT1=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_s_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_s_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_cry_13_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [28]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [28]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [29]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [29]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_cry_12 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_cry_14 ),
	.S0(\u_comps.mult_result [28]),
	.S1(\u_comps.mult_result [29])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_13_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_13_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_13_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_cry_11_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [26]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [26]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [27]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [27]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_cry_10 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_cry_12 ),
	.S0(\u_comps.mult_result [26]),
	.S1(\u_comps.mult_result [27])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_11_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_11_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_11_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_cry_9_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [24]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [24]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [25]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [25]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_cry_8 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_cry_10 ),
	.S0(\u_comps.mult_result [24]),
	.S1(\u_comps.mult_result [25])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_9_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_9_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_9_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_cry_7_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [22]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [22]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [23]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [23]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_cry_6 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_cry_8 ),
	.S0(\u_comps.mult_result [22]),
	.S1(\u_comps.mult_result [23])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_7_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_7_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_7_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_cry_5_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [20]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [20]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [21]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [21]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_cry_4 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_cry_6 ),
	.S0(\u_comps.mult_result [20]),
	.S1(\u_comps.mult_result [21])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_5_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_5_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_5_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_cry_3_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [18]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [18]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [19]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [19]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_cry_2 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_cry_4 ),
	.S0(\u_comps.mult_result [18]),
	.S1(\u_comps.mult_result [19])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_3_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_3_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_3_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_cry_1_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [16]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [16]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [17]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [17]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_cry_0 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_cry_2 ),
	.S0(\u_comps.mult_result [16]),
	.S1(\u_comps.mult_result [17])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_1_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_1_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_B_4_1 ),
	.B1(\u_comps.mac_B_4_2 ),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_cry_0 ),
	.S0(N_3687),
	.S1(N_2913)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_0_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_cry_0_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_21_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_11f [29]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_11f [30]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_20 ),
	.COUT(N_3685),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [29]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [30])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_21_0 .INIT0=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_21_0 .INIT1=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_21_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_21_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_19_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_11f [27]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_11f [28]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_18 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_20 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [27]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [28])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_19_0 .INIT0=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_19_0 .INIT1=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_19_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_19_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_17_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_11f [25]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_11f [26]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_16 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_18 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [25]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [26])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_17_0 .INIT0=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_17_0 .INIT1=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_17_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_17_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_15_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_12f [23]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_11f [23]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_12f [24]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_11f [24]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_14 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_16 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [23]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [24])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_15_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_15_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_13_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_12f [21]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_11f [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_12f [22]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_11f [22]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_12 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_14 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [21]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [22])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_13_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_13_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_13_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_11_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_12f [19]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_11f [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_12f [20]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_11f [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_10 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_12 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [19]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [20])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_11_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_11_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_11_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_9_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_12f [17]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_11f [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_12f [18]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_11f [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_8 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_10 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_14 [17]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [18])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_9_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_9_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_9_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_7_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_12f [15]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_11f [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_12f [16]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_11f [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_6 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_8 ),
	.S0(\u_comps.mac_B_4_1 ),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_14 [16])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_7_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_7_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_7_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_5_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_12f [13]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_12f [14]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_4 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_6 ),
	.S0(\u_comps.mult_result [13]),
	.S1(\u_comps.mult_result [14])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_5_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_5_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_5_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_3_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_12f [11]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_12f [12]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_2 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_4 ),
	.S0(\u_comps.mult_result [11]),
	.S1(\u_comps.mult_result [12])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_3_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_3_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_3_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_1_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_12f [9]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_13f [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_12f [10]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_13f [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_0 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_2 ),
	.S0(\u_comps.mult_result [9]),
	.S1(\u_comps.mult_result [10])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_1_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_1_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_B_4_scalar ),
	.B1(\u_comps.mac_B_4_0 ),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_14_cry_0 ),
	.S0(N_3663),
	.S1(N_2898)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_0_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_14_cry_0_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_15_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_15_cry ),
	.COUT(N_3660),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [28]),
	.S1(N_3661)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_15_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_15_0 .INIT1=16'h0000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_14_0  (
	.A0(\u_comps.u_mult.DATAA_R [13]),
	.B0(\u_comps.u_mult.DATAB_R [13]),
	.C0(\u_comps.u_mult.DATAB_R [14]),
	.D0(\u_comps.u_mult.DATAA_R [12]),
	.A1(\u_comps.u_mult.DATAA_R [13]),
	.B1(\u_comps.u_mult.DATAB_R [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_13 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_15_cry ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [26]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [27])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_14_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_14_0 .INIT1=16'h8008;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_14_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_14_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_12_0  (
	.A0(\u_comps.u_mult.DATAA_R [13]),
	.B0(\u_comps.u_mult.DATAB_R [11]),
	.C0(\u_comps.u_mult.DATAB_R [12]),
	.D0(\u_comps.u_mult.DATAA_R [12]),
	.A1(\u_comps.u_mult.DATAA_R [13]),
	.B1(\u_comps.u_mult.DATAB_R [12]),
	.C1(\u_comps.u_mult.DATAB_R [13]),
	.D1(\u_comps.u_mult.DATAA_R [12]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_11 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_13 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [24]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [25])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_12_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_12_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_12_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_12_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_10_0  (
	.A0(\u_comps.u_mult.DATAA_R [13]),
	.B0(\u_comps.u_mult.DATAB_R [9]),
	.C0(\u_comps.u_mult.DATAB_R [10]),
	.D0(\u_comps.u_mult.DATAA_R [12]),
	.A1(\u_comps.u_mult.DATAA_R [13]),
	.B1(\u_comps.u_mult.DATAB_R [10]),
	.C1(\u_comps.u_mult.DATAB_R [11]),
	.D1(\u_comps.u_mult.DATAA_R [12]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_9 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_11 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [22]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [23])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_10_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_10_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_10_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_10_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_8_0  (
	.A0(\u_comps.u_mult.DATAA_R [13]),
	.B0(\u_comps.u_mult.DATAB_R [7]),
	.C0(\u_comps.u_mult.DATAB_R [8]),
	.D0(\u_comps.u_mult.DATAA_R [12]),
	.A1(\u_comps.u_mult.DATAA_R [13]),
	.B1(\u_comps.u_mult.DATAB_R [8]),
	.C1(\u_comps.u_mult.DATAB_R [9]),
	.D1(\u_comps.u_mult.DATAA_R [12]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_7 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_9 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [20]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [21])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_8_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_8_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_8_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_8_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_6_0  (
	.A0(\u_comps.u_mult.DATAA_R [13]),
	.B0(\u_comps.u_mult.DATAB_R [5]),
	.C0(\u_comps.u_mult.DATAB_R [6]),
	.D0(\u_comps.u_mult.DATAA_R [12]),
	.A1(\u_comps.u_mult.DATAA_R [13]),
	.B1(\u_comps.u_mult.DATAB_R [6]),
	.C1(\u_comps.u_mult.DATAB_R [7]),
	.D1(\u_comps.u_mult.DATAA_R [12]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_5 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_7 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [18]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [19])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_6_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_6_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_6_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_6_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_4_0  (
	.A0(\u_comps.u_mult.DATAA_R [14]),
	.B0(\u_comps.u_mult.DATAB_R [2]),
	.C0(\u_comps.u_mult.DATAB_R [3]),
	.D0(\u_comps.u_mult.DATAA_R [13]),
	.A1(\u_comps.u_mult.DATAA_R [13]),
	.B1(\u_comps.u_mult.DATAB_R [4]),
	.C1(\u_comps.u_mult.DATAB_R [5]),
	.D1(\u_comps.u_mult.DATAA_R [12]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_3 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_5 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [16]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [17])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_4_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_4_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_4_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_4_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_2_0  (
	.A0(\u_comps.u_mult.DATAA_R [13]),
	.B0(\u_comps.u_mult.DATAB_R [1]),
	.C0(\u_comps.u_mult.DATAB_R [2]),
	.D0(\u_comps.u_mult.DATAA_R [12]),
	.A1(\u_comps.u_mult.DATAA_R [13]),
	.B1(\u_comps.u_mult.DATAB_R [2]),
	.C1(\u_comps.u_mult.DATAB_R [3]),
	.D1(\u_comps.u_mult.DATAA_R [12]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_1 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_3 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [14]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [15])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_2_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_2_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_2_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_1_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [13]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.DATAB_R [1]),
	.D1(\u_comps.u_mult.DATAA_R [12]),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_6_cry_1 ),
	.S0(N_3644),
	.S1(N_2881)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_1_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_1_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_6_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_18_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_18_cry ),
	.COUT(N_3641),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [27]),
	.S1(N_3642)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_18_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_18_0 .INIT1=16'h0000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_18_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_18_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_17_0  (
	.A0(\u_comps.u_mult.DATAB_R [10]),
	.B0(\u_comps.u_mult.DATAA_R [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAB_R [11]),
	.B1(\u_comps.u_mult.DATAA_R [15]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_16 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_18_cry ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [25]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [26])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_17_0 .INIT0=16'h4000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_17_0 .INIT1=16'h4000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_17_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_17_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_15_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [23]),
	.B0(\u_comps.u_mult.DATAB_R [8]),
	.C0(\u_comps.u_mult.DATAA_R [15]),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [24]),
	.B1(\u_comps.u_mult.DATAB_R [9]),
	.C1(\u_comps.u_mult.DATAA_R [15]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_14 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_16 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [23]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [24])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_15_0 .INIT0=16'h9a0a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_15_0 .INIT1=16'h9a0a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_13_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [21]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [22]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [22]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_12 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_14 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [21]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [22])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_13_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_13_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_13_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_11_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [19]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [20]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_10 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_12 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [19]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [20])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_11_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_11_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_11_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_9_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [17]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [18]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_8 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_10 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [17]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [18])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_9_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_9_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_9_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_7_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [15]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [16]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_6 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_8 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [15]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [16])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_7_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_7_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_7_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_5_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [13]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [14]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_4 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_6 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [13]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [14])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_5_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_5_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_5_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_3_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [11]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [12]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_2 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_4 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [11]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [12])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_3_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_3_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_3_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_2_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_10_scalar ),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_10_cry_2 ),
	.S0(N_3623),
	.S1(N_2851)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_2_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_2_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_10_cry_2_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_17_0  (
	.A0(\u_comps.u_mult.DATAB_R [14]),
	.B0(\u_comps.u_mult.DATAA_R [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [15]),
	.B1(\u_comps.u_mult.DATAB_R [15]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_16 ),
	.COUT(N_3621),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_11 [29]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_11 [30])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_17_0 .INIT0=16'h4000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_17_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_17_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_17_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_15_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [27]),
	.B0(\u_comps.u_mult.DATAB_R [12]),
	.C0(\u_comps.u_mult.DATAA_R [15]),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [28]),
	.B1(\u_comps.u_mult.DATAB_R [13]),
	.C1(\u_comps.u_mult.DATAA_R [15]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_14 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_16 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_11 [27]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_11 [28])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_15_0 .INIT0=16'h9a0a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_15_0 .INIT1=16'h9a0a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_13_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [25]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [25]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [26]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [26]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_12 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_14 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_11 [25]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_11 [26])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_13_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_13_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_13_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_11_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [23]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [23]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [24]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [24]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_10 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_12 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_11 [23]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_11 [24])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_11_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_11_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_11_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_9_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [21]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [22]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [22]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_8 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_10 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_11 [21]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_11 [22])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_9_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_9_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_9_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_7_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [19]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [20]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_6 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_8 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_11 [19]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_11 [20])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_7_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_7_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_7_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_5_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [17]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [18]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_4 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_6 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_11 [17]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_11 [18])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_5_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_5_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_5_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_3_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [15]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [16]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_2 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_4 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_11 [15]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_11 [16])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_3_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_3_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_3_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_2_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_11_scalar ),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_11_cry_2 ),
	.S0(N_3605),
	.S1(N_2834)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_2_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_2_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_11_cry_2_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_19_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [23]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_18 ),
	.COUT(N_3602),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_12 [23]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_12 [24])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_19_0 .INIT0=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_19_0 .INIT1=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_19_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_19_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_17_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [21]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [22]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_16 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_18 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_12 [21]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_12 [22])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_17_0 .INIT0=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_17_0 .INIT1=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_17_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_17_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_15_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [19]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [20]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_14 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_16 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_12 [19]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_12 [20])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_15_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_15_0 .INIT1=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_13_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [17]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [18]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_12 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_14 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_12 [17]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_12 [18])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_13_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_13_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_13_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_11_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [15]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [16]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_10 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_12 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_12 [15]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_12 [16])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_11_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_11_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_11_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_9_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [13]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [14]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_8 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_10 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_12 [13]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_12 [14])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_9_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_9_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_9_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_7_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [11]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [12]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_6 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_8 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_12 [11]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_12 [12])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_7_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_7_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_7_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_5_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [9]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [10]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_4 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_6 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_12 [9]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_12 [10])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_5_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_5_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_5_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_3_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [7]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [8]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_2 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_4 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2 [7]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_12 [8])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_3_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_3_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_3_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_1_0  (
	.A0(N_1265),
	.B0(N_1267),
	.C0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [5]),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_9_scalar ),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [6]),
	.C1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [6]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_0 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_2 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2 [5]),
	.S1(\u_comps.u_mult.PRODUCT_R_2 [6])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_1_0 .INIT0=16'h9606;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_1_0 .INIT1=16'h9606;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_12_scalar ),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_12_cry_0 ),
	.S0(N_3582),
	.S1(N_2818)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_0_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_0_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_16_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_16_cry ),
	.COUT(N_3579),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [19]),
	.S1(N_3580)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_16_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_16_0 .INIT1=16'h0000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_16_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_16_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_15_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [17]),
	.B0(\u_comps.u_mult.DATAB_R [2]),
	.C0(\u_comps.u_mult.DATAA_R [15]),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAB_R [3]),
	.B1(\u_comps.u_mult.DATAA_R [15]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_14 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_16_cry ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [17]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [18])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_15_0 .INIT0=16'h9a0a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_15_0 .INIT1=16'h4000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_13_0  (
	.A0(N_1451),
	.B0(N_1453),
	.C0(\u_comps.u_mult.DATAB_R [0]),
	.D0(\u_comps.u_mult.DATAA_R [15]),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [16]),
	.B1(\u_comps.u_mult.DATAB_R [1]),
	.C1(\u_comps.u_mult.DATAA_R [15]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_12 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_14 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [15]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [16])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_13_0 .INIT0=16'h6966;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_13_0 .INIT1=16'h9a0a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_13_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_11_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [13]),
	.B0(N_1110),
	.C0(N_1108),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [14]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [14]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_10 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_12 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [13]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [14])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_11_0 .INIT0=16'h960a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_11_0 .INIT1=16'h7808;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_11_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_9_0  (
	.A0(N_1357),
	.B0(N_1359),
	.C0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [11]),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [12]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.DATAA_R [12]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_8 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_10 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [11]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [12])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_9_0 .INIT0=16'h9606;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_9_0 .INIT1=16'h6a0a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_9_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_7_0  (
	.A0(N_1403),
	.B0(N_1405),
	.C0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [9]),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [10]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [10]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_6 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_8 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [9]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [10])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_7_0 .INIT0=16'h9606;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_7_0 .INIT1=16'h7808;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_7_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_5_0  (
	.A0(N_1219),
	.B0(N_1221),
	.C0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [7]),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [8]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [8]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_4 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_6 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [7]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [8])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_5_0 .INIT0=16'h9606;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_5_0 .INIT1=16'h7808;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_5_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_3_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [5]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [6]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [6]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_2 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_4 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_8 [5]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [6])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_3_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_3_0 .INIT1=16'h7808;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_3_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_1_0  (
	.A0(N_1311),
	.B0(N_1313),
	.C0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [3]),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [4]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [4]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_0 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_2 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2 [3]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_8 [4])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_1_0 .INIT0=16'h9606;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_1_0 .INIT1=16'h7808;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [2]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [2]),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_8_cry_0 ),
	.S0(N_3561),
	.S1(N_2800)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_0_0 .INIT1=16'h7808;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_0_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_15_0  (
	.A0(\u_comps.u_mult.DATAA_R [2]),
	.B0(\u_comps.u_mult.DATAB_R [14]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_14 ),
	.COUT(N_3558),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [16]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [17])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_15_0 .INIT0=16'h8008;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_15_0 .INIT1=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_13_0  (
	.A0(\u_comps.u_mult.DATAA_R [1]),
	.B0(\u_comps.u_mult.DATAB_R [13]),
	.C0(\u_comps.u_mult.DATAB_R [14]),
	.D0(\u_comps.u_mult.DATAA_R [0]),
	.A1(\u_comps.u_mult.DATAA_R [1]),
	.B1(\u_comps.u_mult.DATAB_R [14]),
	.C1(\u_comps.u_mult.DATAA_R [15]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_12 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_14 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [14]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [15])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_13_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_13_0 .INIT1=16'h7808;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_13_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_11_0  (
	.A0(\u_comps.u_mult.DATAA_R [1]),
	.B0(\u_comps.u_mult.DATAB_R [11]),
	.C0(\u_comps.u_mult.DATAB_R [12]),
	.D0(\u_comps.u_mult.DATAA_R [0]),
	.A1(\u_comps.u_mult.DATAA_R [1]),
	.B1(\u_comps.u_mult.DATAB_R [12]),
	.C1(\u_comps.u_mult.DATAB_R [13]),
	.D1(\u_comps.u_mult.DATAA_R [0]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_10 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_12 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [12]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [13])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_11_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_11_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_11_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_9_0  (
	.A0(\u_comps.u_mult.DATAA_R [1]),
	.B0(\u_comps.u_mult.DATAB_R [9]),
	.C0(\u_comps.u_mult.DATAB_R [10]),
	.D0(\u_comps.u_mult.DATAA_R [0]),
	.A1(\u_comps.u_mult.DATAA_R [1]),
	.B1(\u_comps.u_mult.DATAB_R [10]),
	.C1(\u_comps.u_mult.DATAB_R [11]),
	.D1(\u_comps.u_mult.DATAA_R [0]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_8 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_10 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [10]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [11])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_9_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_9_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_9_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_7_0  (
	.A0(\u_comps.u_mult.DATAA_R [1]),
	.B0(\u_comps.u_mult.DATAB_R [7]),
	.C0(\u_comps.u_mult.DATAB_R [8]),
	.D0(\u_comps.u_mult.DATAA_R [0]),
	.A1(\u_comps.u_mult.DATAA_R [1]),
	.B1(\u_comps.u_mult.DATAB_R [8]),
	.C1(\u_comps.u_mult.DATAB_R [9]),
	.D1(\u_comps.u_mult.DATAA_R [0]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_6 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_8 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [8]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [9])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_7_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_7_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_7_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_5_0  (
	.A0(\u_comps.u_mult.DATAA_R [1]),
	.B0(\u_comps.u_mult.DATAB_R [5]),
	.C0(\u_comps.u_mult.DATAB_R [6]),
	.D0(\u_comps.u_mult.DATAA_R [0]),
	.A1(\u_comps.u_mult.DATAA_R [1]),
	.B1(\u_comps.u_mult.DATAB_R [6]),
	.C1(\u_comps.u_mult.DATAB_R [7]),
	.D1(\u_comps.u_mult.DATAA_R [0]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_4 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_6 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [6]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [7])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_5_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_5_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_5_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_3_0  (
	.A0(\u_comps.u_mult.DATAA_R [1]),
	.B0(\u_comps.u_mult.DATAB_R [3]),
	.C0(\u_comps.u_mult.DATAB_R [4]),
	.D0(\u_comps.u_mult.DATAA_R [0]),
	.A1(\u_comps.u_mult.DATAA_R [1]),
	.B1(\u_comps.u_mult.DATAB_R [4]),
	.C1(\u_comps.u_mult.DATAB_R [5]),
	.D1(\u_comps.u_mult.DATAA_R [0]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_2 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_4 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [4]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [5])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_3_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_3_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_3_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_1_0  (
	.A0(\u_comps.u_mult.DATAA_R [1]),
	.B0(\u_comps.u_mult.DATAB_R [1]),
	.C0(\u_comps.u_mult.DATAB_R [2]),
	.D0(\u_comps.u_mult.DATAA_R [0]),
	.A1(\u_comps.u_mult.DATAA_R [1]),
	.B1(\u_comps.u_mult.DATAB_R [2]),
	.C1(\u_comps.u_mult.DATAB_R [3]),
	.D1(\u_comps.u_mult.DATAA_R [0]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_0 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_2 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [2]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [3])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_1_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_1_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [1]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.DATAB_R [1]),
	.D1(\u_comps.u_mult.DATAA_R [0]),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_0_cry_0 ),
	.S0(N_3542),
	.S1(N_2772)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_0_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_0_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_21_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [29]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [30]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_20 ),
	.COUT(N_3540),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_13 [29]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13 [30])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_21_0 .INIT0=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_21_0 .INIT1=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_21_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_21_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_19_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [27]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [27]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [28]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_18 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_20 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_13 [27]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13 [28])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_19_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_19_0 .INIT1=16'ha003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_19_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_19_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_17_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [25]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [25]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [26]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [26]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_16 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_18 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_13 [25]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13 [26])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_17_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_17_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_17_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_17_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_15_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [23]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [23]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [24]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [24]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_14 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_16 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_13 [23]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13 [24])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_15_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_15_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_13_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [21]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [22]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [22]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_12 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_14 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_13 [21]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13 [22])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_13_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_13_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_13_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_11_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [19]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [20]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_10 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_12 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_13 [19]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13 [20])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_11_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_11_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_11_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_9_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [17]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [18]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_8 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_10 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_13 [17]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13 [18])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_9_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_9_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_9_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_7_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [15]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [16]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_6 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_8 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_13 [15]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13 [16])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_7_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_7_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_7_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_5_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_10 [13]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [14]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [14]),
	.C1(\u_comps.u_mult.PRODUCT_R_2.madd_11_scalar ),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_4 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_6 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_13 [13]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13 [14])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_5_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_5_0 .INIT1=16'h960a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_5_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_4_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_13_scalar ),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_10 [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_13_cry_4 ),
	.S0(N_3522),
	.S1(N_2740)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_4_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_4_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_4_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_13_cry_4_0 .INJECT1_1="NO";
// @7:224
  CCU2C \u_comps.un3_data_M_s_15_0  (
	.A0(\u_comps.data_Lf [15]),
	.B0(\u_comps.data_Rf [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.un3_data_M_cry_14 ),
	.COUT(N_3519),
	.S0(\u_comps.un3_data_M [15]),
	.S1(N_3518)
);
defparam \u_comps.un3_data_M_s_15_0 .INIT0=16'h600a;
defparam \u_comps.un3_data_M_s_15_0 .INIT1=16'h5003;
defparam \u_comps.un3_data_M_s_15_0 .INJECT1_0="NO";
defparam \u_comps.un3_data_M_s_15_0 .INJECT1_1="NO";
// @7:224
  CCU2C \u_comps.un3_data_M_cry_13_0  (
	.A0(\u_comps.data_Lf [13]),
	.B0(\u_comps.data_Rf [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.data_Lf [14]),
	.B1(\u_comps.data_Rf [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.un3_data_M_cry_12 ),
	.COUT(\u_comps.un3_data_M_cry_14 ),
	.S0(\u_comps.un3_data_M [13]),
	.S1(\u_comps.un3_data_M [14])
);
defparam \u_comps.un3_data_M_cry_13_0 .INIT0=16'h600a;
defparam \u_comps.un3_data_M_cry_13_0 .INIT1=16'h600a;
defparam \u_comps.un3_data_M_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.un3_data_M_cry_13_0 .INJECT1_1="NO";
// @7:224
  CCU2C \u_comps.un3_data_M_cry_11_0  (
	.A0(\u_comps.data_Lf [11]),
	.B0(\u_comps.data_Rf [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.data_Lf [12]),
	.B1(\u_comps.data_Rf [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.un3_data_M_cry_10 ),
	.COUT(\u_comps.un3_data_M_cry_12 ),
	.S0(\u_comps.un3_data_M [11]),
	.S1(\u_comps.un3_data_M [12])
);
defparam \u_comps.un3_data_M_cry_11_0 .INIT0=16'h600a;
defparam \u_comps.un3_data_M_cry_11_0 .INIT1=16'h600a;
defparam \u_comps.un3_data_M_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.un3_data_M_cry_11_0 .INJECT1_1="NO";
// @7:224
  CCU2C \u_comps.un3_data_M_cry_9_0  (
	.A0(\u_comps.data_Lf [9]),
	.B0(\u_comps.data_Rf [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.data_Lf [10]),
	.B1(\u_comps.data_Rf [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.un3_data_M_cry_8 ),
	.COUT(\u_comps.un3_data_M_cry_10 ),
	.S0(\u_comps.un3_data_M [9]),
	.S1(\u_comps.un3_data_M [10])
);
defparam \u_comps.un3_data_M_cry_9_0 .INIT0=16'h600a;
defparam \u_comps.un3_data_M_cry_9_0 .INIT1=16'h600a;
defparam \u_comps.un3_data_M_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.un3_data_M_cry_9_0 .INJECT1_1="NO";
// @7:224
  CCU2C \u_comps.un3_data_M_cry_7_0  (
	.A0(\u_comps.data_Lf [7]),
	.B0(\u_comps.data_Rf [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.data_Lf [8]),
	.B1(\u_comps.data_Rf [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.un3_data_M_cry_6 ),
	.COUT(\u_comps.un3_data_M_cry_8 ),
	.S0(\u_comps.un3_data_M [7]),
	.S1(\u_comps.un3_data_M [8])
);
defparam \u_comps.un3_data_M_cry_7_0 .INIT0=16'h600a;
defparam \u_comps.un3_data_M_cry_7_0 .INIT1=16'h600a;
defparam \u_comps.un3_data_M_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.un3_data_M_cry_7_0 .INJECT1_1="NO";
// @7:224
  CCU2C \u_comps.un3_data_M_cry_5_0  (
	.A0(\u_comps.data_Lf [5]),
	.B0(\u_comps.data_Rf [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.data_Lf [6]),
	.B1(\u_comps.data_Rf [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.un3_data_M_cry_4 ),
	.COUT(\u_comps.un3_data_M_cry_6 ),
	.S0(\u_comps.un3_data_M [5]),
	.S1(\u_comps.un3_data_M [6])
);
defparam \u_comps.un3_data_M_cry_5_0 .INIT0=16'h600a;
defparam \u_comps.un3_data_M_cry_5_0 .INIT1=16'h600a;
defparam \u_comps.un3_data_M_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.un3_data_M_cry_5_0 .INJECT1_1="NO";
// @7:224
  CCU2C \u_comps.un3_data_M_cry_3_0  (
	.A0(\u_comps.data_Lf [3]),
	.B0(\u_comps.data_Rf [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.data_Lf [4]),
	.B1(\u_comps.data_Rf [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.un3_data_M_cry_2 ),
	.COUT(\u_comps.un3_data_M_cry_4 ),
	.S0(\u_comps.un3_data_M [3]),
	.S1(\u_comps.un3_data_M [4])
);
defparam \u_comps.un3_data_M_cry_3_0 .INIT0=16'h600a;
defparam \u_comps.un3_data_M_cry_3_0 .INIT1=16'h600a;
defparam \u_comps.un3_data_M_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.un3_data_M_cry_3_0 .INJECT1_1="NO";
// @7:224
  CCU2C \u_comps.un3_data_M_cry_1_0  (
	.A0(\u_comps.data_Lf [1]),
	.B0(\u_comps.data_Rf [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.data_Lf [2]),
	.B1(\u_comps.data_Rf [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.un3_data_M_cry_0 ),
	.COUT(\u_comps.un3_data_M_cry_2 ),
	.S0(\u_comps.un3_data_M [1]),
	.S1(\u_comps.un3_data_M [2])
);
defparam \u_comps.un3_data_M_cry_1_0 .INIT0=16'h600a;
defparam \u_comps.un3_data_M_cry_1_0 .INIT1=16'h600a;
defparam \u_comps.un3_data_M_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.un3_data_M_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.un3_data_M_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.data_Lf [0]),
	.B1(\u_comps.data_Rf [0]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.un3_data_M_cry_0 ),
	.S0(N_3503),
	.S1(N_2724)
);
defparam \u_comps.un3_data_M_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.un3_data_M_cry_0_0 .INIT1=16'h600a;
defparam \u_comps.un3_data_M_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.un3_data_M_cry_0_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_15_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_15_cry ),
	.COUT(N_3500),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [22]),
	.S1(N_3501)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_15_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_15_0 .INIT1=16'h0000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_14_0  (
	.A0(\u_comps.u_mult.DATAA_R [7]),
	.B0(\u_comps.u_mult.DATAB_R [13]),
	.C0(\u_comps.u_mult.DATAB_R [14]),
	.D0(\u_comps.u_mult.DATAA_R [6]),
	.A1(\u_comps.u_mult.DATAA_R [7]),
	.B1(\u_comps.u_mult.DATAB_R [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_13 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_15_cry ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [20]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [21])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_14_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_14_0 .INIT1=16'h8008;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_14_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_14_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_12_0  (
	.A0(\u_comps.u_mult.DATAA_R [7]),
	.B0(\u_comps.u_mult.DATAB_R [11]),
	.C0(\u_comps.u_mult.DATAB_R [12]),
	.D0(\u_comps.u_mult.DATAA_R [6]),
	.A1(\u_comps.u_mult.DATAA_R [7]),
	.B1(\u_comps.u_mult.DATAB_R [12]),
	.C1(\u_comps.u_mult.DATAB_R [13]),
	.D1(\u_comps.u_mult.DATAA_R [6]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_11 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_13 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [18]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [19])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_12_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_12_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_12_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_12_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_10_0  (
	.A0(\u_comps.u_mult.DATAA_R [8]),
	.B0(\u_comps.u_mult.DATAB_R [8]),
	.C0(\u_comps.u_mult.DATAB_R [9]),
	.D0(\u_comps.u_mult.DATAA_R [7]),
	.A1(\u_comps.u_mult.DATAA_R [7]),
	.B1(\u_comps.u_mult.DATAB_R [10]),
	.C1(\u_comps.u_mult.DATAB_R [11]),
	.D1(\u_comps.u_mult.DATAA_R [6]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_9 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_11 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [16]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [17])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_10_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_10_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_10_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_10_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_8_0  (
	.A0(\u_comps.u_mult.DATAA_R [7]),
	.B0(\u_comps.u_mult.DATAB_R [7]),
	.C0(\u_comps.u_mult.DATAB_R [8]),
	.D0(\u_comps.u_mult.DATAA_R [6]),
	.A1(\u_comps.u_mult.DATAA_R [7]),
	.B1(\u_comps.u_mult.DATAB_R [8]),
	.C1(\u_comps.u_mult.DATAB_R [9]),
	.D1(\u_comps.u_mult.DATAA_R [6]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_7 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_9 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [14]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [15])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_8_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_8_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_8_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_8_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_6_0  (
	.A0(\u_comps.u_mult.DATAA_R [7]),
	.B0(\u_comps.u_mult.DATAB_R [5]),
	.C0(\u_comps.u_mult.DATAB_R [6]),
	.D0(\u_comps.u_mult.DATAA_R [6]),
	.A1(\u_comps.u_mult.DATAA_R [7]),
	.B1(\u_comps.u_mult.DATAB_R [6]),
	.C1(\u_comps.u_mult.DATAB_R [7]),
	.D1(\u_comps.u_mult.DATAA_R [6]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_5 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_7 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [12]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [13])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_6_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_6_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_6_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_6_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_4_0  (
	.A0(\u_comps.u_mult.DATAA_R [7]),
	.B0(\u_comps.u_mult.DATAB_R [3]),
	.C0(\u_comps.u_mult.DATAB_R [4]),
	.D0(\u_comps.u_mult.DATAA_R [6]),
	.A1(\u_comps.u_mult.DATAA_R [7]),
	.B1(\u_comps.u_mult.DATAB_R [4]),
	.C1(\u_comps.u_mult.DATAB_R [5]),
	.D1(\u_comps.u_mult.DATAA_R [6]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_3 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_5 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [10]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [11])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_4_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_4_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_4_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_4_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_2_0  (
	.A0(\u_comps.u_mult.DATAA_R [7]),
	.B0(\u_comps.u_mult.DATAB_R [1]),
	.C0(\u_comps.u_mult.DATAB_R [2]),
	.D0(\u_comps.u_mult.DATAA_R [6]),
	.A1(\u_comps.u_mult.DATAA_R [7]),
	.B1(\u_comps.u_mult.DATAB_R [2]),
	.C1(\u_comps.u_mult.DATAB_R [3]),
	.D1(\u_comps.u_mult.DATAA_R [6]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_1 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_3 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [8]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [9])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_2_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_2_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_2_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_1_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [7]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.DATAB_R [1]),
	.D1(\u_comps.u_mult.DATAA_R [6]),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_3_cry_1 ),
	.S0(N_3484),
	.S1(N_2709)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_1_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_1_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_3_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_15_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_15_cry ),
	.COUT(N_3481),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [20]),
	.S1(N_3482)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_15_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_15_0 .INIT1=16'h0000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_14_0  (
	.A0(\u_comps.u_mult.DATAA_R [5]),
	.B0(\u_comps.u_mult.DATAB_R [13]),
	.C0(\u_comps.u_mult.DATAB_R [14]),
	.D0(\u_comps.u_mult.DATAA_R [4]),
	.A1(\u_comps.u_mult.DATAA_R [5]),
	.B1(\u_comps.u_mult.DATAB_R [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_13 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_15_cry ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [18]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [19])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_14_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_14_0 .INIT1=16'h8008;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_14_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_14_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_12_0  (
	.A0(\u_comps.u_mult.DATAA_R [6]),
	.B0(\u_comps.u_mult.DATAB_R [10]),
	.C0(\u_comps.u_mult.DATAB_R [11]),
	.D0(\u_comps.u_mult.DATAA_R [5]),
	.A1(\u_comps.u_mult.DATAA_R [5]),
	.B1(\u_comps.u_mult.DATAB_R [12]),
	.C1(\u_comps.u_mult.DATAB_R [13]),
	.D1(\u_comps.u_mult.DATAA_R [4]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_11 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_13 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [16]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [17])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_12_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_12_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_12_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_12_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_10_0  (
	.A0(\u_comps.u_mult.DATAA_R [5]),
	.B0(\u_comps.u_mult.DATAB_R [9]),
	.C0(\u_comps.u_mult.DATAB_R [10]),
	.D0(\u_comps.u_mult.DATAA_R [4]),
	.A1(\u_comps.u_mult.DATAA_R [5]),
	.B1(\u_comps.u_mult.DATAB_R [10]),
	.C1(\u_comps.u_mult.DATAB_R [11]),
	.D1(\u_comps.u_mult.DATAA_R [4]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_9 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_11 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [14]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [15])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_10_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_10_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_10_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_10_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_8_0  (
	.A0(\u_comps.u_mult.DATAA_R [5]),
	.B0(\u_comps.u_mult.DATAB_R [7]),
	.C0(\u_comps.u_mult.DATAB_R [8]),
	.D0(\u_comps.u_mult.DATAA_R [4]),
	.A1(\u_comps.u_mult.DATAA_R [5]),
	.B1(\u_comps.u_mult.DATAB_R [8]),
	.C1(\u_comps.u_mult.DATAB_R [9]),
	.D1(\u_comps.u_mult.DATAA_R [4]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_7 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_9 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [12]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [13])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_8_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_8_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_8_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_8_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_6_0  (
	.A0(\u_comps.u_mult.DATAA_R [5]),
	.B0(\u_comps.u_mult.DATAB_R [5]),
	.C0(\u_comps.u_mult.DATAB_R [6]),
	.D0(\u_comps.u_mult.DATAA_R [4]),
	.A1(\u_comps.u_mult.DATAA_R [5]),
	.B1(\u_comps.u_mult.DATAB_R [6]),
	.C1(\u_comps.u_mult.DATAB_R [7]),
	.D1(\u_comps.u_mult.DATAA_R [4]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_5 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_7 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [10]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [11])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_6_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_6_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_6_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_6_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_4_0  (
	.A0(\u_comps.u_mult.DATAA_R [5]),
	.B0(\u_comps.u_mult.DATAB_R [3]),
	.C0(\u_comps.u_mult.DATAB_R [4]),
	.D0(\u_comps.u_mult.DATAA_R [4]),
	.A1(\u_comps.u_mult.DATAA_R [5]),
	.B1(\u_comps.u_mult.DATAB_R [4]),
	.C1(\u_comps.u_mult.DATAB_R [5]),
	.D1(\u_comps.u_mult.DATAA_R [4]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_3 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_5 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [8]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [9])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_4_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_4_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_4_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_4_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_2_0  (
	.A0(\u_comps.u_mult.DATAA_R [5]),
	.B0(\u_comps.u_mult.DATAB_R [1]),
	.C0(\u_comps.u_mult.DATAB_R [2]),
	.D0(\u_comps.u_mult.DATAA_R [4]),
	.A1(\u_comps.u_mult.DATAA_R [5]),
	.B1(\u_comps.u_mult.DATAB_R [2]),
	.C1(\u_comps.u_mult.DATAB_R [3]),
	.D1(\u_comps.u_mult.DATAA_R [4]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_1 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_3 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [6]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [7])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_2_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_2_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_2_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_1_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [5]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.DATAB_R [1]),
	.D1(\u_comps.u_mult.DATAA_R [4]),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_2_cry_1 ),
	.S0(N_3465),
	.S1(N_2679)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_1_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_1_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_2_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_15_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_15_cry ),
	.COUT(N_3462),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [18]),
	.S1(N_3463)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_15_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_15_0 .INIT1=16'h0000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_14_0  (
	.A0(\u_comps.u_mult.DATAA_R [4]),
	.B0(\u_comps.u_mult.DATAB_R [12]),
	.C0(\u_comps.u_mult.DATAB_R [13]),
	.D0(\u_comps.u_mult.DATAA_R [3]),
	.A1(\u_comps.u_mult.DATAA_R [3]),
	.B1(\u_comps.u_mult.DATAB_R [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_13 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_15_cry ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [16]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [17])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_14_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_14_0 .INIT1=16'h8008;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_14_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_14_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_12_0  (
	.A0(\u_comps.u_mult.DATAA_R [3]),
	.B0(\u_comps.u_mult.DATAB_R [11]),
	.C0(\u_comps.u_mult.DATAB_R [12]),
	.D0(\u_comps.u_mult.DATAA_R [2]),
	.A1(\u_comps.u_mult.DATAA_R [3]),
	.B1(\u_comps.u_mult.DATAB_R [12]),
	.C1(\u_comps.u_mult.DATAB_R [13]),
	.D1(\u_comps.u_mult.DATAA_R [2]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_11 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_13 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_11_scalar ),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [15])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_12_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_12_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_12_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_12_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_10_0  (
	.A0(\u_comps.u_mult.DATAA_R [3]),
	.B0(\u_comps.u_mult.DATAB_R [9]),
	.C0(\u_comps.u_mult.DATAB_R [10]),
	.D0(\u_comps.u_mult.DATAA_R [2]),
	.A1(\u_comps.u_mult.DATAA_R [3]),
	.B1(\u_comps.u_mult.DATAB_R [10]),
	.C1(\u_comps.u_mult.DATAB_R [11]),
	.D1(\u_comps.u_mult.DATAA_R [2]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_9 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_11 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [12]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [13])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_10_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_10_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_10_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_10_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_8_0  (
	.A0(\u_comps.u_mult.DATAA_R [3]),
	.B0(\u_comps.u_mult.DATAB_R [7]),
	.C0(\u_comps.u_mult.DATAB_R [8]),
	.D0(\u_comps.u_mult.DATAA_R [2]),
	.A1(\u_comps.u_mult.DATAA_R [3]),
	.B1(\u_comps.u_mult.DATAB_R [8]),
	.C1(\u_comps.u_mult.DATAB_R [9]),
	.D1(\u_comps.u_mult.DATAA_R [2]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_7 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_9 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_10_scalar ),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [11])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_8_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_8_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_8_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_8_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_6_0  (
	.A0(\u_comps.u_mult.DATAA_R [3]),
	.B0(\u_comps.u_mult.DATAB_R [5]),
	.C0(\u_comps.u_mult.DATAB_R [6]),
	.D0(\u_comps.u_mult.DATAA_R [2]),
	.A1(\u_comps.u_mult.DATAA_R [3]),
	.B1(\u_comps.u_mult.DATAB_R [6]),
	.C1(\u_comps.u_mult.DATAB_R [7]),
	.D1(\u_comps.u_mult.DATAA_R [2]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_5 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_7 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [8]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [9])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_6_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_6_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_6_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_6_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_4_0  (
	.A0(\u_comps.u_mult.DATAA_R [3]),
	.B0(\u_comps.u_mult.DATAB_R [3]),
	.C0(\u_comps.u_mult.DATAB_R [4]),
	.D0(\u_comps.u_mult.DATAA_R [2]),
	.A1(\u_comps.u_mult.DATAA_R [3]),
	.B1(\u_comps.u_mult.DATAB_R [4]),
	.C1(\u_comps.u_mult.DATAB_R [5]),
	.D1(\u_comps.u_mult.DATAA_R [2]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_3 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_5 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9_scalar ),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [7])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_4_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_4_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_4_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_4_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_2_0  (
	.A0(\u_comps.u_mult.DATAA_R [3]),
	.B0(\u_comps.u_mult.DATAB_R [1]),
	.C0(\u_comps.u_mult.DATAB_R [2]),
	.D0(\u_comps.u_mult.DATAA_R [2]),
	.A1(\u_comps.u_mult.DATAA_R [3]),
	.B1(\u_comps.u_mult.DATAB_R [2]),
	.C1(\u_comps.u_mult.DATAB_R [3]),
	.D1(\u_comps.u_mult.DATAA_R [2]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_1 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_3 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_12_scalar ),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_1 [5])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_2_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_2_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_2_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_1_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [3]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.DATAB_R [1]),
	.D1(\u_comps.u_mult.DATAA_R [2]),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_1_cry_1 ),
	.S0(N_3446),
	.S1(N_2649)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_1_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_1_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_15_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_15_cry ),
	.COUT(N_3443),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [26]),
	.S1(N_3444)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_15_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_15_0 .INIT1=16'h0000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_14_0  (
	.A0(\u_comps.u_mult.DATAA_R [11]),
	.B0(\u_comps.u_mult.DATAB_R [13]),
	.C0(\u_comps.u_mult.DATAB_R [14]),
	.D0(\u_comps.u_mult.DATAA_R [10]),
	.A1(\u_comps.u_mult.DATAA_R [11]),
	.B1(\u_comps.u_mult.DATAB_R [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_13 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_15_cry ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [24]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [25])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_14_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_14_0 .INIT1=16'h8008;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_14_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_14_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_12_0  (
	.A0(\u_comps.u_mult.DATAA_R [11]),
	.B0(\u_comps.u_mult.DATAB_R [11]),
	.C0(\u_comps.u_mult.DATAB_R [12]),
	.D0(\u_comps.u_mult.DATAA_R [10]),
	.A1(\u_comps.u_mult.DATAA_R [11]),
	.B1(\u_comps.u_mult.DATAB_R [12]),
	.C1(\u_comps.u_mult.DATAB_R [13]),
	.D1(\u_comps.u_mult.DATAA_R [10]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_11 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_13 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [22]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [23])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_12_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_12_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_12_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_12_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_10_0  (
	.A0(\u_comps.u_mult.DATAA_R [11]),
	.B0(\u_comps.u_mult.DATAB_R [9]),
	.C0(\u_comps.u_mult.DATAB_R [10]),
	.D0(\u_comps.u_mult.DATAA_R [10]),
	.A1(\u_comps.u_mult.DATAA_R [11]),
	.B1(\u_comps.u_mult.DATAB_R [10]),
	.C1(\u_comps.u_mult.DATAB_R [11]),
	.D1(\u_comps.u_mult.DATAA_R [10]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_9 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_11 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [20]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [21])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_10_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_10_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_10_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_10_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_8_0  (
	.A0(\u_comps.u_mult.DATAA_R [11]),
	.B0(\u_comps.u_mult.DATAB_R [7]),
	.C0(\u_comps.u_mult.DATAB_R [8]),
	.D0(\u_comps.u_mult.DATAA_R [10]),
	.A1(\u_comps.u_mult.DATAA_R [11]),
	.B1(\u_comps.u_mult.DATAB_R [8]),
	.C1(\u_comps.u_mult.DATAB_R [9]),
	.D1(\u_comps.u_mult.DATAA_R [10]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_7 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_9 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [18]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [19])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_8_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_8_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_8_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_8_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_6_0  (
	.A0(\u_comps.u_mult.DATAA_R [12]),
	.B0(\u_comps.u_mult.DATAB_R [4]),
	.C0(\u_comps.u_mult.DATAB_R [5]),
	.D0(\u_comps.u_mult.DATAA_R [11]),
	.A1(\u_comps.u_mult.DATAA_R [11]),
	.B1(\u_comps.u_mult.DATAB_R [6]),
	.C1(\u_comps.u_mult.DATAB_R [7]),
	.D1(\u_comps.u_mult.DATAA_R [10]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_5 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_7 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [16]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [17])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_6_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_6_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_6_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_6_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_4_0  (
	.A0(\u_comps.u_mult.DATAA_R [11]),
	.B0(\u_comps.u_mult.DATAB_R [3]),
	.C0(\u_comps.u_mult.DATAB_R [4]),
	.D0(\u_comps.u_mult.DATAA_R [10]),
	.A1(\u_comps.u_mult.DATAA_R [11]),
	.B1(\u_comps.u_mult.DATAB_R [4]),
	.C1(\u_comps.u_mult.DATAB_R [5]),
	.D1(\u_comps.u_mult.DATAA_R [10]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_3 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_5 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [14]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [15])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_4_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_4_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_4_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_4_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_2_0  (
	.A0(\u_comps.u_mult.DATAA_R [11]),
	.B0(\u_comps.u_mult.DATAB_R [1]),
	.C0(\u_comps.u_mult.DATAB_R [2]),
	.D0(\u_comps.u_mult.DATAA_R [10]),
	.A1(\u_comps.u_mult.DATAA_R [11]),
	.B1(\u_comps.u_mult.DATAB_R [2]),
	.C1(\u_comps.u_mult.DATAB_R [3]),
	.D1(\u_comps.u_mult.DATAA_R [10]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_1 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_3 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [12]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [13])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_2_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_2_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_2_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_1_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [11]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.DATAB_R [1]),
	.D1(\u_comps.u_mult.DATAA_R [10]),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_5_cry_1 ),
	.S0(N_3427),
	.S1(N_2619)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_1_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_1_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_5_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_15_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_15_cry ),
	.COUT(N_3424),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [24]),
	.S1(N_3425)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_15_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_15_0 .INIT1=16'h0000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_14_0  (
	.A0(\u_comps.u_mult.DATAA_R [9]),
	.B0(\u_comps.u_mult.DATAB_R [13]),
	.C0(\u_comps.u_mult.DATAB_R [14]),
	.D0(\u_comps.u_mult.DATAA_R [8]),
	.A1(\u_comps.u_mult.DATAA_R [9]),
	.B1(\u_comps.u_mult.DATAB_R [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_13 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_15_cry ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [22]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [23])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_14_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_14_0 .INIT1=16'h8008;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_14_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_14_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_12_0  (
	.A0(\u_comps.u_mult.DATAA_R [9]),
	.B0(\u_comps.u_mult.DATAB_R [11]),
	.C0(\u_comps.u_mult.DATAB_R [12]),
	.D0(\u_comps.u_mult.DATAA_R [8]),
	.A1(\u_comps.u_mult.DATAA_R [9]),
	.B1(\u_comps.u_mult.DATAB_R [12]),
	.C1(\u_comps.u_mult.DATAB_R [13]),
	.D1(\u_comps.u_mult.DATAA_R [8]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_11 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_13 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [20]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [21])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_12_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_12_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_12_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_12_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_10_0  (
	.A0(\u_comps.u_mult.DATAA_R [9]),
	.B0(\u_comps.u_mult.DATAB_R [9]),
	.C0(\u_comps.u_mult.DATAB_R [10]),
	.D0(\u_comps.u_mult.DATAA_R [8]),
	.A1(\u_comps.u_mult.DATAA_R [9]),
	.B1(\u_comps.u_mult.DATAB_R [10]),
	.C1(\u_comps.u_mult.DATAB_R [11]),
	.D1(\u_comps.u_mult.DATAA_R [8]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_9 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_11 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [18]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [19])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_10_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_10_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_10_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_10_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_8_0  (
	.A0(\u_comps.u_mult.DATAA_R [10]),
	.B0(\u_comps.u_mult.DATAB_R [6]),
	.C0(\u_comps.u_mult.DATAB_R [7]),
	.D0(\u_comps.u_mult.DATAA_R [9]),
	.A1(\u_comps.u_mult.DATAA_R [9]),
	.B1(\u_comps.u_mult.DATAB_R [8]),
	.C1(\u_comps.u_mult.DATAB_R [9]),
	.D1(\u_comps.u_mult.DATAA_R [8]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_7 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_9 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [16]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [17])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_8_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_8_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_8_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_8_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_6_0  (
	.A0(\u_comps.u_mult.DATAA_R [9]),
	.B0(\u_comps.u_mult.DATAB_R [5]),
	.C0(\u_comps.u_mult.DATAB_R [6]),
	.D0(\u_comps.u_mult.DATAA_R [8]),
	.A1(\u_comps.u_mult.DATAA_R [9]),
	.B1(\u_comps.u_mult.DATAB_R [6]),
	.C1(\u_comps.u_mult.DATAB_R [7]),
	.D1(\u_comps.u_mult.DATAA_R [8]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_5 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_7 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [14]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [15])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_6_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_6_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_6_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_6_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_4_0  (
	.A0(\u_comps.u_mult.DATAA_R [9]),
	.B0(\u_comps.u_mult.DATAB_R [3]),
	.C0(\u_comps.u_mult.DATAB_R [4]),
	.D0(\u_comps.u_mult.DATAA_R [8]),
	.A1(\u_comps.u_mult.DATAA_R [9]),
	.B1(\u_comps.u_mult.DATAB_R [4]),
	.C1(\u_comps.u_mult.DATAB_R [5]),
	.D1(\u_comps.u_mult.DATAA_R [8]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_3 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_5 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [12]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [13])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_4_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_4_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_4_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_4_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_2_0  (
	.A0(\u_comps.u_mult.DATAA_R [9]),
	.B0(\u_comps.u_mult.DATAB_R [1]),
	.C0(\u_comps.u_mult.DATAB_R [2]),
	.D0(\u_comps.u_mult.DATAA_R [8]),
	.A1(\u_comps.u_mult.DATAA_R [9]),
	.B1(\u_comps.u_mult.DATAB_R [2]),
	.C1(\u_comps.u_mult.DATAB_R [3]),
	.D1(\u_comps.u_mult.DATAA_R [8]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_1 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_3 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [10]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [11])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_2_0 .INIT0=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_2_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_2_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_1_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [9]),
	.B1(\u_comps.u_mult.DATAB_R [0]),
	.C1(\u_comps.u_mult.DATAB_R [1]),
	.D1(\u_comps.u_mult.DATAA_R [8]),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_4_cry_1 ),
	.S0(N_3408),
	.S1(N_2589)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_1_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_1_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_4_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_18_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_18_cry ),
	.COUT(N_3405),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [23]),
	.S1(N_3406)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_18_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_18_0 .INIT1=16'h0000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_18_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_18_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_17_0  (
	.A0(\u_comps.u_mult.DATAB_R [6]),
	.B0(\u_comps.u_mult.DATAA_R [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAB_R [7]),
	.B1(\u_comps.u_mult.DATAA_R [15]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_16 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_18_cry ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [21]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [22])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_17_0 .INIT0=16'h4000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_17_0 .INIT1=16'h4000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_17_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_17_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_15_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [19]),
	.B0(\u_comps.u_mult.DATAB_R [4]),
	.C0(\u_comps.u_mult.DATAA_R [15]),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [20]),
	.B1(\u_comps.u_mult.DATAB_R [5]),
	.C1(\u_comps.u_mult.DATAA_R [15]),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_14 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_16 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [19]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [20])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_15_0 .INIT0=16'h9a0a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_15_0 .INIT1=16'h9a0a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_15_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_13_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [17]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [18]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_12 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_14 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [17]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [18])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_13_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_13_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_13_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_11_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_6 [15]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_5 [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_6 [16]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_10 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_12 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [15]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [16])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_11_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_11_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_11_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_9_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_4 [13]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_5 [14]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_8 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_10 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [13]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [14])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_9_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_9_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_9_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_7_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_3 [11]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_2 [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_4 [12]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_6 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_8 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [11]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_13_scalar )
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_7_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_7_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_7_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_5_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [9]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_3 [10]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_4 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_6 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [9]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [10])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_5_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_5_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_5_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_3_0  (
	.A0(\u_comps.u_mult.PRODUCT_R_2.madd_1 [7]),
	.B0(\u_comps.u_mult.PRODUCT_R_2.madd_0 [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_2 [8]),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_2 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_4 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_9 [7]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_9 [8])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_3_0 .INIT0=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_3_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_3_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_2_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.PRODUCT_R_2.madd_9_scalar ),
	.B1(\u_comps.u_mult.PRODUCT_R_2.madd_0 [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_9_cry_2 ),
	.S0(N_3387),
	.S1(N_2559)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_2_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_2_0 .INIT1=16'h600a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_9_cry_2_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_7_s_16_0  (
	.A0(\u_comps.u_mult.DATAA_R [15]),
	.B0(\u_comps.u_mult.DATAB_R [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_15 ),
	.COUT(N_3384),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [30]),
	.S1(N_3383)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_s_16_0 .INIT0=16'h800a;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_s_16_0 .INIT1=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_s_16_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_s_16_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_14_0  (
	.A0(\u_comps.u_mult.DATAA_R [14]),
	.B0(\u_comps.u_mult.DATAB_R [14]),
	.C0(\u_comps.u_mult.DATAB_R [15]),
	.D0(\u_comps.u_mult.DATAA_R [13]),
	.A1(\u_comps.u_mult.DATAB_R [15]),
	.B1(\u_comps.u_mult.DATAA_R [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_13 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_15 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [28]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [29])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_14_0 .INIT0=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_14_0 .INIT1=16'h2000;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_14_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_14_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_12_0  (
	.A0(\u_comps.u_mult.DATAA_R [14]),
	.B0(\u_comps.u_mult.DATAB_R [12]),
	.C0(\u_comps.u_mult.DATAB_R [15]),
	.D0(\u_comps.u_mult.DATAA_R [11]),
	.A1(\u_comps.u_mult.DATAA_R [14]),
	.B1(\u_comps.u_mult.DATAB_R [13]),
	.C1(\u_comps.u_mult.DATAB_R [15]),
	.D1(\u_comps.u_mult.DATAA_R [12]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_11 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_13 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [26]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [27])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_12_0 .INIT0=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_12_0 .INIT1=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_12_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_12_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_10_0  (
	.A0(\u_comps.u_mult.DATAA_R [14]),
	.B0(\u_comps.u_mult.DATAB_R [10]),
	.C0(\u_comps.u_mult.DATAB_R [15]),
	.D0(\u_comps.u_mult.DATAA_R [9]),
	.A1(\u_comps.u_mult.DATAA_R [14]),
	.B1(\u_comps.u_mult.DATAB_R [11]),
	.C1(\u_comps.u_mult.DATAB_R [15]),
	.D1(\u_comps.u_mult.DATAA_R [10]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_9 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_11 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [24]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [25])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_10_0 .INIT0=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_10_0 .INIT1=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_10_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_10_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_8_0  (
	.A0(\u_comps.u_mult.DATAA_R [14]),
	.B0(\u_comps.u_mult.DATAB_R [8]),
	.C0(\u_comps.u_mult.DATAB_R [15]),
	.D0(\u_comps.u_mult.DATAA_R [7]),
	.A1(\u_comps.u_mult.DATAA_R [14]),
	.B1(\u_comps.u_mult.DATAB_R [9]),
	.C1(\u_comps.u_mult.DATAB_R [15]),
	.D1(\u_comps.u_mult.DATAA_R [8]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_7 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_9 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [22]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [23])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_8_0 .INIT0=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_8_0 .INIT1=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_8_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_8_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_6_0  (
	.A0(\u_comps.u_mult.DATAA_R [14]),
	.B0(\u_comps.u_mult.DATAB_R [6]),
	.C0(\u_comps.u_mult.DATAB_R [15]),
	.D0(\u_comps.u_mult.DATAA_R [5]),
	.A1(\u_comps.u_mult.DATAA_R [14]),
	.B1(\u_comps.u_mult.DATAB_R [7]),
	.C1(\u_comps.u_mult.DATAB_R [15]),
	.D1(\u_comps.u_mult.DATAA_R [6]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_5 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_7 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [20]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [21])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_6_0 .INIT0=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_6_0 .INIT1=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_6_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_6_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_4_0  (
	.A0(\u_comps.u_mult.DATAA_R [14]),
	.B0(\u_comps.u_mult.DATAB_R [4]),
	.C0(\u_comps.u_mult.DATAB_R [15]),
	.D0(\u_comps.u_mult.DATAA_R [3]),
	.A1(\u_comps.u_mult.DATAA_R [14]),
	.B1(\u_comps.u_mult.DATAB_R [5]),
	.C1(\u_comps.u_mult.DATAB_R [15]),
	.D1(\u_comps.u_mult.DATAA_R [4]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_3 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_5 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [18]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [19])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_4_0 .INIT0=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_4_0 .INIT1=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_4_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_4_0 .INJECT1_1="NO";
// @10:128
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_2_0  (
	.A0(\u_comps.u_mult.DATAA_R [1]),
	.B0(\u_comps.u_mult.DATAB_R [15]),
	.C0(\u_comps.u_mult.DATAA_R [0]),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [14]),
	.B1(\u_comps.u_mult.DATAB_R [3]),
	.C1(\u_comps.u_mult.DATAB_R [15]),
	.D1(\u_comps.u_mult.DATAA_R [2]),
	.CIN(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_1 ),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_3 ),
	.S0(\u_comps.u_mult.PRODUCT_R_2.madd_7 [16]),
	.S1(\u_comps.u_mult.PRODUCT_R_2.madd_7 [17])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_2_0 .INIT0=16'h4804;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_2_0 .INIT1=16'h8878;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_2_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_2_0 .INJECT1_1="NO";
  CCU2C \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_1_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.u_mult.DATAA_R [0]),
	.B1(\u_comps.u_mult.DATAB_R [15]),
	.C1(\u_comps.u_mult.DATAB_R [1]),
	.D1(\u_comps.u_mult.DATAA_R [14]),
	.CIN(),
	.COUT(\u_comps.u_mult.PRODUCT_R_2.madd_7_cry_1 ),
	.S0(N_3368),
	.S1(N_2542)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_1_0 .INIT0=16'h5003;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_1_0 .INIT1=16'h7888;
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.u_mult.PRODUCT_R_2.madd_7_cry_1_0 .INJECT1_1="NO";
// @8:83
  CCU2C \u_dcc.prevo_256_3_cry_15_0  (
	.A0(\u_dcc.prevo [22]),
	.B0(\u_dcc.prevo [23]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.prevo_256_3_cry_14 ),
	.COUT(N_3365),
	.S0(\u_dcc.prevo_256_3 [15]),
	.S1(\u_dcc.prevo_256_3 [16])
);
defparam \u_dcc.prevo_256_3_cry_15_0 .INIT0=16'h600a;
defparam \u_dcc.prevo_256_3_cry_15_0 .INIT1=16'h5003;
defparam \u_dcc.prevo_256_3_cry_15_0 .INJECT1_0="NO";
defparam \u_dcc.prevo_256_3_cry_15_0 .INJECT1_1="NO";
// @8:83
  CCU2C \u_dcc.prevo_256_3_cry_13_0  (
	.A0(\u_dcc.prevo [20]),
	.B0(\u_dcc.prevo [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [21]),
	.B1(\u_dcc.prevo [22]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.prevo_256_3_cry_12 ),
	.COUT(\u_dcc.prevo_256_3_cry_14 ),
	.S0(\u_dcc.prevo_256_3 [13]),
	.S1(\u_dcc.prevo_256_3 [14])
);
defparam \u_dcc.prevo_256_3_cry_13_0 .INIT0=16'h600a;
defparam \u_dcc.prevo_256_3_cry_13_0 .INIT1=16'h600a;
defparam \u_dcc.prevo_256_3_cry_13_0 .INJECT1_0="NO";
defparam \u_dcc.prevo_256_3_cry_13_0 .INJECT1_1="NO";
// @8:83
  CCU2C \u_dcc.prevo_256_3_cry_11_0  (
	.A0(\u_dcc.prevo [18]),
	.B0(\u_dcc.prevo [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [19]),
	.B1(\u_dcc.prevo [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.prevo_256_3_cry_10 ),
	.COUT(\u_dcc.prevo_256_3_cry_12 ),
	.S0(\u_dcc.prevo_256_3 [11]),
	.S1(\u_dcc.prevo_256_3 [12])
);
defparam \u_dcc.prevo_256_3_cry_11_0 .INIT0=16'h600a;
defparam \u_dcc.prevo_256_3_cry_11_0 .INIT1=16'h600a;
defparam \u_dcc.prevo_256_3_cry_11_0 .INJECT1_0="NO";
defparam \u_dcc.prevo_256_3_cry_11_0 .INJECT1_1="NO";
// @8:83
  CCU2C \u_dcc.prevo_256_3_cry_9_0  (
	.A0(\u_dcc.prevo [16]),
	.B0(\u_dcc.prevo [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [17]),
	.B1(\u_dcc.prevo [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.prevo_256_3_cry_8 ),
	.COUT(\u_dcc.prevo_256_3_cry_10 ),
	.S0(\u_dcc.prevo_256_3 [9]),
	.S1(\u_dcc.prevo_256_3 [10])
);
defparam \u_dcc.prevo_256_3_cry_9_0 .INIT0=16'h600a;
defparam \u_dcc.prevo_256_3_cry_9_0 .INIT1=16'h600a;
defparam \u_dcc.prevo_256_3_cry_9_0 .INJECT1_0="NO";
defparam \u_dcc.prevo_256_3_cry_9_0 .INJECT1_1="NO";
// @8:83
  CCU2C \u_dcc.prevo_256_3_cry_7_0  (
	.A0(\u_dcc.prevo [14]),
	.B0(\u_dcc.prevo [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [15]),
	.B1(\u_dcc.prevo [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.prevo_256_3_cry_6 ),
	.COUT(\u_dcc.prevo_256_3_cry_8 ),
	.S0(\u_dcc.prevo_256_3 [7]),
	.S1(\u_dcc.prevo_256_3 [8])
);
defparam \u_dcc.prevo_256_3_cry_7_0 .INIT0=16'h600a;
defparam \u_dcc.prevo_256_3_cry_7_0 .INIT1=16'h600a;
defparam \u_dcc.prevo_256_3_cry_7_0 .INJECT1_0="NO";
defparam \u_dcc.prevo_256_3_cry_7_0 .INJECT1_1="NO";
// @8:83
  CCU2C \u_dcc.prevo_256_3_cry_5_0  (
	.A0(\u_dcc.prevo [12]),
	.B0(\u_dcc.prevo [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [13]),
	.B1(\u_dcc.prevo [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.prevo_256_3_cry_4 ),
	.COUT(\u_dcc.prevo_256_3_cry_6 ),
	.S0(\u_dcc.prevo_256_3 [5]),
	.S1(\u_dcc.prevo_256_3 [6])
);
defparam \u_dcc.prevo_256_3_cry_5_0 .INIT0=16'h600a;
defparam \u_dcc.prevo_256_3_cry_5_0 .INIT1=16'h600a;
defparam \u_dcc.prevo_256_3_cry_5_0 .INJECT1_0="NO";
defparam \u_dcc.prevo_256_3_cry_5_0 .INJECT1_1="NO";
// @8:83
  CCU2C \u_dcc.prevo_256_3_cry_3_0  (
	.A0(\u_dcc.prevo [10]),
	.B0(\u_dcc.prevo [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [11]),
	.B1(\u_dcc.prevo [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.prevo_256_3_cry_2 ),
	.COUT(\u_dcc.prevo_256_3_cry_4 ),
	.S0(\u_dcc.prevo_256_3 [3]),
	.S1(\u_dcc.prevo_256_3 [4])
);
defparam \u_dcc.prevo_256_3_cry_3_0 .INIT0=16'h600a;
defparam \u_dcc.prevo_256_3_cry_3_0 .INIT1=16'h600a;
defparam \u_dcc.prevo_256_3_cry_3_0 .INJECT1_0="NO";
defparam \u_dcc.prevo_256_3_cry_3_0 .INJECT1_1="NO";
// @8:83
  CCU2C \u_dcc.prevo_256_3_cry_1_0  (
	.A0(\u_dcc.prevo [8]),
	.B0(\u_dcc.prevo [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [9]),
	.B1(\u_dcc.prevo [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.prevo_256_3_cry_0 ),
	.COUT(\u_dcc.prevo_256_3_cry_2 ),
	.S0(\u_dcc.prevo_256_3 [1]),
	.S1(\u_dcc.prevo_256_3 [2])
);
defparam \u_dcc.prevo_256_3_cry_1_0 .INIT0=16'h600a;
defparam \u_dcc.prevo_256_3_cry_1_0 .INIT1=16'h600a;
defparam \u_dcc.prevo_256_3_cry_1_0 .INJECT1_0="NO";
defparam \u_dcc.prevo_256_3_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_dcc.prevo_256_3_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [7]),
	.B1(\u_dcc.prevo [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_dcc.prevo_256_3_cry_0 ),
	.S0(N_3349),
	.S1(N_2513)
);
defparam \u_dcc.prevo_256_3_cry_0_0 .INIT0=16'h5003;
defparam \u_dcc.prevo_256_3_cry_0_0 .INIT1=16'h600a;
defparam \u_dcc.prevo_256_3_cry_0_0 .INJECT1_0="NO";
defparam \u_dcc.prevo_256_3_cry_0_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_s_23_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_22 ),
	.COUT(N_3346),
	.S0(N_1516),
	.S1(N_3345)
);
defparam \u_dcc.un1_subo_s_23_0 .INIT0=16'ha003;
defparam \u_dcc.un1_subo_s_23_0 .INIT1=16'h5003;
defparam \u_dcc.un1_subo_s_23_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_s_23_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_21_0  (
	.A0(\u_dcc.prevo [23]),
	.B0(\u_dcc.prevo [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [23]),
	.B1(\u_dcc.prevo [22]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_20 ),
	.COUT(\u_dcc.un1_subo_cry_22 ),
	.S0(N_1514),
	.S1(N_1515)
);
defparam \u_dcc.un1_subo_cry_21_0 .INIT0=16'h9005;
defparam \u_dcc.un1_subo_cry_21_0 .INIT1=16'h9005;
defparam \u_dcc.un1_subo_cry_21_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_21_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_19_0  (
	.A0(\u_dcc.prevo [23]),
	.B0(\u_dcc.prevo [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [23]),
	.B1(\u_dcc.prevo [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_18 ),
	.COUT(\u_dcc.un1_subo_cry_20 ),
	.S0(N_1512),
	.S1(N_1513)
);
defparam \u_dcc.un1_subo_cry_19_0 .INIT0=16'h9005;
defparam \u_dcc.un1_subo_cry_19_0 .INIT1=16'h9005;
defparam \u_dcc.un1_subo_cry_19_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_19_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_17_0  (
	.A0(\u_dcc.prevo [23]),
	.B0(\u_dcc.prevo [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [23]),
	.B1(\u_dcc.prevo [18]),
	.C1(\u_dcc.prevo [23]),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_16 ),
	.COUT(\u_dcc.un1_subo_cry_18 ),
	.S0(N_1510),
	.S1(N_1511)
);
defparam \u_dcc.un1_subo_cry_17_0 .INIT0=16'h9005;
defparam \u_dcc.un1_subo_cry_17_0 .INIT1=16'hc305;
defparam \u_dcc.un1_subo_cry_17_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_17_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_15_0  (
	.A0(\u_dcc.prevo [15]),
	.B0(\u_dcc.prevo_256_3 [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [16]),
	.B1(\u_dcc.prevo_256_3 [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_14 ),
	.COUT(\u_dcc.un1_subo_cry_16 ),
	.S0(N_1508),
	.S1(N_1509)
);
defparam \u_dcc.un1_subo_cry_15_0 .INIT0=16'h900a;
defparam \u_dcc.un1_subo_cry_15_0 .INIT1=16'h900a;
defparam \u_dcc.un1_subo_cry_15_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_15_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_13_0  (
	.A0(\u_dcc.prevo [13]),
	.B0(\u_dcc.prevo_256_3 [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [14]),
	.B1(\u_dcc.prevo_256_3 [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_12 ),
	.COUT(\u_dcc.un1_subo_cry_14 ),
	.S0(N_1506),
	.S1(N_1507)
);
defparam \u_dcc.un1_subo_cry_13_0 .INIT0=16'h900a;
defparam \u_dcc.un1_subo_cry_13_0 .INIT1=16'h900a;
defparam \u_dcc.un1_subo_cry_13_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_13_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_11_0  (
	.A0(\u_dcc.prevo [11]),
	.B0(\u_dcc.prevo_256_3 [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [12]),
	.B1(\u_dcc.prevo_256_3 [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_10 ),
	.COUT(\u_dcc.un1_subo_cry_12 ),
	.S0(N_1504),
	.S1(N_1505)
);
defparam \u_dcc.un1_subo_cry_11_0 .INIT0=16'h900a;
defparam \u_dcc.un1_subo_cry_11_0 .INIT1=16'h900a;
defparam \u_dcc.un1_subo_cry_11_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_11_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_9_0  (
	.A0(\u_dcc.prevo [9]),
	.B0(\u_dcc.prevo_256_3 [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [10]),
	.B1(\u_dcc.prevo_256_3 [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_8 ),
	.COUT(\u_dcc.un1_subo_cry_10 ),
	.S0(N_1502),
	.S1(N_1503)
);
defparam \u_dcc.un1_subo_cry_9_0 .INIT0=16'h900a;
defparam \u_dcc.un1_subo_cry_9_0 .INIT1=16'h900a;
defparam \u_dcc.un1_subo_cry_9_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_9_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_7_0  (
	.A0(\u_dcc.prevo [7]),
	.B0(\u_dcc.prevo_256_3 [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [8]),
	.B1(\u_dcc.prevo_256_3 [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_6 ),
	.COUT(\u_dcc.un1_subo_cry_8 ),
	.S0(N_1500),
	.S1(N_1501)
);
defparam \u_dcc.un1_subo_cry_7_0 .INIT0=16'h900a;
defparam \u_dcc.un1_subo_cry_7_0 .INIT1=16'h900a;
defparam \u_dcc.un1_subo_cry_7_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_7_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_5_0  (
	.A0(\u_dcc.prevo [5]),
	.B0(\u_dcc.prevo_256_3 [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [6]),
	.B1(\u_dcc.prevo_256_3 [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_4 ),
	.COUT(\u_dcc.un1_subo_cry_6 ),
	.S0(N_1498),
	.S1(N_1499)
);
defparam \u_dcc.un1_subo_cry_5_0 .INIT0=16'h900a;
defparam \u_dcc.un1_subo_cry_5_0 .INIT1=16'h900a;
defparam \u_dcc.un1_subo_cry_5_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_5_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_3_0  (
	.A0(\u_dcc.prevo [3]),
	.B0(\u_dcc.prevo_256_3 [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [4]),
	.B1(\u_dcc.prevo_256_3 [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_2 ),
	.COUT(\u_dcc.un1_subo_cry_4 ),
	.S0(N_1496),
	.S1(N_1497)
);
defparam \u_dcc.un1_subo_cry_3_0 .INIT0=16'h900a;
defparam \u_dcc.un1_subo_cry_3_0 .INIT1=16'h900a;
defparam \u_dcc.un1_subo_cry_3_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_3_0 .INJECT1_1="NO";
// @8:92
  CCU2C \u_dcc.un1_subo_cry_1_0  (
	.A0(\u_dcc.prevo [1]),
	.B0(\u_dcc.prevo_256_3 [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [2]),
	.B1(\u_dcc.prevo_256_3 [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_subo_cry_0 ),
	.COUT(\u_dcc.un1_subo_cry_2 ),
	.S0(N_1494),
	.S1(N_1495)
);
defparam \u_dcc.un1_subo_cry_1_0 .INIT0=16'h900a;
defparam \u_dcc.un1_subo_cry_1_0 .INIT1=16'h900a;
defparam \u_dcc.un1_subo_cry_1_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_dcc.un1_subo_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.prevo [0]),
	.B1(\u_dcc.prevo [8]),
	.C1(\u_dcc.prevo [7]),
	.D1(VCC),
	.CIN(),
	.COUT(\u_dcc.un1_subo_cry_0 ),
	.S0(N_3321),
	.S1(N_3322)
);
defparam \u_dcc.un1_subo_cry_0_0 .INIT0=16'h500c;
defparam \u_dcc.un1_subo_cry_0_0 .INIT1=16'h690a;
defparam \u_dcc.un1_subo_cry_0_0 .INJECT1_0="NO";
defparam \u_dcc.un1_subo_cry_0_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_23_0  (
	.A0(\u_dcc.previ [23]),
	.B0(dec_data[23]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.previ [23]),
	.B1(dec_data[23]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_22 ),
	.COUT(N_3318),
	.S0(N_1540),
	.S1(N_1541)
);
defparam \u_dcc.un2_subi_cry_23_0 .INIT0=16'h9005;
defparam \u_dcc.un2_subi_cry_23_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_23_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_23_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_21_0  (
	.A0(dec_data[21]),
	.B0(\u_dcc.previ [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[22]),
	.B1(\u_dcc.previ [22]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_20 ),
	.COUT(\u_dcc.un2_subi_cry_22 ),
	.S0(N_1538),
	.S1(N_1539)
);
defparam \u_dcc.un2_subi_cry_21_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_21_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_21_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_21_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_19_0  (
	.A0(dec_data[19]),
	.B0(\u_dcc.previ [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[20]),
	.B1(\u_dcc.previ [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_18 ),
	.COUT(\u_dcc.un2_subi_cry_20 ),
	.S0(N_1536),
	.S1(N_1537)
);
defparam \u_dcc.un2_subi_cry_19_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_19_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_19_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_19_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_17_0  (
	.A0(dec_data[17]),
	.B0(\u_dcc.previ [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[18]),
	.B1(\u_dcc.previ [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_16 ),
	.COUT(\u_dcc.un2_subi_cry_18 ),
	.S0(N_1534),
	.S1(N_1535)
);
defparam \u_dcc.un2_subi_cry_17_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_17_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_17_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_17_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_15_0  (
	.A0(dec_data[15]),
	.B0(\u_dcc.previ [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[16]),
	.B1(\u_dcc.previ [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_14 ),
	.COUT(\u_dcc.un2_subi_cry_16 ),
	.S0(N_1532),
	.S1(N_1533)
);
defparam \u_dcc.un2_subi_cry_15_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_15_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_15_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_15_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_13_0  (
	.A0(dec_data[13]),
	.B0(\u_dcc.previ [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[14]),
	.B1(\u_dcc.previ [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_12 ),
	.COUT(\u_dcc.un2_subi_cry_14 ),
	.S0(N_1530),
	.S1(N_1531)
);
defparam \u_dcc.un2_subi_cry_13_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_13_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_13_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_13_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_11_0  (
	.A0(dec_data[11]),
	.B0(\u_dcc.previ [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[12]),
	.B1(\u_dcc.previ [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_10 ),
	.COUT(\u_dcc.un2_subi_cry_12 ),
	.S0(N_1528),
	.S1(N_1529)
);
defparam \u_dcc.un2_subi_cry_11_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_11_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_11_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_11_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_9_0  (
	.A0(dec_data[9]),
	.B0(\u_dcc.previ [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[10]),
	.B1(\u_dcc.previ [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_8 ),
	.COUT(\u_dcc.un2_subi_cry_10 ),
	.S0(N_1526),
	.S1(N_1527)
);
defparam \u_dcc.un2_subi_cry_9_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_9_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_9_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_9_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_7_0  (
	.A0(dec_data[7]),
	.B0(\u_dcc.previ [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[8]),
	.B1(\u_dcc.previ [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_6 ),
	.COUT(\u_dcc.un2_subi_cry_8 ),
	.S0(N_1524),
	.S1(N_1525)
);
defparam \u_dcc.un2_subi_cry_7_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_7_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_7_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_7_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_5_0  (
	.A0(dec_data[5]),
	.B0(\u_dcc.previ [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[6]),
	.B1(\u_dcc.previ [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_4 ),
	.COUT(\u_dcc.un2_subi_cry_6 ),
	.S0(N_1522),
	.S1(N_1523)
);
defparam \u_dcc.un2_subi_cry_5_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_5_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_5_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_5_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_3_0  (
	.A0(dec_data[3]),
	.B0(\u_dcc.previ [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[4]),
	.B1(\u_dcc.previ [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_2 ),
	.COUT(\u_dcc.un2_subi_cry_4 ),
	.S0(N_1520),
	.S1(N_1521)
);
defparam \u_dcc.un2_subi_cry_3_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_3_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_3_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_3_0 .INJECT1_1="NO";
// @8:70
  CCU2C \u_dcc.un2_subi_cry_1_0  (
	.A0(dec_data[1]),
	.B0(\u_dcc.previ [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[2]),
	.B1(\u_dcc.previ [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un2_subi_cry_0 ),
	.COUT(\u_dcc.un2_subi_cry_2 ),
	.S0(N_1518),
	.S1(N_1519)
);
defparam \u_dcc.un2_subi_cry_1_0 .INIT0=16'h900a;
defparam \u_dcc.un2_subi_cry_1_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_1_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_dcc.un2_subi_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(dec_data[0]),
	.B1(\u_dcc.previ [0]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_dcc.un2_subi_cry_0 ),
	.S0(N_3293),
	.S1(N_3294)
);
defparam \u_dcc.un2_subi_cry_0_0 .INIT0=16'h500c;
defparam \u_dcc.un2_subi_cry_0_0 .INIT1=16'h900a;
defparam \u_dcc.un2_subi_cry_0_0 .INJECT1_0="NO";
defparam \u_dcc.un2_subi_cry_0_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_s_27_0  (
	.A0(\u_comps.mac_T [27]),
	.B0(\u_comps.mac_B [31]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_26 ),
	.COUT(N_3289),
	.S0(\u_comps.mac_sum [27]),
	.S1(N_3288)
);
defparam \u_comps.mac_sum_s_27_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_s_27_0 .INIT1=16'h5003;
defparam \u_comps.mac_sum_s_27_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_s_27_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_25_0  (
	.A0(\u_comps.mac_T [25]),
	.B0(\u_comps.mac_B [31]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [26]),
	.B1(\u_comps.mac_B [31]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_24 ),
	.COUT(\u_comps.mac_sum_cry_26 ),
	.S0(\u_comps.mac_sum [25]),
	.S1(\u_comps.mac_sum [26])
);
defparam \u_comps.mac_sum_cry_25_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_25_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_25_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_25_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_23_0  (
	.A0(\u_comps.mac_T [23]),
	.B0(\u_comps.mac_B [31]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [24]),
	.B1(\u_comps.mac_B [31]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_22 ),
	.COUT(\u_comps.mac_sum_cry_24 ),
	.S0(\u_comps.mac_sum [23]),
	.S1(\u_comps.mac_sum [24])
);
defparam \u_comps.mac_sum_cry_23_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_23_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_23_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_23_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_21_0  (
	.A0(\u_comps.mac_T [21]),
	.B0(\u_comps.mac_B [31]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [22]),
	.B1(\u_comps.mac_B [31]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_20 ),
	.COUT(\u_comps.mac_sum_cry_22 ),
	.S0(\u_comps.mac_sum [21]),
	.S1(\u_comps.mac_sum [22])
);
defparam \u_comps.mac_sum_cry_21_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_21_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_21_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_21_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_19_0  (
	.A0(\u_comps.mac_T [19]),
	.B0(\u_comps.mac_B [29]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [20]),
	.B1(\u_comps.mac_B [30]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_18 ),
	.COUT(\u_comps.mac_sum_cry_20 ),
	.S0(\u_comps.mac_sum [19]),
	.S1(\u_comps.mac_sum [20])
);
defparam \u_comps.mac_sum_cry_19_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_19_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_19_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_19_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_17_0  (
	.A0(\u_comps.mac_T [17]),
	.B0(\u_comps.mac_B [27]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [18]),
	.B1(\u_comps.mac_B [28]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_16 ),
	.COUT(\u_comps.mac_sum_cry_18 ),
	.S0(\u_comps.mac_sum [17]),
	.S1(\u_comps.mac_sum [18])
);
defparam \u_comps.mac_sum_cry_17_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_17_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_17_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_17_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_15_0  (
	.A0(\u_comps.mac_T [15]),
	.B0(\u_comps.mac_B [25]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [16]),
	.B1(\u_comps.mac_B [26]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_14 ),
	.COUT(\u_comps.mac_sum_cry_16 ),
	.S0(\u_comps.mac_sum [15]),
	.S1(\u_comps.mac_sum [16])
);
defparam \u_comps.mac_sum_cry_15_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_15_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_15_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_13_0  (
	.A0(\u_comps.mac_T [13]),
	.B0(\u_comps.mac_B [23]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [14]),
	.B1(\u_comps.mac_B [24]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_12 ),
	.COUT(\u_comps.mac_sum_cry_14 ),
	.S0(\u_comps.mac_sum [13]),
	.S1(\u_comps.mac_sum [14])
);
defparam \u_comps.mac_sum_cry_13_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_13_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_13_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_11_0  (
	.A0(\u_comps.mac_T [11]),
	.B0(\u_comps.mac_B [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [12]),
	.B1(\u_comps.mac_B [22]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_10 ),
	.COUT(\u_comps.mac_sum_cry_12 ),
	.S0(\u_comps.mac_sum [11]),
	.S1(\u_comps.mac_sum [12])
);
defparam \u_comps.mac_sum_cry_11_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_11_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_11_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_9_0  (
	.A0(\u_comps.mac_T [9]),
	.B0(\u_comps.mac_B [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [10]),
	.B1(\u_comps.mac_B [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_8 ),
	.COUT(\u_comps.mac_sum_cry_10 ),
	.S0(\u_comps.mac_sum [9]),
	.S1(\u_comps.mac_sum [10])
);
defparam \u_comps.mac_sum_cry_9_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_9_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_9_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_7_0  (
	.A0(\u_comps.mac_T [7]),
	.B0(\u_comps.mac_B [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [8]),
	.B1(\u_comps.mac_B [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_6 ),
	.COUT(\u_comps.mac_sum_cry_8 ),
	.S0(\u_comps.mac_sum [7]),
	.S1(\u_comps.mac_sum [8])
);
defparam \u_comps.mac_sum_cry_7_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_7_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_7_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_5_0  (
	.A0(\u_comps.mac_T [5]),
	.B0(\u_comps.mac_B [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [6]),
	.B1(\u_comps.mac_B [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_4 ),
	.COUT(\u_comps.mac_sum_cry_6 ),
	.S0(\u_comps.mac_sum [5]),
	.S1(\u_comps.mac_sum [6])
);
defparam \u_comps.mac_sum_cry_5_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_5_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_5_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_3_0  (
	.A0(\u_comps.mac_T [3]),
	.B0(\u_comps.mac_B [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [4]),
	.B1(\u_comps.mac_B [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_2 ),
	.COUT(\u_comps.mac_sum_cry_4 ),
	.S0(\u_comps.mac_sum [3]),
	.S1(\u_comps.mac_sum [4])
);
defparam \u_comps.mac_sum_cry_3_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_3_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_3_0 .INJECT1_1="NO";
// @7:348
  CCU2C \u_comps.mac_sum_cry_1_0  (
	.A0(\u_comps.mac_T [1]),
	.B0(\u_comps.mac_B [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_T [2]),
	.B1(\u_comps.mac_B [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_sum_cry_0 ),
	.COUT(\u_comps.mac_sum_cry_2 ),
	.S0(N_3262),
	.S1(\u_comps.mac_sum [2])
);
defparam \u_comps.mac_sum_cry_1_0 .INIT0=16'h600a;
defparam \u_comps.mac_sum_cry_1_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.mac_sum_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_sum_scalar ),
	.B1(\u_comps.mac_B [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.mac_sum_cry_0 ),
	.S0(N_3261),
	.S1(N_2444)
);
defparam \u_comps.mac_sum_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.mac_sum_cry_0_0 .INIT1=16'h600a;
defparam \u_comps.mac_sum_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.mac_sum_cry_0_0 .INJECT1_1="NO";
// @7:177
  CCU2C \u_comps.un1_caddr_cry_3_0  (
	.A0(\u_comps.run_en ),
	.B0(\u_comps.run_even ),
	.C0(\u_comps.caddr [3]),
	.D0(VCC),
	.A1(\u_comps.caddr [4]),
	.B1(\u_comps.run_even ),
	.C1(\u_comps.run_en ),
	.D1(VCC),
	.CIN(\u_comps.un1_caddr_cry_2 ),
	.COUT(N_3259),
	.S0(\u_comps.un1_caddr [3]),
	.S1(\u_comps.un1_caddr [4])
);
defparam \u_comps.un1_caddr_cry_3_0 .INIT0=16'h7808;
defparam \u_comps.un1_caddr_cry_3_0 .INIT1=16'h6a0a;
defparam \u_comps.un1_caddr_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.un1_caddr_cry_3_0 .INJECT1_1="NO";
// @7:177
  CCU2C \u_comps.un1_caddr_cry_1_0  (
	.A0(\u_comps.run_en ),
	.B0(\u_comps.run_even ),
	.C0(\u_comps.caddr [1]),
	.D0(VCC),
	.A1(\u_comps.run_en ),
	.B1(\u_comps.run_even ),
	.C1(\u_comps.caddr [2]),
	.D1(VCC),
	.CIN(\u_comps.un1_caddr_cry_0 ),
	.COUT(\u_comps.un1_caddr_cry_2 ),
	.S0(\u_comps.un1_caddr [1]),
	.S1(\u_comps.un1_caddr [2])
);
defparam \u_comps.un1_caddr_cry_1_0 .INIT0=16'h7808;
defparam \u_comps.un1_caddr_cry_1_0 .INIT1=16'h7808;
defparam \u_comps.un1_caddr_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.un1_caddr_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.un1_caddr_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.run_en ),
	.B1(\u_comps.run_even ),
	.C1(\u_comps.caddr [0]),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.un1_caddr_cry_0 ),
	.S0(N_3255),
	.S1(N_2417)
);
defparam \u_comps.un1_caddr_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.un1_caddr_cry_0_0 .INIT1=16'h7808;
defparam \u_comps.un1_caddr_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.un1_caddr_cry_0_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_s_21_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [21]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_20 ),
	.COUT(N_3252),
	.S0(\u_cic.un13_dout_p [21]),
	.S1(N_3251)
);
defparam \u_cic.un13_dout_p_s_21_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_s_21_0 .INIT1=16'h5003;
defparam \u_cic.un13_dout_p_s_21_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_s_21_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_19_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [19]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [20]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_18 ),
	.COUT(\u_cic.un13_dout_p_cry_20 ),
	.S0(\u_cic.un13_dout_p [19]),
	.S1(\u_cic.un13_dout_p [20])
);
defparam \u_cic.un13_dout_p_cry_19_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_19_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_19_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_19_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_17_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [17]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [18]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_16 ),
	.COUT(\u_cic.un13_dout_p_cry_18 ),
	.S0(\u_cic.un13_dout_p [17]),
	.S1(\u_cic.un13_dout_p [18])
);
defparam \u_cic.un13_dout_p_cry_17_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_17_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_17_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_17_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_15_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [15]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [16]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_14 ),
	.COUT(\u_cic.un13_dout_p_cry_16 ),
	.S0(\u_cic.un13_dout_p [15]),
	.S1(\u_cic.un13_dout_p [16])
);
defparam \u_cic.un13_dout_p_cry_15_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_15_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_15_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_15_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_13_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [13]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [14]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_12 ),
	.COUT(\u_cic.un13_dout_p_cry_14 ),
	.S0(\u_cic.un13_dout_p [13]),
	.S1(\u_cic.un13_dout_p [14])
);
defparam \u_cic.un13_dout_p_cry_13_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_13_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_13_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_13_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_11_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [11]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [12]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_10 ),
	.COUT(\u_cic.un13_dout_p_cry_12 ),
	.S0(\u_cic.un13_dout_p [11]),
	.S1(\u_cic.un13_dout_p [12])
);
defparam \u_cic.un13_dout_p_cry_11_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_11_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_11_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_11_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_9_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [9]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [10]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_8 ),
	.COUT(\u_cic.un13_dout_p_cry_10 ),
	.S0(\u_cic.un13_dout_p [9]),
	.S1(\u_cic.un13_dout_p [10])
);
defparam \u_cic.un13_dout_p_cry_9_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_9_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_9_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_9_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_7_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [7]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [8]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_6 ),
	.COUT(\u_cic.un13_dout_p_cry_8 ),
	.S0(\u_cic.un13_dout_p [7]),
	.S1(\u_cic.un13_dout_p [8])
);
defparam \u_cic.un13_dout_p_cry_7_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_7_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_7_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_7_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_5_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [5]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [6]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_4 ),
	.COUT(\u_cic.un13_dout_p_cry_6 ),
	.S0(\u_cic.un13_dout_p [5]),
	.S1(\u_cic.un13_dout_p [6])
);
defparam \u_cic.un13_dout_p_cry_5_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_5_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_5_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_5_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_3_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [3]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [4]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_2 ),
	.COUT(\u_cic.un13_dout_p_cry_4 ),
	.S0(\u_cic.un13_dout_p [3]),
	.S1(\u_cic.un13_dout_p [4])
);
defparam \u_cic.un13_dout_p_cry_3_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_3_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_3_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_3_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un13_dout_p_cry_1_0  (
	.A0(\u_cic.PP.PL[2].dout_p[2] [1]),
	.B0(\u_cic.PP.PL[3].dout_r[3] [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[2].dout_p[2] [2]),
	.B1(\u_cic.PP.PL[3].dout_r[3] [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un13_dout_p_cry_0 ),
	.COUT(\u_cic.un13_dout_p_cry_2 ),
	.S0(\u_cic.un13_dout_p [1]),
	.S1(\u_cic.un13_dout_p [2])
);
defparam \u_cic.un13_dout_p_cry_1_0 .INIT0=16'h900a;
defparam \u_cic.un13_dout_p_cry_1_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_1_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_cic.un13_dout_p_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.un13_dout_p_scalar ),
	.B1(\u_cic.PP.PL[3].dout_r[3] [0]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_cic.un13_dout_p_cry_0 ),
	.S0(N_3229),
	.S1(N_3230)
);
defparam \u_cic.un13_dout_p_cry_0_0 .INIT0=16'h500c;
defparam \u_cic.un13_dout_p_cry_0_0 .INIT1=16'h900a;
defparam \u_cic.un13_dout_p_cry_0_0 .INJECT1_0="NO";
defparam \u_cic.un13_dout_p_cry_0_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_s_21_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [21]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_20 ),
	.COUT(N_3225),
	.S0(\u_cic.un9_dout_p [21]),
	.S1(N_3224)
);
defparam \u_cic.un9_dout_p_s_21_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_s_21_0 .INIT1=16'h5003;
defparam \u_cic.un9_dout_p_s_21_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_s_21_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_19_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [19]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [20]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_18 ),
	.COUT(\u_cic.un9_dout_p_cry_20 ),
	.S0(\u_cic.un9_dout_p [19]),
	.S1(\u_cic.un9_dout_p [20])
);
defparam \u_cic.un9_dout_p_cry_19_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_19_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_19_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_19_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_17_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [17]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [18]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_16 ),
	.COUT(\u_cic.un9_dout_p_cry_18 ),
	.S0(\u_cic.un9_dout_p [17]),
	.S1(\u_cic.un9_dout_p [18])
);
defparam \u_cic.un9_dout_p_cry_17_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_17_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_17_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_17_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_15_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [15]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [16]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_14 ),
	.COUT(\u_cic.un9_dout_p_cry_16 ),
	.S0(\u_cic.un9_dout_p [15]),
	.S1(\u_cic.un9_dout_p [16])
);
defparam \u_cic.un9_dout_p_cry_15_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_15_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_15_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_15_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_13_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [13]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [14]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_12 ),
	.COUT(\u_cic.un9_dout_p_cry_14 ),
	.S0(\u_cic.un9_dout_p [13]),
	.S1(\u_cic.un9_dout_p [14])
);
defparam \u_cic.un9_dout_p_cry_13_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_13_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_13_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_13_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_11_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [11]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [12]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_10 ),
	.COUT(\u_cic.un9_dout_p_cry_12 ),
	.S0(\u_cic.un9_dout_p [11]),
	.S1(\u_cic.un9_dout_p [12])
);
defparam \u_cic.un9_dout_p_cry_11_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_11_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_11_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_11_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_9_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [9]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [10]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_8 ),
	.COUT(\u_cic.un9_dout_p_cry_10 ),
	.S0(\u_cic.un9_dout_p [9]),
	.S1(\u_cic.un9_dout_p [10])
);
defparam \u_cic.un9_dout_p_cry_9_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_9_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_9_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_9_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_7_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [7]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [8]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_6 ),
	.COUT(\u_cic.un9_dout_p_cry_8 ),
	.S0(\u_cic.un9_dout_p [7]),
	.S1(\u_cic.un9_dout_p [8])
);
defparam \u_cic.un9_dout_p_cry_7_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_7_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_7_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_7_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_5_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [5]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [6]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_4 ),
	.COUT(\u_cic.un9_dout_p_cry_6 ),
	.S0(\u_cic.un9_dout_p [5]),
	.S1(\u_cic.un9_dout_p [6])
);
defparam \u_cic.un9_dout_p_cry_5_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_5_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_5_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_5_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_3_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [3]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [4]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_2 ),
	.COUT(\u_cic.un9_dout_p_cry_4 ),
	.S0(\u_cic.un9_dout_p [3]),
	.S1(\u_cic.un9_dout_p [4])
);
defparam \u_cic.un9_dout_p_cry_3_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_3_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_3_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_3_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un9_dout_p_cry_1_0  (
	.A0(\u_cic.PP.PL[1].dout_p[1] [1]),
	.B0(\u_cic.PP.PL[2].dout_r[2] [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[1].dout_p[1] [2]),
	.B1(\u_cic.PP.PL[2].dout_r[2] [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un9_dout_p_cry_0 ),
	.COUT(\u_cic.un9_dout_p_cry_2 ),
	.S0(\u_cic.un9_dout_p [1]),
	.S1(\u_cic.un9_dout_p [2])
);
defparam \u_cic.un9_dout_p_cry_1_0 .INIT0=16'h900a;
defparam \u_cic.un9_dout_p_cry_1_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_1_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_cic.un9_dout_p_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.un9_dout_p_scalar ),
	.B1(\u_cic.PP.PL[2].dout_r[2] [0]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_cic.un9_dout_p_cry_0 ),
	.S0(N_3202),
	.S1(N_3203)
);
defparam \u_cic.un9_dout_p_cry_0_0 .INIT0=16'h500c;
defparam \u_cic.un9_dout_p_cry_0_0 .INIT1=16'h900a;
defparam \u_cic.un9_dout_p_cry_0_0 .INJECT1_0="NO";
defparam \u_cic.un9_dout_p_cry_0_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_s_21_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [21]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_20 ),
	.COUT(N_3198),
	.S0(\u_cic.un5_dout_p [21]),
	.S1(N_3197)
);
defparam \u_cic.un5_dout_p_s_21_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_s_21_0 .INIT1=16'h5003;
defparam \u_cic.un5_dout_p_s_21_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_s_21_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_19_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [19]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [20]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_18 ),
	.COUT(\u_cic.un5_dout_p_cry_20 ),
	.S0(\u_cic.un5_dout_p [19]),
	.S1(\u_cic.un5_dout_p [20])
);
defparam \u_cic.un5_dout_p_cry_19_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_19_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_19_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_19_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_17_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [17]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [18]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_16 ),
	.COUT(\u_cic.un5_dout_p_cry_18 ),
	.S0(\u_cic.un5_dout_p [17]),
	.S1(\u_cic.un5_dout_p [18])
);
defparam \u_cic.un5_dout_p_cry_17_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_17_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_17_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_17_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_15_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [15]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [16]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_14 ),
	.COUT(\u_cic.un5_dout_p_cry_16 ),
	.S0(\u_cic.un5_dout_p [15]),
	.S1(\u_cic.un5_dout_p [16])
);
defparam \u_cic.un5_dout_p_cry_15_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_15_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_15_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_15_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_13_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [13]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [14]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_12 ),
	.COUT(\u_cic.un5_dout_p_cry_14 ),
	.S0(\u_cic.un5_dout_p [13]),
	.S1(\u_cic.un5_dout_p [14])
);
defparam \u_cic.un5_dout_p_cry_13_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_13_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_13_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_13_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_11_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [11]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [12]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_10 ),
	.COUT(\u_cic.un5_dout_p_cry_12 ),
	.S0(\u_cic.un5_dout_p [11]),
	.S1(\u_cic.un5_dout_p [12])
);
defparam \u_cic.un5_dout_p_cry_11_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_11_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_11_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_11_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_9_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [9]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [10]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_8 ),
	.COUT(\u_cic.un5_dout_p_cry_10 ),
	.S0(\u_cic.un5_dout_p [9]),
	.S1(\u_cic.un5_dout_p [10])
);
defparam \u_cic.un5_dout_p_cry_9_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_9_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_9_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_9_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_7_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [7]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [8]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_6 ),
	.COUT(\u_cic.un5_dout_p_cry_8 ),
	.S0(\u_cic.un5_dout_p [7]),
	.S1(\u_cic.un5_dout_p [8])
);
defparam \u_cic.un5_dout_p_cry_7_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_7_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_7_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_7_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_5_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [5]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [6]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_4 ),
	.COUT(\u_cic.un5_dout_p_cry_6 ),
	.S0(\u_cic.un5_dout_p [5]),
	.S1(\u_cic.un5_dout_p [6])
);
defparam \u_cic.un5_dout_p_cry_5_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_5_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_5_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_5_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_3_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [3]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [4]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_2 ),
	.COUT(\u_cic.un5_dout_p_cry_4 ),
	.S0(\u_cic.un5_dout_p [3]),
	.S1(\u_cic.un5_dout_p [4])
);
defparam \u_cic.un5_dout_p_cry_3_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_3_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_3_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_3_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un5_dout_p_cry_1_0  (
	.A0(\u_cic.PP.PL[0].dout_p[0] [1]),
	.B0(\u_cic.PP.PL[1].dout_r[1] [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.PP.PL[0].dout_p[0] [2]),
	.B1(\u_cic.PP.PL[1].dout_r[1] [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_dout_p_cry_0 ),
	.COUT(\u_cic.un5_dout_p_cry_2 ),
	.S0(\u_cic.un5_dout_p [1]),
	.S1(\u_cic.un5_dout_p [2])
);
defparam \u_cic.un5_dout_p_cry_1_0 .INIT0=16'h900a;
defparam \u_cic.un5_dout_p_cry_1_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_1_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_cic.un5_dout_p_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.un5_dout_p_scalar ),
	.B1(\u_cic.PP.PL[1].dout_r[1] [0]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_cic.un5_dout_p_cry_0 ),
	.S0(N_3175),
	.S1(N_3176)
);
defparam \u_cic.un5_dout_p_cry_0_0 .INIT0=16'h500c;
defparam \u_cic.un5_dout_p_cry_0_0 .INIT1=16'h900a;
defparam \u_cic.un5_dout_p_cry_0_0 .INJECT1_0="NO";
defparam \u_cic.un5_dout_p_cry_0_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_s_21_0  (
	.A0(\u_cic.INTA[3].din_r[3] [21]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_20 ),
	.COUT(N_3171),
	.S0(\u_cic.un1_dout_p [21]),
	.S1(N_3170)
);
defparam \u_cic.un1_dout_p_s_21_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_s_21_0 .INIT1=16'h5003;
defparam \u_cic.un1_dout_p_s_21_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_s_21_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_19_0  (
	.A0(\u_cic.INTA[3].din_r[3] [19]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [20]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_18 ),
	.COUT(\u_cic.un1_dout_p_cry_20 ),
	.S0(\u_cic.un1_dout_p [19]),
	.S1(\u_cic.un1_dout_p [20])
);
defparam \u_cic.un1_dout_p_cry_19_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_19_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_19_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_19_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_17_0  (
	.A0(\u_cic.INTA[3].din_r[3] [17]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [18]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_16 ),
	.COUT(\u_cic.un1_dout_p_cry_18 ),
	.S0(\u_cic.un1_dout_p [17]),
	.S1(\u_cic.un1_dout_p [18])
);
defparam \u_cic.un1_dout_p_cry_17_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_17_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_17_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_17_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_15_0  (
	.A0(\u_cic.INTA[3].din_r[3] [15]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [16]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_14 ),
	.COUT(\u_cic.un1_dout_p_cry_16 ),
	.S0(\u_cic.un1_dout_p [15]),
	.S1(\u_cic.un1_dout_p [16])
);
defparam \u_cic.un1_dout_p_cry_15_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_15_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_15_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_15_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_13_0  (
	.A0(\u_cic.INTA[3].din_r[3] [13]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [14]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_12 ),
	.COUT(\u_cic.un1_dout_p_cry_14 ),
	.S0(\u_cic.un1_dout_p [13]),
	.S1(\u_cic.un1_dout_p [14])
);
defparam \u_cic.un1_dout_p_cry_13_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_13_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_13_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_13_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_11_0  (
	.A0(\u_cic.INTA[3].din_r[3] [11]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [12]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_10 ),
	.COUT(\u_cic.un1_dout_p_cry_12 ),
	.S0(\u_cic.un1_dout_p [11]),
	.S1(\u_cic.un1_dout_p [12])
);
defparam \u_cic.un1_dout_p_cry_11_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_11_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_11_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_11_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_9_0  (
	.A0(\u_cic.INTA[3].din_r[3] [9]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [10]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_8 ),
	.COUT(\u_cic.un1_dout_p_cry_10 ),
	.S0(\u_cic.un1_dout_p [9]),
	.S1(\u_cic.un1_dout_p [10])
);
defparam \u_cic.un1_dout_p_cry_9_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_9_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_9_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_9_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_7_0  (
	.A0(\u_cic.INTA[3].din_r[3] [7]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [8]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_6 ),
	.COUT(\u_cic.un1_dout_p_cry_8 ),
	.S0(\u_cic.un1_dout_p [7]),
	.S1(\u_cic.un1_dout_p [8])
);
defparam \u_cic.un1_dout_p_cry_7_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_7_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_7_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_7_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_5_0  (
	.A0(\u_cic.INTA[3].din_r[3] [5]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [6]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_4 ),
	.COUT(\u_cic.un1_dout_p_cry_6 ),
	.S0(\u_cic.un1_dout_p [5]),
	.S1(\u_cic.un1_dout_p [6])
);
defparam \u_cic.un1_dout_p_cry_5_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_5_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_5_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_5_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_3_0  (
	.A0(\u_cic.INTA[3].din_r[3] [3]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [4]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_2 ),
	.COUT(\u_cic.un1_dout_p_cry_4 ),
	.S0(\u_cic.un1_dout_p [3]),
	.S1(\u_cic.un1_dout_p [4])
);
defparam \u_cic.un1_dout_p_cry_3_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_3_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_3_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_3_0 .INJECT1_1="NO";
// @6:143
  CCU2C \u_cic.un1_dout_p_cry_1_0  (
	.A0(\u_cic.INTA[3].din_r[3] [1]),
	.B0(\u_cic.PP.PL[0].dout_r[0] [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [2]),
	.B1(\u_cic.PP.PL[0].dout_r[0] [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un1_dout_p_cry_0 ),
	.COUT(\u_cic.un1_dout_p_cry_2 ),
	.S0(\u_cic.un1_dout_p [1]),
	.S1(\u_cic.un1_dout_p [2])
);
defparam \u_cic.un1_dout_p_cry_1_0 .INIT0=16'h900a;
defparam \u_cic.un1_dout_p_cry_1_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_1_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_cic.un1_dout_p_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.un11_din_r_scalar ),
	.B1(\u_cic.PP.PL[0].dout_r[0] [0]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_cic.un1_dout_p_cry_0 ),
	.S0(N_3148),
	.S1(N_3149)
);
defparam \u_cic.un1_dout_p_cry_0_0 .INIT0=16'h500c;
defparam \u_cic.un1_dout_p_cry_0_0 .INIT1=16'h900a;
defparam \u_cic.un1_dout_p_cry_0_0 .INJECT1_0="NO";
defparam \u_cic.un1_dout_p_cry_0_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_s_21_0  (
	.A0(\u_cic.INTA[3].din_r[3] [21]),
	.B0(\u_cic.INTA[2].din_r[2] [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_20 ),
	.COUT(N_3144),
	.S0(\u_cic.un11_din_r [21]),
	.S1(N_3143)
);
defparam \u_cic.un11_din_r_s_21_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_s_21_0 .INIT1=16'h5003;
defparam \u_cic.un11_din_r_s_21_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_s_21_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_19_0  (
	.A0(\u_cic.INTA[3].din_r[3] [19]),
	.B0(\u_cic.INTA[2].din_r[2] [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [20]),
	.B1(\u_cic.INTA[2].din_r[2] [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_18 ),
	.COUT(\u_cic.un11_din_r_cry_20 ),
	.S0(\u_cic.un11_din_r [19]),
	.S1(\u_cic.un11_din_r [20])
);
defparam \u_cic.un11_din_r_cry_19_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_19_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_19_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_19_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_17_0  (
	.A0(\u_cic.INTA[3].din_r[3] [17]),
	.B0(\u_cic.INTA[2].din_r[2] [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [18]),
	.B1(\u_cic.INTA[2].din_r[2] [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_16 ),
	.COUT(\u_cic.un11_din_r_cry_18 ),
	.S0(\u_cic.un11_din_r [17]),
	.S1(\u_cic.un11_din_r [18])
);
defparam \u_cic.un11_din_r_cry_17_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_17_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_17_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_17_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_15_0  (
	.A0(\u_cic.INTA[3].din_r[3] [15]),
	.B0(\u_cic.INTA[2].din_r[2] [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [16]),
	.B1(\u_cic.INTA[2].din_r[2] [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_14 ),
	.COUT(\u_cic.un11_din_r_cry_16 ),
	.S0(\u_cic.un11_din_r [15]),
	.S1(\u_cic.un11_din_r [16])
);
defparam \u_cic.un11_din_r_cry_15_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_15_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_15_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_15_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_13_0  (
	.A0(\u_cic.INTA[3].din_r[3] [13]),
	.B0(\u_cic.INTA[2].din_r[2] [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [14]),
	.B1(\u_cic.INTA[2].din_r[2] [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_12 ),
	.COUT(\u_cic.un11_din_r_cry_14 ),
	.S0(\u_cic.un11_din_r [13]),
	.S1(\u_cic.un11_din_r [14])
);
defparam \u_cic.un11_din_r_cry_13_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_13_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_13_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_13_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_11_0  (
	.A0(\u_cic.INTA[3].din_r[3] [11]),
	.B0(\u_cic.INTA[2].din_r[2] [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [12]),
	.B1(\u_cic.INTA[2].din_r[2] [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_10 ),
	.COUT(\u_cic.un11_din_r_cry_12 ),
	.S0(\u_cic.un11_din_r [11]),
	.S1(\u_cic.un11_din_r [12])
);
defparam \u_cic.un11_din_r_cry_11_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_11_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_11_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_11_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_9_0  (
	.A0(\u_cic.INTA[3].din_r[3] [9]),
	.B0(\u_cic.INTA[2].din_r[2] [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [10]),
	.B1(\u_cic.INTA[2].din_r[2] [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_8 ),
	.COUT(\u_cic.un11_din_r_cry_10 ),
	.S0(\u_cic.un11_din_r [9]),
	.S1(\u_cic.un11_din_r [10])
);
defparam \u_cic.un11_din_r_cry_9_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_9_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_9_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_9_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_7_0  (
	.A0(\u_cic.INTA[3].din_r[3] [7]),
	.B0(\u_cic.INTA[2].din_r[2] [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [8]),
	.B1(\u_cic.INTA[2].din_r[2] [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_6 ),
	.COUT(\u_cic.un11_din_r_cry_8 ),
	.S0(\u_cic.un11_din_r [7]),
	.S1(\u_cic.un11_din_r [8])
);
defparam \u_cic.un11_din_r_cry_7_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_7_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_7_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_7_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_5_0  (
	.A0(\u_cic.INTA[3].din_r[3] [5]),
	.B0(\u_cic.INTA[2].din_r[2] [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [6]),
	.B1(\u_cic.INTA[2].din_r[2] [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_4 ),
	.COUT(\u_cic.un11_din_r_cry_6 ),
	.S0(\u_cic.un11_din_r [5]),
	.S1(\u_cic.un11_din_r [6])
);
defparam \u_cic.un11_din_r_cry_5_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_5_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_5_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_5_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_3_0  (
	.A0(\u_cic.INTA[3].din_r[3] [3]),
	.B0(\u_cic.INTA[2].din_r[2] [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [4]),
	.B1(\u_cic.INTA[2].din_r[2] [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_2 ),
	.COUT(\u_cic.un11_din_r_cry_4 ),
	.S0(\u_cic.un11_din_r [3]),
	.S1(\u_cic.un11_din_r [4])
);
defparam \u_cic.un11_din_r_cry_3_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_3_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_3_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_3_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un11_din_r_cry_1_0  (
	.A0(\u_cic.INTA[3].din_r[3] [1]),
	.B0(\u_cic.INTA[2].din_r[2] [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[3].din_r[3] [2]),
	.B1(\u_cic.INTA[2].din_r[2] [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un11_din_r_cry_0 ),
	.COUT(\u_cic.un11_din_r_cry_2 ),
	.S0(\u_cic.un11_din_r [1]),
	.S1(\u_cic.un11_din_r [2])
);
defparam \u_cic.un11_din_r_cry_1_0 .INIT0=16'h600a;
defparam \u_cic.un11_din_r_cry_1_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_1_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_cic.un11_din_r_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.un11_din_r_scalar ),
	.B1(\u_cic.un8_din_r_scalar ),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_cic.un11_din_r_cry_0 ),
	.S0(N_3122),
	.S1(N_2325)
);
defparam \u_cic.un11_din_r_cry_0_0 .INIT0=16'h5003;
defparam \u_cic.un11_din_r_cry_0_0 .INIT1=16'h600a;
defparam \u_cic.un11_din_r_cry_0_0 .INJECT1_0="NO";
defparam \u_cic.un11_din_r_cry_0_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_s_21_0  (
	.A0(\u_cic.INTA[2].din_r[2] [21]),
	.B0(\u_cic.INTA[1].din_r[1] [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_20 ),
	.COUT(N_3119),
	.S0(\u_cic.un8_din_r [21]),
	.S1(N_3118)
);
defparam \u_cic.un8_din_r_s_21_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_s_21_0 .INIT1=16'h5003;
defparam \u_cic.un8_din_r_s_21_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_s_21_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_19_0  (
	.A0(\u_cic.INTA[2].din_r[2] [19]),
	.B0(\u_cic.INTA[1].din_r[1] [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [20]),
	.B1(\u_cic.INTA[1].din_r[1] [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_18 ),
	.COUT(\u_cic.un8_din_r_cry_20 ),
	.S0(\u_cic.un8_din_r [19]),
	.S1(\u_cic.un8_din_r [20])
);
defparam \u_cic.un8_din_r_cry_19_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_19_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_19_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_19_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_17_0  (
	.A0(\u_cic.INTA[2].din_r[2] [17]),
	.B0(\u_cic.INTA[1].din_r[1] [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [18]),
	.B1(\u_cic.INTA[1].din_r[1] [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_16 ),
	.COUT(\u_cic.un8_din_r_cry_18 ),
	.S0(\u_cic.un8_din_r [17]),
	.S1(\u_cic.un8_din_r [18])
);
defparam \u_cic.un8_din_r_cry_17_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_17_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_17_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_17_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_15_0  (
	.A0(\u_cic.INTA[2].din_r[2] [15]),
	.B0(\u_cic.INTA[1].din_r[1] [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [16]),
	.B1(\u_cic.INTA[1].din_r[1] [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_14 ),
	.COUT(\u_cic.un8_din_r_cry_16 ),
	.S0(\u_cic.un8_din_r [15]),
	.S1(\u_cic.un8_din_r [16])
);
defparam \u_cic.un8_din_r_cry_15_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_15_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_15_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_15_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_13_0  (
	.A0(\u_cic.INTA[2].din_r[2] [13]),
	.B0(\u_cic.INTA[1].din_r[1] [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [14]),
	.B1(\u_cic.INTA[1].din_r[1] [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_12 ),
	.COUT(\u_cic.un8_din_r_cry_14 ),
	.S0(\u_cic.un8_din_r [13]),
	.S1(\u_cic.un8_din_r [14])
);
defparam \u_cic.un8_din_r_cry_13_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_13_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_13_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_13_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_11_0  (
	.A0(\u_cic.INTA[2].din_r[2] [11]),
	.B0(\u_cic.INTA[1].din_r[1] [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [12]),
	.B1(\u_cic.INTA[1].din_r[1] [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_10 ),
	.COUT(\u_cic.un8_din_r_cry_12 ),
	.S0(\u_cic.un8_din_r [11]),
	.S1(\u_cic.un8_din_r [12])
);
defparam \u_cic.un8_din_r_cry_11_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_11_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_11_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_11_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_9_0  (
	.A0(\u_cic.INTA[2].din_r[2] [9]),
	.B0(\u_cic.INTA[1].din_r[1] [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [10]),
	.B1(\u_cic.INTA[1].din_r[1] [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_8 ),
	.COUT(\u_cic.un8_din_r_cry_10 ),
	.S0(\u_cic.un8_din_r [9]),
	.S1(\u_cic.un8_din_r [10])
);
defparam \u_cic.un8_din_r_cry_9_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_9_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_9_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_9_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_7_0  (
	.A0(\u_cic.INTA[2].din_r[2] [7]),
	.B0(\u_cic.INTA[1].din_r[1] [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [8]),
	.B1(\u_cic.INTA[1].din_r[1] [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_6 ),
	.COUT(\u_cic.un8_din_r_cry_8 ),
	.S0(\u_cic.un8_din_r [7]),
	.S1(\u_cic.un8_din_r [8])
);
defparam \u_cic.un8_din_r_cry_7_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_7_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_7_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_7_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_5_0  (
	.A0(\u_cic.INTA[2].din_r[2] [5]),
	.B0(\u_cic.INTA[1].din_r[1] [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [6]),
	.B1(\u_cic.INTA[1].din_r[1] [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_4 ),
	.COUT(\u_cic.un8_din_r_cry_6 ),
	.S0(\u_cic.un8_din_r [5]),
	.S1(\u_cic.un8_din_r [6])
);
defparam \u_cic.un8_din_r_cry_5_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_5_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_5_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_5_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_3_0  (
	.A0(\u_cic.INTA[2].din_r[2] [3]),
	.B0(\u_cic.INTA[1].din_r[1] [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [4]),
	.B1(\u_cic.INTA[1].din_r[1] [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_2 ),
	.COUT(\u_cic.un8_din_r_cry_4 ),
	.S0(\u_cic.un8_din_r [3]),
	.S1(\u_cic.un8_din_r [4])
);
defparam \u_cic.un8_din_r_cry_3_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_3_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_3_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_3_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un8_din_r_cry_1_0  (
	.A0(\u_cic.INTA[2].din_r[2] [1]),
	.B0(\u_cic.INTA[1].din_r[1] [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[2].din_r[2] [2]),
	.B1(\u_cic.INTA[1].din_r[1] [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un8_din_r_cry_0 ),
	.COUT(\u_cic.un8_din_r_cry_2 ),
	.S0(\u_cic.un8_din_r [1]),
	.S1(\u_cic.un8_din_r [2])
);
defparam \u_cic.un8_din_r_cry_1_0 .INIT0=16'h600a;
defparam \u_cic.un8_din_r_cry_1_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_1_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_cic.un8_din_r_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.un8_din_r_scalar ),
	.B1(\u_cic.un5_din_r_scalar ),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_cic.un8_din_r_cry_0 ),
	.S0(N_3097),
	.S1(N_2304)
);
defparam \u_cic.un8_din_r_cry_0_0 .INIT0=16'h5003;
defparam \u_cic.un8_din_r_cry_0_0 .INIT1=16'h600a;
defparam \u_cic.un8_din_r_cry_0_0 .INJECT1_0="NO";
defparam \u_cic.un8_din_r_cry_0_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_s_21_0  (
	.A0(\u_cic.INTA[1].din_r[1] [21]),
	.B0(\u_cic.INTA[0].din_r[0] [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_20 ),
	.COUT(N_3094),
	.S0(\u_cic.un5_din_r [21]),
	.S1(N_3093)
);
defparam \u_cic.un5_din_r_s_21_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_s_21_0 .INIT1=16'h5003;
defparam \u_cic.un5_din_r_s_21_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_s_21_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_19_0  (
	.A0(\u_cic.INTA[1].din_r[1] [19]),
	.B0(\u_cic.INTA[0].din_r[0] [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [20]),
	.B1(\u_cic.INTA[0].din_r[0] [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_18 ),
	.COUT(\u_cic.un5_din_r_cry_20 ),
	.S0(\u_cic.un5_din_r [19]),
	.S1(\u_cic.un5_din_r [20])
);
defparam \u_cic.un5_din_r_cry_19_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_19_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_19_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_19_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_17_0  (
	.A0(\u_cic.INTA[1].din_r[1] [17]),
	.B0(\u_cic.INTA[0].din_r[0] [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [18]),
	.B1(\u_cic.INTA[0].din_r[0] [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_16 ),
	.COUT(\u_cic.un5_din_r_cry_18 ),
	.S0(\u_cic.un5_din_r [17]),
	.S1(\u_cic.un5_din_r [18])
);
defparam \u_cic.un5_din_r_cry_17_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_17_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_17_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_17_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_15_0  (
	.A0(\u_cic.INTA[1].din_r[1] [15]),
	.B0(\u_cic.INTA[0].din_r[0] [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [16]),
	.B1(\u_cic.INTA[0].din_r[0] [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_14 ),
	.COUT(\u_cic.un5_din_r_cry_16 ),
	.S0(\u_cic.un5_din_r [15]),
	.S1(\u_cic.un5_din_r [16])
);
defparam \u_cic.un5_din_r_cry_15_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_15_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_15_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_15_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_13_0  (
	.A0(\u_cic.INTA[1].din_r[1] [13]),
	.B0(\u_cic.INTA[0].din_r[0] [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [14]),
	.B1(\u_cic.INTA[0].din_r[0] [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_12 ),
	.COUT(\u_cic.un5_din_r_cry_14 ),
	.S0(\u_cic.un5_din_r [13]),
	.S1(\u_cic.un5_din_r [14])
);
defparam \u_cic.un5_din_r_cry_13_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_13_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_13_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_13_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_11_0  (
	.A0(\u_cic.INTA[1].din_r[1] [11]),
	.B0(\u_cic.INTA[0].din_r[0] [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [12]),
	.B1(\u_cic.INTA[0].din_r[0] [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_10 ),
	.COUT(\u_cic.un5_din_r_cry_12 ),
	.S0(\u_cic.un5_din_r [11]),
	.S1(\u_cic.un5_din_r [12])
);
defparam \u_cic.un5_din_r_cry_11_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_11_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_11_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_11_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_9_0  (
	.A0(\u_cic.INTA[1].din_r[1] [9]),
	.B0(\u_cic.INTA[0].din_r[0] [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [10]),
	.B1(\u_cic.INTA[0].din_r[0] [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_8 ),
	.COUT(\u_cic.un5_din_r_cry_10 ),
	.S0(\u_cic.un5_din_r [9]),
	.S1(\u_cic.un5_din_r [10])
);
defparam \u_cic.un5_din_r_cry_9_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_9_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_9_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_9_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_7_0  (
	.A0(\u_cic.INTA[1].din_r[1] [7]),
	.B0(\u_cic.INTA[0].din_r[0] [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [8]),
	.B1(\u_cic.INTA[0].din_r[0] [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_6 ),
	.COUT(\u_cic.un5_din_r_cry_8 ),
	.S0(\u_cic.un5_din_r [7]),
	.S1(\u_cic.un5_din_r [8])
);
defparam \u_cic.un5_din_r_cry_7_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_7_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_7_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_7_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_5_0  (
	.A0(\u_cic.INTA[1].din_r[1] [5]),
	.B0(\u_cic.INTA[0].din_r[0] [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [6]),
	.B1(\u_cic.INTA[0].din_r[0] [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_4 ),
	.COUT(\u_cic.un5_din_r_cry_6 ),
	.S0(\u_cic.un5_din_r [5]),
	.S1(\u_cic.un5_din_r [6])
);
defparam \u_cic.un5_din_r_cry_5_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_5_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_5_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_5_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_3_0  (
	.A0(\u_cic.INTA[1].din_r[1] [3]),
	.B0(\u_cic.INTA[0].din_r[0] [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [4]),
	.B1(\u_cic.INTA[0].din_r[0] [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_2 ),
	.COUT(\u_cic.un5_din_r_cry_4 ),
	.S0(\u_cic.un5_din_r [3]),
	.S1(\u_cic.un5_din_r [4])
);
defparam \u_cic.un5_din_r_cry_3_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_3_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_3_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_3_0 .INJECT1_1="NO";
// @6:80
  CCU2C \u_cic.un5_din_r_cry_1_0  (
	.A0(\u_cic.INTA[1].din_r[1] [1]),
	.B0(\u_cic.INTA[0].din_r[0] [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.INTA[1].din_r[1] [2]),
	.B1(\u_cic.INTA[0].din_r[0] [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.un5_din_r_cry_0 ),
	.COUT(\u_cic.un5_din_r_cry_2 ),
	.S0(\u_cic.un5_din_r [1]),
	.S1(\u_cic.un5_din_r [2])
);
defparam \u_cic.un5_din_r_cry_1_0 .INIT0=16'h600a;
defparam \u_cic.un5_din_r_cry_1_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_1_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_cic.un5_din_r_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.un5_din_r_scalar ),
	.B1(\u_cic.INTA[0].din_r[0] [0]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_cic.un5_din_r_cry_0 ),
	.S0(N_3072),
	.S1(N_2283)
);
defparam \u_cic.un5_din_r_cry_0_0 .INIT0=16'h5003;
defparam \u_cic.un5_din_r_cry_0_0 .INIT1=16'h600a;
defparam \u_cic.un5_din_r_cry_0_0 .INJECT1_0="NO";
defparam \u_cic.un5_din_r_cry_0_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_23_0  (
	.A0(\u_dcc.subo [23]),
	.B0(\u_dcc.subi [23]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [23]),
	.B1(\u_dcc.subi [24]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_22 ),
	.COUT(N_3070),
	.S0(\u_dcc.un1_sum [23]),
	.S1(\u_dcc.un1_sum [24])
);
defparam \u_dcc.un1_sum_cry_23_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_23_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_23_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_23_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_21_0  (
	.A0(\u_dcc.subo [21]),
	.B0(\u_dcc.subi [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [22]),
	.B1(\u_dcc.subi [22]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_20 ),
	.COUT(\u_dcc.un1_sum_cry_22 ),
	.S0(\u_dcc.un1_sum [21]),
	.S1(\u_dcc.un1_sum [22])
);
defparam \u_dcc.un1_sum_cry_21_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_21_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_21_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_21_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_19_0  (
	.A0(\u_dcc.subo [19]),
	.B0(\u_dcc.subi [19]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [20]),
	.B1(\u_dcc.subi [20]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_18 ),
	.COUT(\u_dcc.un1_sum_cry_20 ),
	.S0(\u_dcc.un1_sum [19]),
	.S1(\u_dcc.un1_sum [20])
);
defparam \u_dcc.un1_sum_cry_19_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_19_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_19_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_19_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_17_0  (
	.A0(\u_dcc.subo [17]),
	.B0(\u_dcc.subi [17]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [18]),
	.B1(\u_dcc.subi [18]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_16 ),
	.COUT(\u_dcc.un1_sum_cry_18 ),
	.S0(\u_dcc.un1_sum [17]),
	.S1(\u_dcc.un1_sum [18])
);
defparam \u_dcc.un1_sum_cry_17_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_17_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_17_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_17_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_15_0  (
	.A0(\u_dcc.subo [15]),
	.B0(\u_dcc.subi [15]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [16]),
	.B1(\u_dcc.subi [16]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_14 ),
	.COUT(\u_dcc.un1_sum_cry_16 ),
	.S0(\u_dcc.un1_sum [15]),
	.S1(\u_dcc.un1_sum [16])
);
defparam \u_dcc.un1_sum_cry_15_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_15_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_15_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_15_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_13_0  (
	.A0(\u_dcc.subo [13]),
	.B0(\u_dcc.subi [13]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [14]),
	.B1(\u_dcc.subi [14]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_12 ),
	.COUT(\u_dcc.un1_sum_cry_14 ),
	.S0(\u_dcc.un1_sum [13]),
	.S1(\u_dcc.un1_sum [14])
);
defparam \u_dcc.un1_sum_cry_13_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_13_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_13_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_13_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_11_0  (
	.A0(\u_dcc.subo [11]),
	.B0(\u_dcc.subi [11]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [12]),
	.B1(\u_dcc.subi [12]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_10 ),
	.COUT(\u_dcc.un1_sum_cry_12 ),
	.S0(\u_dcc.un1_sum [11]),
	.S1(\u_dcc.un1_sum [12])
);
defparam \u_dcc.un1_sum_cry_11_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_11_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_11_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_11_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_9_0  (
	.A0(\u_dcc.subo [9]),
	.B0(\u_dcc.subi [9]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [10]),
	.B1(\u_dcc.subi [10]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_8 ),
	.COUT(\u_dcc.un1_sum_cry_10 ),
	.S0(\u_dcc.un1_sum [9]),
	.S1(\u_dcc.un1_sum [10])
);
defparam \u_dcc.un1_sum_cry_9_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_9_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_9_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_9_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_7_0  (
	.A0(\u_dcc.subo [7]),
	.B0(\u_dcc.subi [7]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [8]),
	.B1(\u_dcc.subi [8]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_6 ),
	.COUT(\u_dcc.un1_sum_cry_8 ),
	.S0(\u_dcc.un1_sum [7]),
	.S1(\u_dcc.un1_sum [8])
);
defparam \u_dcc.un1_sum_cry_7_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_7_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_7_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_7_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_5_0  (
	.A0(\u_dcc.subo [5]),
	.B0(\u_dcc.subi [5]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [6]),
	.B1(\u_dcc.subi [6]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_4 ),
	.COUT(\u_dcc.un1_sum_cry_6 ),
	.S0(\u_dcc.un1_sum [5]),
	.S1(\u_dcc.un1_sum [6])
);
defparam \u_dcc.un1_sum_cry_5_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_5_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_5_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_5_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_3_0  (
	.A0(\u_dcc.subo [3]),
	.B0(\u_dcc.subi [3]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [4]),
	.B1(\u_dcc.subi [4]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_2 ),
	.COUT(\u_dcc.un1_sum_cry_4 ),
	.S0(\u_dcc.un1_sum [3]),
	.S1(\u_dcc.un1_sum [4])
);
defparam \u_dcc.un1_sum_cry_3_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_3_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_3_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_3_0 .INJECT1_1="NO";
// @8:100
  CCU2C \u_dcc.un1_sum_cry_1_0  (
	.A0(\u_dcc.subo [1]),
	.B0(\u_dcc.subi [1]),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [2]),
	.B1(\u_dcc.subi [2]),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_dcc.un1_sum_cry_0 ),
	.COUT(\u_dcc.un1_sum_cry_2 ),
	.S0(\u_dcc.un1_sum [1]),
	.S1(\u_dcc.un1_sum [2])
);
defparam \u_dcc.un1_sum_cry_1_0 .INIT0=16'h600a;
defparam \u_dcc.un1_sum_cry_1_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_1_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_dcc.un1_sum_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_dcc.subo [0]),
	.B1(\u_dcc.subi [0]),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_dcc.un1_sum_cry_0 ),
	.S0(N_3046),
	.S1(N_2262)
);
defparam \u_dcc.un1_sum_cry_0_0 .INIT0=16'h5003;
defparam \u_dcc.un1_sum_cry_0_0 .INIT1=16'h600a;
defparam \u_dcc.un1_sum_cry_0_0 .INJECT1_0="NO";
defparam \u_dcc.un1_sum_cry_0_0 .INJECT1_1="NO";
// @7:206
  CCU2C \u_comps.raddr_R_s_0[5]  (
	.A0(\u_comps.raddr_R [5]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.raddr_R_cry [4]),
	.COUT(N_3043),
	.S0(\u_comps.raddr_R_s [5]),
	.S1(N_3042)
);
defparam \u_comps.raddr_R_s_0[5] .INIT0=16'h500a;
defparam \u_comps.raddr_R_s_0[5] .INIT1=16'h5003;
defparam \u_comps.raddr_R_s_0[5] .INJECT1_0="NO";
defparam \u_comps.raddr_R_s_0[5] .INJECT1_1="NO";
// @7:206
  CCU2C \u_comps.raddr_R_cry_0[3]  (
	.A0(\u_comps.raddr_R [3]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.raddr_R [4]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.raddr_R_cry [2]),
	.COUT(\u_comps.raddr_R_cry [4]),
	.S0(\u_comps.raddr_R_s [3]),
	.S1(\u_comps.raddr_R_s [4])
);
defparam \u_comps.raddr_R_cry_0[3] .INIT0=16'h500f;
defparam \u_comps.raddr_R_cry_0[3] .INIT1=16'h500f;
defparam \u_comps.raddr_R_cry_0[3] .INJECT1_0="NO";
defparam \u_comps.raddr_R_cry_0[3] .INJECT1_1="NO";
// @7:206
  CCU2C \u_comps.raddr_R_cry_0[1]  (
	.A0(\u_comps.raddr_R [1]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.raddr_R [2]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.raddr_R_cry [0]),
	.COUT(\u_comps.raddr_R_cry [2]),
	.S0(\u_comps.raddr_R_s [1]),
	.S1(\u_comps.raddr_R_s [2])
);
defparam \u_comps.raddr_R_cry_0[1] .INIT0=16'h500f;
defparam \u_comps.raddr_R_cry_0[1] .INIT1=16'h500f;
defparam \u_comps.raddr_R_cry_0[1] .INJECT1_0="NO";
defparam \u_comps.raddr_R_cry_0[1] .INJECT1_1="NO";
  CCU2C \u_comps.raddr_R_cry_0[0]  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.raddr_R [0]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.raddr_R_cry [0]),
	.S0(N_3037),
	.S1(\u_comps.raddr_R_s [0])
);
defparam \u_comps.raddr_R_cry_0[0] .INIT0=16'h5003;
defparam \u_comps.raddr_R_cry_0[0] .INIT1=16'h500f;
defparam \u_comps.raddr_R_cry_0[0] .INJECT1_0="NO";
defparam \u_comps.raddr_R_cry_0[0] .INJECT1_1="NO";
// @7:196
  CCU2C \u_comps.raddr_L_s_0[5]  (
	.A0(\u_comps.raddr_L [5]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.raddr_L_cry [4]),
	.COUT(N_3034),
	.S0(\u_comps.raddr_L_s [5]),
	.S1(N_3033)
);
defparam \u_comps.raddr_L_s_0[5] .INIT0=16'ha00a;
defparam \u_comps.raddr_L_s_0[5] .INIT1=16'h5003;
defparam \u_comps.raddr_L_s_0[5] .INJECT1_0="NO";
defparam \u_comps.raddr_L_s_0[5] .INJECT1_1="NO";
// @7:196
  CCU2C \u_comps.raddr_L_cry_0[3]  (
	.A0(\u_comps.raddr_L [3]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.raddr_L [4]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.raddr_L_cry [2]),
	.COUT(\u_comps.raddr_L_cry [4]),
	.S0(\u_comps.raddr_L_s [3]),
	.S1(\u_comps.raddr_L_s [4])
);
defparam \u_comps.raddr_L_cry_0[3] .INIT0=16'ha003;
defparam \u_comps.raddr_L_cry_0[3] .INIT1=16'ha003;
defparam \u_comps.raddr_L_cry_0[3] .INJECT1_0="NO";
defparam \u_comps.raddr_L_cry_0[3] .INJECT1_1="NO";
// @7:196
  CCU2C \u_comps.raddr_L_cry_0[1]  (
	.A0(\u_comps.raddr_L [1]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.raddr_L [2]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.raddr_L_cry [0]),
	.COUT(\u_comps.raddr_L_cry [2]),
	.S0(\u_comps.raddr_L_s [1]),
	.S1(\u_comps.raddr_L_s [2])
);
defparam \u_comps.raddr_L_cry_0[1] .INIT0=16'ha003;
defparam \u_comps.raddr_L_cry_0[1] .INIT1=16'ha003;
defparam \u_comps.raddr_L_cry_0[1] .INJECT1_0="NO";
defparam \u_comps.raddr_L_cry_0[1] .INJECT1_1="NO";
  CCU2C \u_comps.raddr_L_cry_0[0]  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.raddr_L [0]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.raddr_L_cry [0]),
	.S0(N_3027),
	.S1(\u_comps.raddr_L_s [0])
);
defparam \u_comps.raddr_L_cry_0[0] .INIT0=16'h500c;
defparam \u_comps.raddr_L_cry_0[0] .INIT1=16'ha003;
defparam \u_comps.raddr_L_cry_0[0] .INJECT1_0="NO";
defparam \u_comps.raddr_L_cry_0[0] .INJECT1_1="NO";
// @7:188
  CCU2C \u_comps.waddr_cry_0[5]  (
	.A0(\u_comps.waddr [5]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.waddr [6]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.waddr_cry [4]),
	.COUT(N_3024),
	.S0(\u_comps.waddr_s [5]),
	.S1(\u_comps.waddr_s [6])
);
defparam \u_comps.waddr_cry_0[5] .INIT0=16'ha003;
defparam \u_comps.waddr_cry_0[5] .INIT1=16'ha00a;
defparam \u_comps.waddr_cry_0[5] .INJECT1_0="NO";
defparam \u_comps.waddr_cry_0[5] .INJECT1_1="NO";
// @7:188
  CCU2C \u_comps.waddr_cry_0[3]  (
	.A0(\u_comps.waddr [3]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.waddr [4]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.waddr_cry [2]),
	.COUT(\u_comps.waddr_cry [4]),
	.S0(\u_comps.waddr_s [3]),
	.S1(\u_comps.waddr_s [4])
);
defparam \u_comps.waddr_cry_0[3] .INIT0=16'ha003;
defparam \u_comps.waddr_cry_0[3] .INIT1=16'ha003;
defparam \u_comps.waddr_cry_0[3] .INJECT1_0="NO";
defparam \u_comps.waddr_cry_0[3] .INJECT1_1="NO";
// @7:188
  CCU2C \u_comps.waddr_cry_0[1]  (
	.A0(\u_comps.waddr [1]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.waddr [2]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.waddr_cry [0]),
	.COUT(\u_comps.waddr_cry [2]),
	.S0(\u_comps.waddr_s [1]),
	.S1(\u_comps.waddr_s [2])
);
defparam \u_comps.waddr_cry_0[1] .INIT0=16'ha003;
defparam \u_comps.waddr_cry_0[1] .INIT1=16'ha003;
defparam \u_comps.waddr_cry_0[1] .INJECT1_0="NO";
defparam \u_comps.waddr_cry_0[1] .INJECT1_1="NO";
  CCU2C \u_comps.waddr_cry_0[0]  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.waddr [0]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.waddr_cry [0]),
	.S0(N_3017),
	.S1(\u_comps.waddr_s [0])
);
defparam \u_comps.waddr_cry_0[0] .INIT0=16'h500c;
defparam \u_comps.waddr_cry_0[0] .INIT1=16'ha003;
defparam \u_comps.waddr_cry_0[0] .INJECT1_0="NO";
defparam \u_comps.waddr_cry_0[0] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_s_0[21]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [21]),
	.C0(VCC),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [20]),
	.COUT(N_3013),
	.S0(\u_cic.INTA[0].din_r[0]_s [21]),
	.S1(N_3012)
);
defparam \u_cic.INTA[0].din_r[0]_s_0[21] .INIT0=16'h900a;
defparam \u_cic.INTA[0].din_r[0]_s_0[21] .INIT1=16'h5003;
defparam \u_cic.INTA[0].din_r[0]_s_0[21] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_s_0[21] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[19]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [19]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [20]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [18]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [20]),
	.S0(\u_cic.INTA[0].din_r[0]_s [19]),
	.S1(\u_cic.INTA[0].din_r[0]_s [20])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[19] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[19] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[19] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[19] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[17]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [17]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [18]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [16]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [18]),
	.S0(\u_cic.INTA[0].din_r[0]_s [17]),
	.S1(\u_cic.INTA[0].din_r[0]_s [18])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[17] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[17] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[17] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[17] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[15]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [15]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [16]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [14]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [16]),
	.S0(\u_cic.INTA[0].din_r[0]_s [15]),
	.S1(\u_cic.INTA[0].din_r[0]_s [16])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[15] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[15] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[15] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[15] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[13]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [13]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [14]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [12]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [14]),
	.S0(\u_cic.INTA[0].din_r[0]_s [13]),
	.S1(\u_cic.INTA[0].din_r[0]_s [14])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[13] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[13] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[13] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[13] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[11]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [11]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [12]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [10]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [12]),
	.S0(\u_cic.INTA[0].din_r[0]_s [11]),
	.S1(\u_cic.INTA[0].din_r[0]_s [12])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[11] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[11] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[11] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[11] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[9]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [9]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [10]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [8]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [10]),
	.S0(\u_cic.INTA[0].din_r[0]_s [9]),
	.S1(\u_cic.INTA[0].din_r[0]_s [10])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[9] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[9] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[9] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[9] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[7]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [7]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [8]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [6]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [8]),
	.S0(\u_cic.INTA[0].din_r[0]_s [7]),
	.S1(\u_cic.INTA[0].din_r[0]_s [8])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[7] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[7] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[7] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[7] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[5]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [5]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [6]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [4]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [6]),
	.S0(\u_cic.INTA[0].din_r[0]_s [5]),
	.S1(\u_cic.INTA[0].din_r[0]_s [6])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[5] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[5] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[5] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[5] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[3]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [3]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [4]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [2]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [4]),
	.S0(\u_cic.INTA[0].din_r[0]_s [3]),
	.S1(\u_cic.INTA[0].din_r[0]_s [4])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[3] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[3] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[3] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[3] .INJECT1_1="NO";
// @6:73
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[1]  (
	.A0(pdm_data),
	.B0(\u_cic.INTA[0].din_r[0] [1]),
	.C0(pdm_data),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [2]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(\u_cic.INTA[0].din_r[0]_cry [0]),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [2]),
	.S0(\u_cic.INTA[0].din_r[0]_s [1]),
	.S1(\u_cic.INTA[0].din_r[0]_s [2])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[1] .INIT0=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[1] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[1] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[1] .INJECT1_1="NO";
  CCU2C \u_cic.INTA[0].din_r[0]_cry_0[0]  (
	.A0(VCC),
	.B0(pdm_data),
	.C0(VCC),
	.D0(VCC),
	.A1(pdm_data),
	.B1(\u_cic.INTA[0].din_r[0] [0]),
	.C1(pdm_data),
	.D1(VCC),
	.CIN(),
	.COUT(\u_cic.INTA[0].din_r[0]_cry [0]),
	.S0(N_2990),
	.S1(\u_cic.INTA[0].din_r[0]_s [0])
);
defparam \u_cic.INTA[0].din_r[0]_cry_0[0] .INIT0=16'h500c;
defparam \u_cic.INTA[0].din_r[0]_cry_0[0] .INIT1=16'hc305;
defparam \u_cic.INTA[0].din_r[0]_cry_0[0] .INJECT1_0="NO";
defparam \u_cic.INTA[0].din_r[0]_cry_0[0] .INJECT1_1="NO";
// @6:87
  CCU2C \u_cic.dcnt_cry_0[3]  (
	.A0(\u_cic.dcnt [3]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.dcnt [4]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.dcnt_cry [2]),
	.COUT(N_2987),
	.S0(\u_cic.dcnt_s [3]),
	.S1(\u_cic.dcnt_s [4])
);
defparam \u_cic.dcnt_cry_0[3] .INIT0=16'ha003;
defparam \u_cic.dcnt_cry_0[3] .INIT1=16'ha00a;
defparam \u_cic.dcnt_cry_0[3] .INJECT1_0="NO";
defparam \u_cic.dcnt_cry_0[3] .INJECT1_1="NO";
// @6:87
  CCU2C \u_cic.dcnt_cry_0[1]  (
	.A0(\u_cic.dcnt [1]),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.dcnt [2]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_cic.dcnt_cry [0]),
	.COUT(\u_cic.dcnt_cry [2]),
	.S0(\u_cic.dcnt_s [1]),
	.S1(\u_cic.dcnt_s [2])
);
defparam \u_cic.dcnt_cry_0[1] .INIT0=16'ha003;
defparam \u_cic.dcnt_cry_0[1] .INIT1=16'ha003;
defparam \u_cic.dcnt_cry_0[1] .INJECT1_0="NO";
defparam \u_cic.dcnt_cry_0[1] .INJECT1_1="NO";
  CCU2C \u_cic.dcnt_cry_0[0]  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_cic.dcnt [0]),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(),
	.COUT(\u_cic.dcnt_cry [0]),
	.S0(N_2982),
	.S1(\u_cic.dcnt_s [0])
);
defparam \u_cic.dcnt_cry_0[0] .INIT0=16'h500c;
defparam \u_cic.dcnt_cry_0[0] .INIT1=16'ha003;
defparam \u_cic.dcnt_cry_0[0] .INJECT1_0="NO";
defparam \u_cic.dcnt_cry_0[0] .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_s_31_0  (
	.A0(\u_comps.mult_result [30]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mac_B [31]),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_30 ),
	.COUT(N_2978),
	.S0(\u_comps.mac_B_4 [31]),
	.S1(N_2977)
);
defparam \u_comps.mac_B_4_s_31_0 .INIT0=16'h9a0a;
defparam \u_comps.mac_B_4_s_31_0 .INIT1=16'h5003;
defparam \u_comps.mac_B_4_s_31_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_s_31_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_29_0  (
	.A0(\u_comps.mac_B [29]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [29]),
	.D0(VCC),
	.A1(\u_comps.mac_B [30]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [30]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_28 ),
	.COUT(\u_comps.mac_B_4_cry_30 ),
	.S0(\u_comps.mac_B_4 [29]),
	.S1(\u_comps.mac_B_4 [30])
);
defparam \u_comps.mac_B_4_cry_29_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_29_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_29_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_29_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_27_0  (
	.A0(\u_comps.mac_B [27]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [27]),
	.D0(VCC),
	.A1(\u_comps.mac_B [28]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [28]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_26 ),
	.COUT(\u_comps.mac_B_4_cry_28 ),
	.S0(\u_comps.mac_B_4 [27]),
	.S1(\u_comps.mac_B_4 [28])
);
defparam \u_comps.mac_B_4_cry_27_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_27_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_27_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_27_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_25_0  (
	.A0(\u_comps.mac_B [25]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [25]),
	.D0(VCC),
	.A1(\u_comps.mac_B [26]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [26]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_24 ),
	.COUT(\u_comps.mac_B_4_cry_26 ),
	.S0(\u_comps.mac_B_4 [25]),
	.S1(\u_comps.mac_B_4 [26])
);
defparam \u_comps.mac_B_4_cry_25_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_25_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_25_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_25_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_23_0  (
	.A0(\u_comps.mac_B [23]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [23]),
	.D0(VCC),
	.A1(\u_comps.mac_B [24]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [24]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_22 ),
	.COUT(\u_comps.mac_B_4_cry_24 ),
	.S0(\u_comps.mac_B_4 [23]),
	.S1(\u_comps.mac_B_4 [24])
);
defparam \u_comps.mac_B_4_cry_23_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_23_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_23_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_23_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_21_0  (
	.A0(\u_comps.mac_B [21]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [21]),
	.D0(VCC),
	.A1(\u_comps.mac_B [22]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [22]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_20 ),
	.COUT(\u_comps.mac_B_4_cry_22 ),
	.S0(\u_comps.mac_B_4 [21]),
	.S1(\u_comps.mac_B_4 [22])
);
defparam \u_comps.mac_B_4_cry_21_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_21_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_21_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_21_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_19_0  (
	.A0(\u_comps.mac_B [19]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [19]),
	.D0(VCC),
	.A1(\u_comps.mac_B [20]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [20]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_18 ),
	.COUT(\u_comps.mac_B_4_cry_20 ),
	.S0(\u_comps.mac_B_4 [19]),
	.S1(\u_comps.mac_B_4 [20])
);
defparam \u_comps.mac_B_4_cry_19_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_19_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_19_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_19_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_17_0  (
	.A0(\u_comps.mac_B [17]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [17]),
	.D0(VCC),
	.A1(\u_comps.mac_B [18]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [18]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_16 ),
	.COUT(\u_comps.mac_B_4_cry_18 ),
	.S0(\u_comps.mac_B_4 [17]),
	.S1(\u_comps.mac_B_4 [18])
);
defparam \u_comps.mac_B_4_cry_17_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_17_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_17_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_17_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_15_0  (
	.A0(\u_comps.mac_B [15]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mac_B_4_2 ),
	.D0(\u_comps.mac_B_4_1 ),
	.A1(\u_comps.mac_B [16]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [16]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_14 ),
	.COUT(\u_comps.mac_B_4_cry_16 ),
	.S0(\u_comps.mac_B_4 [15]),
	.S1(\u_comps.mac_B_4 [16])
);
defparam \u_comps.mac_B_4_cry_15_0 .INIT0=16'h2dd2;
defparam \u_comps.mac_B_4_cry_15_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_15_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_13_0  (
	.A0(\u_comps.mac_B [13]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [13]),
	.D0(VCC),
	.A1(\u_comps.mac_B [14]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [14]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_12 ),
	.COUT(\u_comps.mac_B_4_cry_14 ),
	.S0(\u_comps.mac_B_4 [13]),
	.S1(\u_comps.mac_B_4 [14])
);
defparam \u_comps.mac_B_4_cry_13_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_13_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_13_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_11_0  (
	.A0(\u_comps.mac_B [11]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [11]),
	.D0(VCC),
	.A1(\u_comps.mac_B [12]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [12]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_10 ),
	.COUT(\u_comps.mac_B_4_cry_12 ),
	.S0(\u_comps.mac_B_4 [11]),
	.S1(\u_comps.mac_B_4 [12])
);
defparam \u_comps.mac_B_4_cry_11_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_11_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_11_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_9_0  (
	.A0(\u_comps.mac_B [9]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [9]),
	.D0(VCC),
	.A1(\u_comps.mac_B [10]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [10]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_8 ),
	.COUT(\u_comps.mac_B_4_cry_10 ),
	.S0(\u_comps.mac_B_4 [9]),
	.S1(\u_comps.mac_B_4 [10])
);
defparam \u_comps.mac_B_4_cry_9_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_9_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_9_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_7_0  (
	.A0(\u_comps.mac_B [7]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [7]),
	.D0(VCC),
	.A1(\u_comps.mac_B [8]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mac_B_4_0 ),
	.D1(\u_comps.mac_B_4_scalar ),
	.CIN(\u_comps.mac_B_4_cry_6 ),
	.COUT(\u_comps.mac_B_4_cry_8 ),
	.S0(\u_comps.mac_B_4 [7]),
	.S1(\u_comps.mac_B_4 [8])
);
defparam \u_comps.mac_B_4_cry_7_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_7_0 .INIT1=16'h2dd2;
defparam \u_comps.mac_B_4_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_7_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_5_0  (
	.A0(\u_comps.mac_B [5]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [5]),
	.D0(VCC),
	.A1(\u_comps.mac_B [6]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [6]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_4 ),
	.COUT(\u_comps.mac_B_4_cry_6 ),
	.S0(\u_comps.mac_B_4 [5]),
	.S1(\u_comps.mac_B_4 [6])
);
defparam \u_comps.mac_B_4_cry_5_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_5_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_5_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_3_0  (
	.A0(\u_comps.mac_B [3]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [3]),
	.D0(VCC),
	.A1(\u_comps.mac_B [4]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [4]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_2 ),
	.COUT(\u_comps.mac_B_4_cry_4 ),
	.S0(\u_comps.mac_B_4 [3]),
	.S1(\u_comps.mac_B_4 [4])
);
defparam \u_comps.mac_B_4_cry_3_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_3_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_3_0 .INJECT1_1="NO";
// @7:344
  CCU2C \u_comps.mac_B_4_cry_1_0  (
	.A0(\u_comps.mac_B [1]),
	.B0(\u_comps.dstart_r [5]),
	.C0(\u_comps.mult_result [1]),
	.D0(VCC),
	.A1(\u_comps.mac_B [2]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [2]),
	.D1(VCC),
	.CIN(\u_comps.mac_B_4_cry_0 ),
	.COUT(\u_comps.mac_B_4_cry_2 ),
	.S0(\u_comps.mac_B_4 [1]),
	.S1(\u_comps.mac_B_4 [2])
);
defparam \u_comps.mac_B_4_cry_1_0 .INIT0=16'hd202;
defparam \u_comps.mac_B_4_cry_1_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.mac_B_4_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_B [0]),
	.B1(\u_comps.dstart_r [5]),
	.C1(\u_comps.mult_result [0]),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.mac_B_4_cry_0 ),
	.S0(N_2946),
	.S1(N_2217)
);
defparam \u_comps.mac_B_4_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.mac_B_4_cry_0_0 .INIT1=16'hd202;
defparam \u_comps.mac_B_4_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.mac_B_4_cry_0_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_s_27_0  (
	.A0(\u_comps.mult_result [27]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mac_T [27]),
	.D0(VCC),
	.A1(VCC),
	.B1(VCC),
	.C1(VCC),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_26 ),
	.COUT(N_2943),
	.S0(\u_comps.mac_T_4 [27]),
	.S1(N_2942)
);
defparam \u_comps.mac_T_4_s_27_0 .INIT0=16'h9a0a;
defparam \u_comps.mac_T_4_s_27_0 .INIT1=16'h5003;
defparam \u_comps.mac_T_4_s_27_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_s_27_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_25_0  (
	.A0(\u_comps.mac_T [25]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [25]),
	.D0(VCC),
	.A1(\u_comps.mac_T [26]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [26]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_24 ),
	.COUT(\u_comps.mac_T_4_cry_26 ),
	.S0(\u_comps.mac_T_4 [25]),
	.S1(\u_comps.mac_T_4 [26])
);
defparam \u_comps.mac_T_4_cry_25_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_25_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_25_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_25_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_23_0  (
	.A0(\u_comps.mac_T [23]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [23]),
	.D0(VCC),
	.A1(\u_comps.mac_T [24]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [24]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_22 ),
	.COUT(\u_comps.mac_T_4_cry_24 ),
	.S0(\u_comps.mac_T_4 [23]),
	.S1(\u_comps.mac_T_4 [24])
);
defparam \u_comps.mac_T_4_cry_23_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_23_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_23_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_23_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_21_0  (
	.A0(\u_comps.mac_T [21]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [21]),
	.D0(VCC),
	.A1(\u_comps.mac_T [22]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [22]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_20 ),
	.COUT(\u_comps.mac_T_4_cry_22 ),
	.S0(\u_comps.mac_T_4 [21]),
	.S1(\u_comps.mac_T_4 [22])
);
defparam \u_comps.mac_T_4_cry_21_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_21_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_21_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_21_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_19_0  (
	.A0(\u_comps.mac_T [19]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [19]),
	.D0(VCC),
	.A1(\u_comps.mac_T [20]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [20]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_18 ),
	.COUT(\u_comps.mac_T_4_cry_20 ),
	.S0(\u_comps.mac_T_4 [19]),
	.S1(\u_comps.mac_T_4 [20])
);
defparam \u_comps.mac_T_4_cry_19_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_19_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_19_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_19_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_17_0  (
	.A0(\u_comps.mac_T [17]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [17]),
	.D0(VCC),
	.A1(\u_comps.mac_T [18]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [18]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_16 ),
	.COUT(\u_comps.mac_T_4_cry_18 ),
	.S0(\u_comps.mac_T_4 [17]),
	.S1(\u_comps.mac_T_4 [18])
);
defparam \u_comps.mac_T_4_cry_17_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_17_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_17_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_17_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_15_0  (
	.A0(\u_comps.mac_T [15]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mac_B_4_2 ),
	.D0(\u_comps.mac_B_4_1 ),
	.A1(\u_comps.mac_T [16]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [16]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_14 ),
	.COUT(\u_comps.mac_T_4_cry_16 ),
	.S0(\u_comps.mac_T_4 [15]),
	.S1(\u_comps.mac_T_4 [16])
);
defparam \u_comps.mac_T_4_cry_15_0 .INIT0=16'h2dd2;
defparam \u_comps.mac_T_4_cry_15_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_15_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_15_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_13_0  (
	.A0(\u_comps.mac_T [13]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [13]),
	.D0(VCC),
	.A1(\u_comps.mac_T [14]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [14]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_12 ),
	.COUT(\u_comps.mac_T_4_cry_14 ),
	.S0(\u_comps.mac_T_4 [13]),
	.S1(\u_comps.mac_T_4 [14])
);
defparam \u_comps.mac_T_4_cry_13_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_13_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_13_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_13_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_11_0  (
	.A0(\u_comps.mac_T [11]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [11]),
	.D0(VCC),
	.A1(\u_comps.mac_T [12]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [12]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_10 ),
	.COUT(\u_comps.mac_T_4_cry_12 ),
	.S0(\u_comps.mac_T_4 [11]),
	.S1(\u_comps.mac_T_4 [12])
);
defparam \u_comps.mac_T_4_cry_11_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_11_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_11_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_11_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_9_0  (
	.A0(\u_comps.mac_T [9]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [9]),
	.D0(VCC),
	.A1(\u_comps.mac_T [10]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [10]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_8 ),
	.COUT(\u_comps.mac_T_4_cry_10 ),
	.S0(\u_comps.mac_T_4 [9]),
	.S1(\u_comps.mac_T_4 [10])
);
defparam \u_comps.mac_T_4_cry_9_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_9_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_9_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_9_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_7_0  (
	.A0(\u_comps.mac_T [7]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [7]),
	.D0(VCC),
	.A1(\u_comps.mac_T [8]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mac_B_4_0 ),
	.D1(\u_comps.mac_B_4_scalar ),
	.CIN(\u_comps.mac_T_4_cry_6 ),
	.COUT(\u_comps.mac_T_4_cry_8 ),
	.S0(\u_comps.mac_T_4 [7]),
	.S1(\u_comps.mac_T_4 [8])
);
defparam \u_comps.mac_T_4_cry_7_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_7_0 .INIT1=16'h2dd2;
defparam \u_comps.mac_T_4_cry_7_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_7_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_5_0  (
	.A0(\u_comps.mac_T [5]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [5]),
	.D0(VCC),
	.A1(\u_comps.mac_T [6]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [6]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_4 ),
	.COUT(\u_comps.mac_T_4_cry_6 ),
	.S0(\u_comps.mac_T_4 [5]),
	.S1(\u_comps.mac_T_4 [6])
);
defparam \u_comps.mac_T_4_cry_5_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_5_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_5_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_5_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_3_0  (
	.A0(\u_comps.mac_T [3]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [3]),
	.D0(VCC),
	.A1(\u_comps.mac_T [4]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [4]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_2 ),
	.COUT(\u_comps.mac_T_4_cry_4 ),
	.S0(\u_comps.mac_T_4 [3]),
	.S1(\u_comps.mac_T_4 [4])
);
defparam \u_comps.mac_T_4_cry_3_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_3_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_3_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_3_0 .INJECT1_1="NO";
// @7:334
  CCU2C \u_comps.mac_T_4_cry_1_0  (
	.A0(\u_comps.mac_T [1]),
	.B0(\u_comps.dstart_r [4]),
	.C0(\u_comps.mult_result [1]),
	.D0(VCC),
	.A1(\u_comps.mac_T [2]),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [2]),
	.D1(VCC),
	.CIN(\u_comps.mac_T_4_cry_0 ),
	.COUT(\u_comps.mac_T_4_cry_2 ),
	.S0(\u_comps.mac_T_4 [1]),
	.S1(\u_comps.mac_T_4 [2])
);
defparam \u_comps.mac_T_4_cry_1_0 .INIT0=16'hd202;
defparam \u_comps.mac_T_4_cry_1_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_1_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_1_0 .INJECT1_1="NO";
  CCU2C \u_comps.mac_T_4_cry_0_0  (
	.A0(VCC),
	.B0(VCC),
	.C0(VCC),
	.D0(VCC),
	.A1(\u_comps.mac_sum_scalar ),
	.B1(\u_comps.dstart_r [4]),
	.C1(\u_comps.mult_result [0]),
	.D1(VCC),
	.CIN(),
	.COUT(\u_comps.mac_T_4_cry_0 ),
	.S0(N_2915),
	.S1(N_2155)
);
defparam \u_comps.mac_T_4_cry_0_0 .INIT0=16'h5003;
defparam \u_comps.mac_T_4_cry_0_0 .INIT1=16'hd202;
defparam \u_comps.mac_T_4_cry_0_0 .INJECT1_0="NO";
defparam \u_comps.mac_T_4_cry_0_0 .INJECT1_1="NO";
// @7:201
  LUT4 \u_comps.un2_raddr_L_ac0_5  (
	.A(\u_comps.waddr [4]),
	.B(\u_comps.waddr [1]),
	.C(\u_comps.waddr [2]),
	.D(\u_comps.waddr [3]),
	.Z(\u_comps.un2_raddr_L_c4 )
);
defparam \u_comps.un2_raddr_L_ac0_5 .init=16'h8000;
// @7:201
  LUT4 \u_comps.un2_raddr_L_ac0_3  (
	.A(\u_comps.waddr [3]),
	.B(\u_comps.waddr [2]),
	.C(\u_comps.waddr [1]),
	.D(VCC),
	.Z(\u_comps.un2_raddr_L_c3 )
);
defparam \u_comps.un2_raddr_L_ac0_3 .init=16'h8080;
  LUT4 \u_comps.run_en_RNITTN31  (
	.A(\u_comps.run_even ),
	.B(\u_comps.run_en ),
	.C(\u_comps.din_even ),
	.D(cic_dvalid),
	.Z(\u_comps.raddr_Le )
);
defparam \u_comps.run_en_RNITTN31 .init=16'h8F88;
// @6:48
  LUT4 \u_comps.un13_dout_en_1_cZ  (
	.A(\u_comps.caddr [1]),
	.B(\u_comps.caddr [2]),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.un13_dout_en_1 )
);
defparam \u_comps.un13_dout_en_1_cZ .init=16'h1111;
// @6:48
  LUT4 \u_cic.un10_sample_point_1_cZ  (
	.A(\u_cic.dcnt [0]),
	.B(\u_cic.dcnt [2]),
	.C(VCC),
	.D(VCC),
	.Z(\u_cic.un10_sample_point_1 )
);
defparam \u_cic.un10_sample_point_1_cZ .init=16'h1111;
// @7:201
  LUT4 \u_comps.un2_raddr_L_ac0_1  (
	.A(\u_comps.waddr [1]),
	.B(\u_comps.waddr [2]),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.un2_raddr_L_c2 )
);
defparam \u_comps.un2_raddr_L_ac0_1 .init=16'h8888;
// @8:100
  LUT4 \u_dcc.un1_sum_axb_0_cZ  (
	.A(\u_dcc.subi [0]),
	.B(\u_dcc.subo [0]),
	.C(VCC),
	.D(VCC),
	.Z(\u_dcc.un1_sum_axb_0 )
);
defparam \u_dcc.un1_sum_axb_0_cZ .init=16'h6666;
// @6:80
  LUT4 \u_cic.un5_din_r_axb_0  (
	.A(\u_cic.INTA[0].din_r[0] [0]),
	.B(\u_cic.un5_din_r_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_cic.un5_din_r [0])
);
defparam \u_cic.un5_din_r_axb_0 .init=16'h6666;
// @6:80
  LUT4 \u_cic.un8_din_r_axb_0  (
	.A(\u_cic.un5_din_r_scalar ),
	.B(\u_cic.un8_din_r_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_cic.un8_din_r [0])
);
defparam \u_cic.un8_din_r_axb_0 .init=16'h6666;
// @6:80
  LUT4 \u_cic.un11_din_r_axb_0  (
	.A(\u_cic.un8_din_r_scalar ),
	.B(\u_cic.un11_din_r_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_cic.un11_din_r [0])
);
defparam \u_cic.un11_din_r_axb_0 .init=16'h6666;
// @7:224
  LUT4 \u_comps.un3_data_M_axb_0  (
	.A(\u_comps.data_Lf [0]),
	.B(\u_comps.data_Rf [0]),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.un3_data_M [0])
);
defparam \u_comps.un3_data_M_axb_0 .init=16'h6666;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_36_RNO  (
	.A(\u_comps.u_mult.PRODUCT_R_2.madd_10 [12]),
	.B(\u_comps.u_mult.PRODUCT_R_2.madd_13_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.u_mult.PRODUCT_R_2.madd_13 [12])
);
defparam \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_36_RNO .init=16'h6666;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_2_0_RNIUIEF  (
	.A(\u_comps.u_mult.PRODUCT_R_2.madd_8 [4]),
	.B(\u_comps.u_mult.PRODUCT_R_2.madd_12_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.u_mult.PRODUCT_R_2 [4])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_1_cry_2_0_RNIUIEF .init=16'h6666;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_34_RNO  (
	.A(\u_comps.u_mult.PRODUCT_R_2.madd_0 [10]),
	.B(\u_comps.u_mult.PRODUCT_R_2.madd_10_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.u_mult.PRODUCT_R_2.madd_10 [10])
);
defparam \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_34_RNO .init=16'h6666;
// @7:228
  LUT4 \u_comps.din_w_cZ[11]  (
	.A(cic_data[21]),
	.B(cic_dvalid),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.din_w [11])
);
defparam \u_comps.din_w_cZ[11] .init=16'h8888;
// @7:228
  LUT4 \u_comps.din_w_cZ[10]  (
	.A(cic_data[20]),
	.B(cic_dvalid),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.din_w [10])
);
defparam \u_comps.din_w_cZ[10] .init=16'h8888;
// @7:119
  LUT4 \u_comps.dstart_r_2_cZ[0]  (
	.A(cic_dvalid),
	.B(\u_comps.din_even ),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.dstart_r_2 [0])
);
defparam \u_comps.dstart_r_2_cZ[0] .init=16'h2222;
// @7:192
  LUT4 \u_comps.din_we_cZ  (
	.A(cic_dvalid),
	.B(\u_comps.dvalid_r ),
	.C(VCC),
	.D(VCC),
	.Z(\u_comps.din_we )
);
defparam \u_comps.din_we_cZ .init=16'hEEEE;
// @7:219
  LUT4 \u_comps.data_M_4[15]  (
	.A(\u_comps.data_Lf [15]),
	.B(\u_comps.data_M7f ),
	.C(\u_comps.un3_data_M [15]),
	.D(VCC),
	.Z(\u_comps.data_M [15])
);
defparam \u_comps.data_M_4[15] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[0]  (
	.A(\u_comps.data_Lff [0]),
	.B(\u_comps.data_M7f_0f_fast ),
	.C(\u_comps.un3_data_Mf [0]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [0])
);
defparam \u_comps.data_M_4[0] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[1]  (
	.A(\u_comps.data_Lff [1]),
	.B(\u_comps.data_M7f_0f_fast ),
	.C(\u_comps.un3_data_Mf [1]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [1])
);
defparam \u_comps.data_M_4[1] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[2]  (
	.A(\u_comps.data_Lff [2]),
	.B(\u_comps.data_M7f_0f_fast ),
	.C(\u_comps.un3_data_Mf [2]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [2])
);
defparam \u_comps.data_M_4[2] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[3]  (
	.A(\u_comps.data_Lff [3]),
	.B(\u_comps.data_M7f_0f_fast ),
	.C(\u_comps.un3_data_Mf [3]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [3])
);
defparam \u_comps.data_M_4[3] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[4]  (
	.A(\u_comps.data_Lff [4]),
	.B(\u_comps.data_M7f_0f_fast ),
	.C(\u_comps.un3_data_Mf [4]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [4])
);
defparam \u_comps.data_M_4[4] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[5]  (
	.A(\u_comps.data_Lff [5]),
	.B(\u_comps.data_M7f_0f_fast ),
	.C(\u_comps.un3_data_Mf [5]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [5])
);
defparam \u_comps.data_M_4[5] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[6]  (
	.A(\u_comps.data_Lff [6]),
	.B(\u_comps.data_M7f_0f_rep1 ),
	.C(\u_comps.un3_data_Mf [6]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [6])
);
defparam \u_comps.data_M_4[6] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[7]  (
	.A(\u_comps.data_Lff [7]),
	.B(\u_comps.data_M7f_0f_rep1 ),
	.C(\u_comps.un3_data_Mf [7]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [7])
);
defparam \u_comps.data_M_4[7] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[8]  (
	.A(\u_comps.data_Lff [8]),
	.B(\u_comps.data_M7f_0f_rep1 ),
	.C(\u_comps.un3_data_Mf [8]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [8])
);
defparam \u_comps.data_M_4[8] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[9]  (
	.A(\u_comps.data_Lff [9]),
	.B(\u_comps.data_M7f_0f_rep1 ),
	.C(\u_comps.un3_data_Mf [9]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [9])
);
defparam \u_comps.data_M_4[9] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[10]  (
	.A(\u_comps.data_Lff [10]),
	.B(\u_comps.data_M7f_0f_rep1 ),
	.C(\u_comps.un3_data_Mf [10]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [10])
);
defparam \u_comps.data_M_4[10] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[11]  (
	.A(\u_comps.data_Lff [11]),
	.B(\u_comps.data_M7f_0f_rep1 ),
	.C(\u_comps.un3_data_Mf [11]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [11])
);
defparam \u_comps.data_M_4[11] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[12]  (
	.A(\u_comps.data_Lff [12]),
	.B(\u_comps.data_M7f_0f_rep1 ),
	.C(\u_comps.un3_data_Mf [12]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [12])
);
defparam \u_comps.data_M_4[12] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[13]  (
	.A(\u_comps.data_Lff [13]),
	.B(\u_comps.data_M7f_0f_rep1 ),
	.C(\u_comps.un3_data_Mf [13]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [13])
);
defparam \u_comps.data_M_4[13] .init=16'hB8B8;
// @7:219
  LUT4 \u_comps.data_M_4[14]  (
	.A(\u_comps.data_Lff [14]),
	.B(\u_comps.data_M7f_0f_rep1 ),
	.C(\u_comps.un3_data_Mf [14]),
	.D(VCC),
	.Z(\u_comps.u_mult.DATAA_R [14])
);
defparam \u_comps.data_M_4[14] .init=16'hB8B8;
// @7:228
  LUT4 \u_comps.din_w_cZ[0]  (
	.A(cic_data[0]),
	.B(cic_data[10]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [0])
);
defparam \u_comps.din_w_cZ[0] .init=16'hCACA;
// @7:228
  LUT4 \u_comps.din_w_cZ[1]  (
	.A(cic_data[1]),
	.B(cic_data[11]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [1])
);
defparam \u_comps.din_w_cZ[1] .init=16'hCACA;
// @7:228
  LUT4 \u_comps.din_w_cZ[2]  (
	.A(cic_data[2]),
	.B(cic_data[12]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [2])
);
defparam \u_comps.din_w_cZ[2] .init=16'hCACA;
// @7:228
  LUT4 \u_comps.din_w_cZ[3]  (
	.A(cic_data[3]),
	.B(cic_data[13]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [3])
);
defparam \u_comps.din_w_cZ[3] .init=16'hCACA;
// @7:228
  LUT4 \u_comps.din_w_cZ[4]  (
	.A(cic_data[4]),
	.B(cic_data[14]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [4])
);
defparam \u_comps.din_w_cZ[4] .init=16'hCACA;
// @7:228
  LUT4 \u_comps.din_w_cZ[5]  (
	.A(cic_data[5]),
	.B(cic_data[15]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [5])
);
defparam \u_comps.din_w_cZ[5] .init=16'hCACA;
// @7:228
  LUT4 \u_comps.din_w_cZ[6]  (
	.A(cic_data[6]),
	.B(cic_data[16]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [6])
);
defparam \u_comps.din_w_cZ[6] .init=16'hCACA;
// @7:228
  LUT4 \u_comps.din_w_cZ[7]  (
	.A(cic_data[7]),
	.B(cic_data[17]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [7])
);
defparam \u_comps.din_w_cZ[7] .init=16'hCACA;
// @7:228
  LUT4 \u_comps.din_w_cZ[8]  (
	.A(cic_data[8]),
	.B(cic_data[18]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [8])
);
defparam \u_comps.din_w_cZ[8] .init=16'hCACA;
// @7:228
  LUT4 \u_comps.din_w_cZ[9]  (
	.A(cic_data[9]),
	.B(cic_data[19]),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.din_w [9])
);
defparam \u_comps.din_w_cZ[9] .init=16'hCACA;
// @7:221
  LUT4 \u_comps.data_M7_3_cZ  (
	.A(\u_comps.caddr_r [0]),
	.B(\u_comps.caddr_r [1]),
	.C(\u_comps.caddr_r [4]),
	.D(\u_comps.run_en ),
	.Z(\u_comps.data_M7_3 )
);
defparam \u_comps.data_M7_3_cZ .init=16'h8000;
// @7:334
  LUT4 \u_comps.mac_T_RNO[0]  (
	.A(\u_comps.dstart_r [4]),
	.B(\u_comps.mac_sum_scalar ),
	.C(\u_comps.mult_result [0]),
	.D(VCC),
	.Z(\u_comps.mac_T_4 [0])
);
defparam \u_comps.mac_T_RNO[0] .init=16'hB4B4;
// @7:344
  LUT4 \u_comps.mac_B_RNO[0]  (
	.A(\u_comps.dstart_r [5]),
	.B(\u_comps.mac_B [0]),
	.C(\u_comps.mult_result [0]),
	.D(VCC),
	.Z(\u_comps.mac_B_4 [0])
);
defparam \u_comps.mac_B_RNO[0] .init=16'hB4B4;
// @6:138
  LUT4 \u_cic.PP.PL[3].dout_p[3]_RNO[0]  (
	.A(\u_cic.PP.PL[3].dout_r[3] [0]),
	.B(\u_cic.un13_dout_p_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_cic.un13_dout_p_axb_0_i )
);
defparam \u_cic.PP.PL[3].dout_p[3]_RNO[0] .init=16'h6666;
// @6:138
  LUT4 \u_cic.PP.PL[2].dout_p[2]_RNO[0]  (
	.A(\u_cic.PP.PL[2].dout_r[2] [0]),
	.B(\u_cic.un9_dout_p_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_cic.un9_dout_p_axb_0_i )
);
defparam \u_cic.PP.PL[2].dout_p[2]_RNO[0] .init=16'h6666;
// @6:138
  LUT4 \u_cic.PP.PL[1].dout_p[1]_RNO[0]  (
	.A(\u_cic.PP.PL[1].dout_r[1] [0]),
	.B(\u_cic.un5_dout_p_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_cic.un5_dout_p_axb_0_i )
);
defparam \u_cic.PP.PL[1].dout_p[1]_RNO[0] .init=16'h6666;
// @6:138
  LUT4 \u_cic.PP.PL[0].dout_p[0]_RNO[0]  (
	.A(\u_cic.PP.PL[0].dout_r[0] [0]),
	.B(\u_cic.un11_din_r_scalar ),
	.C(VCC),
	.D(VCC),
	.Z(\u_cic.un1_dout_p_axb_0_i )
);
defparam \u_cic.PP.PL[0].dout_p[0]_RNO[0] .init=16'h6666;
// @7:341
  LUT4 \u_comps.un1_run_even_r_2_cZ  (
	.A(\u_comps.dstart_r [5]),
	.B(\u_comps.run_en_r [3]),
	.C(\u_comps.run_even_r [3]),
	.D(VCC),
	.Z(\u_comps.un1_run_even_r_2 )
);
defparam \u_comps.un1_run_even_r_2_cZ .init=16'hEAEA;
// @7:331
  LUT4 \u_comps.un1_run_en_r_1_cZ  (
	.A(\u_comps.dstart_r [4]),
	.B(\u_comps.run_en_r [3]),
	.C(\u_comps.run_even_r [3]),
	.D(VCC),
	.Z(\u_comps.un1_run_en_r_1 )
);
defparam \u_comps.un1_run_en_r_1_cZ .init=16'hAEAE;
// @8:65
  LUT4 \u_dcc.subi_RNO[0]  (
	.A(dec_data[0]),
	.B(\u_dcc.previ [0]),
	.C(VCC),
	.D(VCC),
	.Z(\u_dcc.un2_subi_axb_0_i )
);
defparam \u_dcc.subi_RNO[0] .init=16'h6666;
// @7:196
  LUT4 \u_comps.raddr_L_lm_0[1]  (
	.A(\u_comps.dstart_r_2 [0]),
	.B(\u_comps.raddr_L_s [1]),
	.C(\u_comps.waddr [1]),
	.D(\u_comps.waddr [2]),
	.Z(\u_comps.raddr_L_lm [1])
);
defparam \u_comps.raddr_L_lm_0[1] .init=16'h4EE4;
// @7:206
  LUT4 \u_comps.raddr_R_lm_0[1]  (
	.A(\u_comps.dstart_r_2 [0]),
	.B(\u_comps.raddr_R_s [1]),
	.C(\u_comps.waddr [1]),
	.D(\u_comps.waddr [2]),
	.Z(\u_comps.raddr_R_lm [1])
);
defparam \u_comps.raddr_R_lm_0[1] .init=16'h4EE4;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_13_0_RNO_0  (
	.A(\u_comps.data_Lff [14]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [1]),
	.D(\u_comps.un3_data_Mf [14]),
	.Z(N_1453)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_13_0_RNO_0 .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_13_0_RNO  (
	.A(\u_comps.data_Lff [0]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [15]),
	.D(\u_comps.un3_data_Mf [0]),
	.Z(N_1451)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_13_0_RNO .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_7_0_RNO_0  (
	.A(\u_comps.data_Lff [8]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [1]),
	.D(\u_comps.un3_data_Mf [8]),
	.Z(N_1405)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_7_0_RNO_0 .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_7_0_RNO  (
	.A(\u_comps.data_Lff [9]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [0]),
	.D(\u_comps.un3_data_Mf [9]),
	.Z(N_1403)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_7_0_RNO .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_9_0_RNO_0  (
	.A(\u_comps.data_Lff [10]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [1]),
	.D(\u_comps.un3_data_Mf [10]),
	.Z(N_1359)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_9_0_RNO_0 .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_9_0_RNO  (
	.A(\u_comps.data_Lff [11]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [0]),
	.D(\u_comps.un3_data_Mf [11]),
	.Z(N_1357)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_9_0_RNO .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_1_0_RNO_0  (
	.A(\u_comps.data_Lff [2]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [1]),
	.D(\u_comps.un3_data_Mf [2]),
	.Z(N_1313)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_1_0_RNO_0 .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_1_0_RNO  (
	.A(\u_comps.data_Lff [3]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [0]),
	.D(\u_comps.un3_data_Mf [3]),
	.Z(N_1311)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_1_0_RNO .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_1_0_RNO_0  (
	.A(\u_comps.data_Lff [4]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [1]),
	.D(\u_comps.un3_data_Mf [4]),
	.Z(N_1267)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_1_0_RNO_0 .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_1_0_RNO  (
	.A(\u_comps.data_Lff [5]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [0]),
	.D(\u_comps.un3_data_Mf [5]),
	.Z(N_1265)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_12_cry_1_0_RNO .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_5_0_RNO_0  (
	.A(\u_comps.data_Lff [6]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [1]),
	.D(\u_comps.un3_data_Mf [6]),
	.Z(N_1221)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_5_0_RNO_0 .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_5_0_RNO  (
	.A(\u_comps.data_Lff [7]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [0]),
	.D(\u_comps.un3_data_Mf [7]),
	.Z(N_1219)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_5_0_RNO .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_11_0_RNO  (
	.A(\u_comps.data_Lff [12]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [1]),
	.D(\u_comps.un3_data_Mf [12]),
	.Z(N_1110)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_11_0_RNO .init=16'hB080;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_11_0_RNO_0  (
	.A(\u_comps.data_Lff [13]),
	.B(\u_comps.data_M7f_0f ),
	.C(\u_comps.u_mult.DATAB_R [0]),
	.D(\u_comps.un3_data_Mf [13]),
	.Z(N_1108)
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_8_cry_11_0_RNO_0 .init=16'hB080;
// @7:221
  LUT4 \u_comps.data_M7_cZ  (
	.A(\u_comps.caddr_r [2]),
	.B(\u_comps.caddr_r [3]),
	.C(\u_comps.data_M7_3 ),
	.D(VCC),
	.Z(\u_comps.data_M7 )
);
defparam \u_comps.data_M7_cZ .init=16'h8080;
// @6:48
  LUT4 \u_comps.un13_dout_en_cZ  (
	.A(\u_comps.caddr [0]),
	.B(\u_comps.caddr [3]),
	.C(\u_comps.caddr [4]),
	.D(\u_comps.un13_dout_en_1 ),
	.Z(\u_comps.un13_dout_en )
);
defparam \u_comps.un13_dout_en_cZ .init=16'h0100;
// @6:48
  LUT4 \u_cic.un10_sample_point  (
	.A(\u_cic.dcnt [1]),
	.B(\u_cic.dcnt [3]),
	.C(\u_cic.dcnt [4]),
	.D(\u_cic.un10_sample_point_1 ),
	.Z(N_1103)
);
defparam \u_cic.un10_sample_point .init=16'h0200;
// @8:85
  LUT4 \u_dcc.subo_RNO[0]  (
	.A(\u_dcc.prevo [0]),
	.B(\u_dcc.prevo [7]),
	.C(\u_dcc.prevo [8]),
	.D(VCC),
	.Z(\u_dcc.un1_subo_axb_0_i )
);
defparam \u_dcc.subo_RNO[0] .init=16'h9696;
// @7:172
  LUT4 \u_comps.caddr_3_cZ[0]  (
	.A(\u_comps.caddr [0]),
	.B(\u_comps.dstart_r_2 [0]),
	.C(\u_comps.run_en ),
	.D(\u_comps.run_even ),
	.Z(\u_comps.caddr_3 [0])
);
defparam \u_comps.caddr_3_cZ[0] .init=16'hDEEE;
// @7:196
  LUT4 \u_comps.raddr_L_lm_0[2]  (
	.A(\u_comps.dstart_r_2 [0]),
	.B(\u_comps.raddr_L_s [2]),
	.C(\u_comps.un2_raddr_L_c2 ),
	.D(\u_comps.waddr [3]),
	.Z(\u_comps.raddr_L_lm [2])
);
defparam \u_comps.raddr_L_lm_0[2] .init=16'h4EE4;
// @7:206
  LUT4 \u_comps.raddr_R_lm_0[2]  (
	.A(\u_comps.dstart_r_2 [0]),
	.B(\u_comps.raddr_R_s [2]),
	.C(\u_comps.un2_raddr_L_c2 ),
	.D(\u_comps.waddr [3]),
	.Z(\u_comps.raddr_R_lm [2])
);
defparam \u_comps.raddr_R_lm_0[2] .init=16'h4EE4;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_0_axb_0  (
	.A(\u_comps.u_mult.DATAA_R [0]),
	.B(\u_comps.u_mult.DATAA_R [1]),
	.C(\u_comps.u_mult.DATAB_R [0]),
	.D(\u_comps.u_mult.DATAB_R [1]),
	.Z(\u_comps.u_mult.PRODUCT_R_2 [1])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_axb_0 .init=16'h6AC0;
// @10:128
  LUT4 \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_1_0_RNIEPN61  (
	.A(\u_comps.u_mult.DATAA_R [2]),
	.B(\u_comps.u_mult.DATAB_R [0]),
	.C(\u_comps.u_mult.PRODUCT_R_2.madd_0 [2]),
	.D(VCC),
	.Z(\u_comps.u_mult.PRODUCT_R_2 [2])
);
defparam \u_comps.u_mult.PRODUCT_R_2.madd_0_cry_1_0_RNIEPN61 .init=16'h7878;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[0]  (
	.A(\u_dcc.sum [0]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [0])
);
defparam \u_dcc.dout_4_cZ[0] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[1]  (
	.A(\u_dcc.sum [1]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [1])
);
defparam \u_dcc.dout_4_cZ[1] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[2]  (
	.A(\u_dcc.sum [2]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [2])
);
defparam \u_dcc.dout_4_cZ[2] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[3]  (
	.A(\u_dcc.sum [3]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [3])
);
defparam \u_dcc.dout_4_cZ[3] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[4]  (
	.A(\u_dcc.sum [4]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [4])
);
defparam \u_dcc.dout_4_cZ[4] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[5]  (
	.A(\u_dcc.sum [5]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [5])
);
defparam \u_dcc.dout_4_cZ[5] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[6]  (
	.A(\u_dcc.sum [6]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [6])
);
defparam \u_dcc.dout_4_cZ[6] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[7]  (
	.A(\u_dcc.sum [7]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [7])
);
defparam \u_dcc.dout_4_cZ[7] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[8]  (
	.A(\u_dcc.sum [8]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [8])
);
defparam \u_dcc.dout_4_cZ[8] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[9]  (
	.A(\u_dcc.sum [9]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [9])
);
defparam \u_dcc.dout_4_cZ[9] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[10]  (
	.A(\u_dcc.sum [10]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [10])
);
defparam \u_dcc.dout_4_cZ[10] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[11]  (
	.A(\u_dcc.sum [11]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [11])
);
defparam \u_dcc.dout_4_cZ[11] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[12]  (
	.A(\u_dcc.sum [12]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [12])
);
defparam \u_dcc.dout_4_cZ[12] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[13]  (
	.A(\u_dcc.sum [13]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [13])
);
defparam \u_dcc.dout_4_cZ[13] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[14]  (
	.A(\u_dcc.sum [14]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [14])
);
defparam \u_dcc.dout_4_cZ[14] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[15]  (
	.A(\u_dcc.sum [15]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [15])
);
defparam \u_dcc.dout_4_cZ[15] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[16]  (
	.A(\u_dcc.sum [16]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [16])
);
defparam \u_dcc.dout_4_cZ[16] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[17]  (
	.A(\u_dcc.sum [17]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [17])
);
defparam \u_dcc.dout_4_cZ[17] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[18]  (
	.A(\u_dcc.sum [18]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [18])
);
defparam \u_dcc.dout_4_cZ[18] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[19]  (
	.A(\u_dcc.sum [19]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [19])
);
defparam \u_dcc.dout_4_cZ[19] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[20]  (
	.A(\u_dcc.sum [20]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [20])
);
defparam \u_dcc.dout_4_cZ[20] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[21]  (
	.A(\u_dcc.sum [21]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [21])
);
defparam \u_dcc.dout_4_cZ[21] .init=16'h8E8E;
// @8:108
  LUT4 \u_dcc.dout_4_cZ[22]  (
	.A(\u_dcc.sum [22]),
	.B(\u_dcc.sum [23]),
	.C(\u_dcc.sum [24]),
	.D(VCC),
	.Z(\u_dcc.dout_4 [22])
);
defparam \u_dcc.dout_4_cZ[22] .init=16'h8E8E;
// @7:166
  LUT4 \u_comps.dout_en_2_cZ[0]  (
	.A(\u_comps.run_en ),
	.B(\u_comps.run_even ),
	.C(\u_comps.un13_dout_en ),
	.D(VCC),
	.Z(\u_comps.dout_en_2 [0])
);
defparam \u_comps.dout_en_2_cZ[0] .init=16'h8080;
// @7:196
  LUT4 \u_comps.raddr_L_lm_0[3]  (
	.A(\u_comps.dstart_r_2 [0]),
	.B(\u_comps.raddr_L_s [3]),
	.C(\u_comps.un2_raddr_L_c3 ),
	.D(\u_comps.waddr [4]),
	.Z(\u_comps.raddr_L_lm [3])
);
defparam \u_comps.raddr_L_lm_0[3] .init=16'h4EE4;
// @7:206
  LUT4 \u_comps.raddr_R_lm_0[3]  (
	.A(\u_comps.dstart_r_2 [0]),
	.B(\u_comps.raddr_R_s [3]),
	.C(\u_comps.un2_raddr_L_c3 ),
	.D(\u_comps.waddr [4]),
	.Z(\u_comps.raddr_R_lm [3])
);
defparam \u_comps.raddr_R_lm_0[3] .init=16'h4EE4;
// @7:355
  LUT4 \u_comps.dout_4_cZ[0]  (
	.A(\u_comps.mac_sum [2]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [0])
);
defparam \u_comps.dout_4_cZ[0] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[1]  (
	.A(\u_comps.mac_sum [3]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [1])
);
defparam \u_comps.dout_4_cZ[1] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[2]  (
	.A(\u_comps.mac_sum [4]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [2])
);
defparam \u_comps.dout_4_cZ[2] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[3]  (
	.A(\u_comps.mac_sum [5]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [3])
);
defparam \u_comps.dout_4_cZ[3] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[4]  (
	.A(\u_comps.mac_sum [6]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [4])
);
defparam \u_comps.dout_4_cZ[4] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[5]  (
	.A(\u_comps.mac_sum [7]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [5])
);
defparam \u_comps.dout_4_cZ[5] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[6]  (
	.A(\u_comps.mac_sum [8]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [6])
);
defparam \u_comps.dout_4_cZ[6] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[7]  (
	.A(\u_comps.mac_sum [9]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [7])
);
defparam \u_comps.dout_4_cZ[7] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[8]  (
	.A(\u_comps.mac_sum [10]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [8])
);
defparam \u_comps.dout_4_cZ[8] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[9]  (
	.A(\u_comps.mac_sum [11]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [9])
);
defparam \u_comps.dout_4_cZ[9] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[10]  (
	.A(\u_comps.mac_sum [12]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [10])
);
defparam \u_comps.dout_4_cZ[10] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[11]  (
	.A(\u_comps.mac_sum [13]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [11])
);
defparam \u_comps.dout_4_cZ[11] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[12]  (
	.A(\u_comps.mac_sum [14]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [12])
);
defparam \u_comps.dout_4_cZ[12] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[13]  (
	.A(\u_comps.mac_sum [15]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [13])
);
defparam \u_comps.dout_4_cZ[13] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[14]  (
	.A(\u_comps.mac_sum [16]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [14])
);
defparam \u_comps.dout_4_cZ[14] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[15]  (
	.A(\u_comps.mac_sum [17]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [15])
);
defparam \u_comps.dout_4_cZ[15] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[16]  (
	.A(\u_comps.mac_sum [18]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [16])
);
defparam \u_comps.dout_4_cZ[16] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[17]  (
	.A(\u_comps.mac_sum [19]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [17])
);
defparam \u_comps.dout_4_cZ[17] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[18]  (
	.A(\u_comps.mac_sum [20]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [18])
);
defparam \u_comps.dout_4_cZ[18] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[19]  (
	.A(\u_comps.mac_sum [21]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [19])
);
defparam \u_comps.dout_4_cZ[19] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[20]  (
	.A(\u_comps.mac_sum [22]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [20])
);
defparam \u_comps.dout_4_cZ[20] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[21]  (
	.A(\u_comps.mac_sum [23]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [21])
);
defparam \u_comps.dout_4_cZ[21] .init=16'h80FE;
// @7:355
  LUT4 \u_comps.dout_4_cZ[22]  (
	.A(\u_comps.mac_sum [24]),
	.B(\u_comps.mac_sum [25]),
	.C(\u_comps.mac_sum [26]),
	.D(\u_comps.mac_sum [27]),
	.Z(\u_comps.dout_4 [22])
);
defparam \u_comps.dout_4_cZ[22] .init=16'h80FE;
// @7:201
  LUT4 \u_comps.un2_raddr_L_axbxc5  (
	.A(\u_comps.un2_raddr_L_c4 ),
	.B(\u_comps.waddr [5]),
	.C(\u_comps.waddr [6]),
	.D(VCC),
	.Z(\u_comps.un2_raddr_L [5])
);
defparam \u_comps.un2_raddr_L_axbxc5 .init=16'h8787;
// @7:196
  LUT4 \u_comps.raddr_L_lm_0[4]  (
	.A(\u_comps.dstart_r_2 [0]),
	.B(\u_comps.raddr_L_s [4]),
	.C(\u_comps.un2_raddr_L_c4 ),
	.D(\u_comps.waddr [5]),
	.Z(\u_comps.raddr_L_lm [4])
);
defparam \u_comps.raddr_L_lm_0[4] .init=16'h4EE4;
// @7:206
  LUT4 \u_comps.raddr_R_lm_0[4]  (
	.A(\u_comps.dstart_r_2 [0]),
	.B(\u_comps.raddr_R_s [4]),
	.C(\u_comps.un2_raddr_L_c4 ),
	.D(\u_comps.waddr [5]),
	.Z(\u_comps.raddr_R_lm [4])
);
defparam \u_comps.raddr_R_lm_0[4] .init=16'h4EE4;
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[21]  (
	.D(\u_cic.INTA[0].din_r[0]_s [21]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [21])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[20]  (
	.D(\u_cic.INTA[0].din_r[0]_s [20]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [20])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[19]  (
	.D(\u_cic.INTA[0].din_r[0]_s [19]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [19])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[18]  (
	.D(\u_cic.INTA[0].din_r[0]_s [18]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [18])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[17]  (
	.D(\u_cic.INTA[0].din_r[0]_s [17]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [17])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[16]  (
	.D(\u_cic.INTA[0].din_r[0]_s [16]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [16])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[15]  (
	.D(\u_cic.INTA[0].din_r[0]_s [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [15])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[14]  (
	.D(\u_cic.INTA[0].din_r[0]_s [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [14])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[13]  (
	.D(\u_cic.INTA[0].din_r[0]_s [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [13])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[12]  (
	.D(\u_cic.INTA[0].din_r[0]_s [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [12])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[11]  (
	.D(\u_cic.INTA[0].din_r[0]_s [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [11])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[10]  (
	.D(\u_cic.INTA[0].din_r[0]_s [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [10])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[9]  (
	.D(\u_cic.INTA[0].din_r[0]_s [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [9])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[8]  (
	.D(\u_cic.INTA[0].din_r[0]_s [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [8])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[7]  (
	.D(\u_cic.INTA[0].din_r[0]_s [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [7])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[6]  (
	.D(\u_cic.INTA[0].din_r[0]_s [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [6])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[5]  (
	.D(\u_cic.INTA[0].din_r[0]_s [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [5])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[4]  (
	.D(\u_cic.INTA[0].din_r[0]_s [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [4])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[3]  (
	.D(\u_cic.INTA[0].din_r[0]_s [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [3])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[2]  (
	.D(\u_cic.INTA[0].din_r[0]_s [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [2])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[1]  (
	.D(\u_cic.INTA[0].din_r[0]_s [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [1])
);
// @6:73
  FD1S3DX \u_cic.INTA[0].din_r[0]_reg[0]  (
	.D(\u_cic.INTA[0].din_r[0]_s [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[0].din_r[0] [0])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[21]  (
	.D(\u_cic.un5_din_r [21]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [21])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[20]  (
	.D(\u_cic.un5_din_r [20]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [20])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[19]  (
	.D(\u_cic.un5_din_r [19]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [19])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[18]  (
	.D(\u_cic.un5_din_r [18]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [18])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[17]  (
	.D(\u_cic.un5_din_r [17]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [17])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[16]  (
	.D(\u_cic.un5_din_r [16]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [16])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[15]  (
	.D(\u_cic.un5_din_r [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [15])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[14]  (
	.D(\u_cic.un5_din_r [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [14])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[13]  (
	.D(\u_cic.un5_din_r [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [13])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[12]  (
	.D(\u_cic.un5_din_r [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [12])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[11]  (
	.D(\u_cic.un5_din_r [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [11])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[10]  (
	.D(\u_cic.un5_din_r [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [10])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[9]  (
	.D(\u_cic.un5_din_r [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [9])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[8]  (
	.D(\u_cic.un5_din_r [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [8])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[7]  (
	.D(\u_cic.un5_din_r [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [7])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[6]  (
	.D(\u_cic.un5_din_r [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [6])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[5]  (
	.D(\u_cic.un5_din_r [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [5])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[4]  (
	.D(\u_cic.un5_din_r [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [4])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[3]  (
	.D(\u_cic.un5_din_r [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [3])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[2]  (
	.D(\u_cic.un5_din_r [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [2])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1]_reg[1]  (
	.D(\u_cic.un5_din_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[1].din_r[1] [1])
);
// @6:73
  FD1S3DX \u_cic.INTA[1].din_r[1][0]  (
	.D(\u_cic.un5_din_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.un5_din_r_scalar )
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[21]  (
	.D(\u_cic.un8_din_r [21]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [21])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[20]  (
	.D(\u_cic.un8_din_r [20]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [20])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[19]  (
	.D(\u_cic.un8_din_r [19]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [19])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[18]  (
	.D(\u_cic.un8_din_r [18]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [18])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[17]  (
	.D(\u_cic.un8_din_r [17]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [17])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[16]  (
	.D(\u_cic.un8_din_r [16]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [16])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[15]  (
	.D(\u_cic.un8_din_r [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [15])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[14]  (
	.D(\u_cic.un8_din_r [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [14])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[13]  (
	.D(\u_cic.un8_din_r [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [13])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[12]  (
	.D(\u_cic.un8_din_r [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [12])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[11]  (
	.D(\u_cic.un8_din_r [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [11])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[10]  (
	.D(\u_cic.un8_din_r [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [10])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[9]  (
	.D(\u_cic.un8_din_r [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [9])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[8]  (
	.D(\u_cic.un8_din_r [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [8])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[7]  (
	.D(\u_cic.un8_din_r [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [7])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[6]  (
	.D(\u_cic.un8_din_r [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [6])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[5]  (
	.D(\u_cic.un8_din_r [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [5])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[4]  (
	.D(\u_cic.un8_din_r [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [4])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[3]  (
	.D(\u_cic.un8_din_r [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [3])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[2]  (
	.D(\u_cic.un8_din_r [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [2])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2]_reg[1]  (
	.D(\u_cic.un8_din_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[2].din_r[2] [1])
);
// @6:73
  FD1S3DX \u_cic.INTA[2].din_r[2][0]  (
	.D(\u_cic.un8_din_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.un8_din_r_scalar )
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[21]  (
	.D(\u_cic.un11_din_r [21]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [21])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[20]  (
	.D(\u_cic.un11_din_r [20]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [20])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[19]  (
	.D(\u_cic.un11_din_r [19]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [19])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[18]  (
	.D(\u_cic.un11_din_r [18]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [18])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[17]  (
	.D(\u_cic.un11_din_r [17]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [17])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[16]  (
	.D(\u_cic.un11_din_r [16]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [16])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[15]  (
	.D(\u_cic.un11_din_r [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [15])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[14]  (
	.D(\u_cic.un11_din_r [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [14])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[13]  (
	.D(\u_cic.un11_din_r [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [13])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[12]  (
	.D(\u_cic.un11_din_r [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [12])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[11]  (
	.D(\u_cic.un11_din_r [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [11])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[10]  (
	.D(\u_cic.un11_din_r [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [10])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[9]  (
	.D(\u_cic.un11_din_r [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [9])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[8]  (
	.D(\u_cic.un11_din_r [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [8])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[7]  (
	.D(\u_cic.un11_din_r [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [7])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[6]  (
	.D(\u_cic.un11_din_r [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [6])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[5]  (
	.D(\u_cic.un11_din_r [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [5])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[4]  (
	.D(\u_cic.un11_din_r [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [4])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[3]  (
	.D(\u_cic.un11_din_r [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [3])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[2]  (
	.D(\u_cic.un11_din_r [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [2])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3]_reg[1]  (
	.D(\u_cic.un11_din_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.INTA[3].din_r[3] [1])
);
// @6:73
  FD1S3DX \u_cic.INTA[3].din_r[3][0]  (
	.D(\u_cic.un11_din_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.un11_din_r_scalar )
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[21]  (
	.D(\u_cic.un1_dout_p [21]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [21])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[20]  (
	.D(\u_cic.un1_dout_p [20]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [20])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[19]  (
	.D(\u_cic.un1_dout_p [19]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [19])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[18]  (
	.D(\u_cic.un1_dout_p [18]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [18])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[17]  (
	.D(\u_cic.un1_dout_p [17]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [17])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[16]  (
	.D(\u_cic.un1_dout_p [16]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [16])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[15]  (
	.D(\u_cic.un1_dout_p [15]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [15])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[14]  (
	.D(\u_cic.un1_dout_p [14]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [14])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[13]  (
	.D(\u_cic.un1_dout_p [13]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [13])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[12]  (
	.D(\u_cic.un1_dout_p [12]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [12])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[11]  (
	.D(\u_cic.un1_dout_p [11]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [11])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[10]  (
	.D(\u_cic.un1_dout_p [10]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [10])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[9]  (
	.D(\u_cic.un1_dout_p [9]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [9])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[8]  (
	.D(\u_cic.un1_dout_p [8]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [8])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[7]  (
	.D(\u_cic.un1_dout_p [7]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [7])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[6]  (
	.D(\u_cic.un1_dout_p [6]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [6])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[5]  (
	.D(\u_cic.un1_dout_p [5]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [5])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[4]  (
	.D(\u_cic.un1_dout_p [4]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [4])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[3]  (
	.D(\u_cic.un1_dout_p [3]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [3])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[2]  (
	.D(\u_cic.un1_dout_p [2]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [2])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0]_reg[1]  (
	.D(\u_cic.un1_dout_p [1]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_p[0] [1])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[0].dout_p[0][0]  (
	.D(\u_cic.un1_dout_p_axb_0_i ),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.un5_dout_p_scalar )
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[21]  (
	.D(\u_cic.INTA[3].din_r[3] [21]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [21])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[20]  (
	.D(\u_cic.INTA[3].din_r[3] [20]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [20])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[19]  (
	.D(\u_cic.INTA[3].din_r[3] [19]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [19])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[18]  (
	.D(\u_cic.INTA[3].din_r[3] [18]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [18])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[17]  (
	.D(\u_cic.INTA[3].din_r[3] [17]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [17])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[16]  (
	.D(\u_cic.INTA[3].din_r[3] [16]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [16])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[15]  (
	.D(\u_cic.INTA[3].din_r[3] [15]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [15])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[14]  (
	.D(\u_cic.INTA[3].din_r[3] [14]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [14])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[13]  (
	.D(\u_cic.INTA[3].din_r[3] [13]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [13])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[12]  (
	.D(\u_cic.INTA[3].din_r[3] [12]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [12])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[11]  (
	.D(\u_cic.INTA[3].din_r[3] [11]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [11])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[10]  (
	.D(\u_cic.INTA[3].din_r[3] [10]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [10])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[9]  (
	.D(\u_cic.INTA[3].din_r[3] [9]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [9])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[8]  (
	.D(\u_cic.INTA[3].din_r[3] [8]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [8])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[7]  (
	.D(\u_cic.INTA[3].din_r[3] [7]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [7])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[6]  (
	.D(\u_cic.INTA[3].din_r[3] [6]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [6])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[5]  (
	.D(\u_cic.INTA[3].din_r[3] [5]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [5])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[4]  (
	.D(\u_cic.INTA[3].din_r[3] [4]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [4])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[3]  (
	.D(\u_cic.INTA[3].din_r[3] [3]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [3])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[2]  (
	.D(\u_cic.INTA[3].din_r[3] [2]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [2])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[1]  (
	.D(\u_cic.INTA[3].din_r[3] [1]),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [1])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[0].dout_r[0]_reg[0]  (
	.D(\u_cic.un11_din_r_scalar ),
	.SP(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[0].dout_r[0] [0])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[21]  (
	.D(\u_cic.un5_dout_p [21]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [21])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[20]  (
	.D(\u_cic.un5_dout_p [20]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [20])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[19]  (
	.D(\u_cic.un5_dout_p [19]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [19])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[18]  (
	.D(\u_cic.un5_dout_p [18]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [18])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[17]  (
	.D(\u_cic.un5_dout_p [17]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [17])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[16]  (
	.D(\u_cic.un5_dout_p [16]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [16])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[15]  (
	.D(\u_cic.un5_dout_p [15]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [15])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[14]  (
	.D(\u_cic.un5_dout_p [14]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [14])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[13]  (
	.D(\u_cic.un5_dout_p [13]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [13])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[12]  (
	.D(\u_cic.un5_dout_p [12]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [12])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[11]  (
	.D(\u_cic.un5_dout_p [11]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [11])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[10]  (
	.D(\u_cic.un5_dout_p [10]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [10])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[9]  (
	.D(\u_cic.un5_dout_p [9]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [9])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[8]  (
	.D(\u_cic.un5_dout_p [8]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [8])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[7]  (
	.D(\u_cic.un5_dout_p [7]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [7])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[6]  (
	.D(\u_cic.un5_dout_p [6]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [6])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[5]  (
	.D(\u_cic.un5_dout_p [5]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [5])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[4]  (
	.D(\u_cic.un5_dout_p [4]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [4])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[3]  (
	.D(\u_cic.un5_dout_p [3]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [3])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[2]  (
	.D(\u_cic.un5_dout_p [2]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [2])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1]_reg[1]  (
	.D(\u_cic.un5_dout_p [1]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_p[1] [1])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[1].dout_p[1][0]  (
	.D(\u_cic.un5_dout_p_axb_0_i ),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.un9_dout_p_scalar )
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[21]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [21]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [21])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[20]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [20]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [20])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[19]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [19]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [19])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[18]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [18]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [18])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[17]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [17]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [17])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[16]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [16]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [16])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[15]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [15]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [15])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[14]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [14]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [14])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[13]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [13]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [13])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[12]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [12]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [12])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[11]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [11]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [11])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[10]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [10]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [10])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[9]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [9]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [9])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[8]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [8]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [8])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[7]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [7]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [7])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[6]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [6]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [6])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[5]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [5]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [5])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[4]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [4]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [4])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[3]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [3]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [3])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[2]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [2]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [2])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[1]  (
	.D(\u_cic.PP.PL[0].dout_p[0] [1]),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [1])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[1].dout_r[1]_reg[0]  (
	.D(\u_cic.un5_dout_p_scalar ),
	.SP(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[1].dout_r[1] [0])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[21]  (
	.D(\u_cic.un9_dout_p [21]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [21])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[20]  (
	.D(\u_cic.un9_dout_p [20]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [20])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[19]  (
	.D(\u_cic.un9_dout_p [19]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [19])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[18]  (
	.D(\u_cic.un9_dout_p [18]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [18])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[17]  (
	.D(\u_cic.un9_dout_p [17]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [17])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[16]  (
	.D(\u_cic.un9_dout_p [16]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [16])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[15]  (
	.D(\u_cic.un9_dout_p [15]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [15])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[14]  (
	.D(\u_cic.un9_dout_p [14]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [14])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[13]  (
	.D(\u_cic.un9_dout_p [13]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [13])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[12]  (
	.D(\u_cic.un9_dout_p [12]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [12])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[11]  (
	.D(\u_cic.un9_dout_p [11]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [11])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[10]  (
	.D(\u_cic.un9_dout_p [10]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [10])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[9]  (
	.D(\u_cic.un9_dout_p [9]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [9])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[8]  (
	.D(\u_cic.un9_dout_p [8]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [8])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[7]  (
	.D(\u_cic.un9_dout_p [7]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [7])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[6]  (
	.D(\u_cic.un9_dout_p [6]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [6])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[5]  (
	.D(\u_cic.un9_dout_p [5]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [5])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[4]  (
	.D(\u_cic.un9_dout_p [4]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [4])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[3]  (
	.D(\u_cic.un9_dout_p [3]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [3])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[2]  (
	.D(\u_cic.un9_dout_p [2]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [2])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2]_reg[1]  (
	.D(\u_cic.un9_dout_p [1]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_p[2] [1])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[2].dout_p[2][0]  (
	.D(\u_cic.un9_dout_p_axb_0_i ),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.un13_dout_p_scalar )
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[21]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [21]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [21])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[20]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [20]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [20])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[19]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [19]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [19])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[18]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [18]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [18])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[17]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [17]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [17])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[16]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [16]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [16])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[15]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [15]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [15])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[14]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [14]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [14])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[13]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [13]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [13])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[12]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [12]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [12])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[11]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [11]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [11])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[10]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [10]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [10])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[9]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [9]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [9])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[8]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [8]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [8])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[7]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [7]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [7])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[6]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [6]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [6])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[5]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [5]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [5])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[4]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [4]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [4])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[3]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [3]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [3])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[2]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [2]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [2])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[1]  (
	.D(\u_cic.PP.PL[1].dout_p[1] [1]),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [1])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[2].dout_r[2]_reg[0]  (
	.D(\u_cic.un9_dout_p_scalar ),
	.SP(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[2].dout_r[2] [0])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][21]  (
	.D(\u_cic.un13_dout_p [21]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[21])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][20]  (
	.D(\u_cic.un13_dout_p [20]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[20])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][19]  (
	.D(\u_cic.un13_dout_p [19]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[19])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][18]  (
	.D(\u_cic.un13_dout_p [18]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[18])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][17]  (
	.D(\u_cic.un13_dout_p [17]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[17])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][16]  (
	.D(\u_cic.un13_dout_p [16]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[16])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][15]  (
	.D(\u_cic.un13_dout_p [15]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[15])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][14]  (
	.D(\u_cic.un13_dout_p [14]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[14])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][13]  (
	.D(\u_cic.un13_dout_p [13]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[13])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][12]  (
	.D(\u_cic.un13_dout_p [12]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[12])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][11]  (
	.D(\u_cic.un13_dout_p [11]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[11])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][10]  (
	.D(\u_cic.un13_dout_p [10]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[10])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][9]  (
	.D(\u_cic.un13_dout_p [9]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[9])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][8]  (
	.D(\u_cic.un13_dout_p [8]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[8])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][7]  (
	.D(\u_cic.un13_dout_p [7]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[7])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][6]  (
	.D(\u_cic.un13_dout_p [6]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[6])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][5]  (
	.D(\u_cic.un13_dout_p [5]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[5])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][4]  (
	.D(\u_cic.un13_dout_p [4]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[4])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][3]  (
	.D(\u_cic.un13_dout_p [3]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[3])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][2]  (
	.D(\u_cic.un13_dout_p [2]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[2])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][1]  (
	.D(\u_cic.un13_dout_p [1]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[1])
);
// @6:138
  FD1P3DX \u_cic.PP.PL[3].dout_p[3][0]  (
	.D(\u_cic.un13_dout_p_axb_0_i ),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_data[0])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[21]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [21]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [21])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[20]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [20]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [20])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[19]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [19]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [19])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[18]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [18]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [18])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[17]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [17]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [17])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[16]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [16]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [16])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[15]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [15]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [15])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[14]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [14]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [14])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[13]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [13]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [13])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[12]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [12]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [12])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[11]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [11]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [11])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[10]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [10]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [10])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[9]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [9]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [9])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[8]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [8]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [8])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[7]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [7]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [7])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[6]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [6]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [6])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[5]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [5]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [5])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[4]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [4]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [4])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[3]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [3]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [3])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[2]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [2]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [2])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[1]  (
	.D(\u_cic.PP.PL[2].dout_p[2] [1]),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [1])
);
// @6:130
  FD1P3DX \u_cic.PP.PL[3].dout_r[3]_reg[0]  (
	.D(\u_cic.un13_dout_p_scalar ),
	.SP(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.PP.PL[3].dout_r[3] [0])
);
// @6:87
  FD1S3DX \u_cic.dcnt_reg[4]  (
	.D(\u_cic.dcnt_s [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.dcnt [4])
);
// @6:87
  FD1S3DX \u_cic.dcnt_reg[3]  (
	.D(\u_cic.dcnt_s [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.dcnt [3])
);
// @6:87
  FD1S3DX \u_cic.dcnt_reg[2]  (
	.D(\u_cic.dcnt_s [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.dcnt [2])
);
// @6:87
  FD1S3DX \u_cic.dcnt_reg[1]  (
	.D(\u_cic.dcnt_s [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.dcnt [1])
);
// @6:87
  FD1S3DX \u_cic.dcnt_reg[0]  (
	.D(\u_cic.dcnt_s [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.dcnt [0])
);
// @6:96
  FD1S3DX \u_cic.samp_en[4]  (
	.D(\u_cic.samp_en [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(cic_dvalid)
);
// @6:96
  FD1S3DX \u_cic.samp_en_reg[3]  (
	.D(\u_cic.samp_en [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.samp_en [3])
);
// @6:96
  FD1S3DX \u_cic.samp_en_reg[2]  (
	.D(\u_cic.samp_en [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.samp_en [2])
);
// @6:96
  FD1S3DX \u_cic.samp_en_reg[1]  (
	.D(\u_cic.samp_en [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.samp_en [1])
);
// @6:96
  FD1S3DX \u_cic.samp_en_reg[0]  (
	.D(N_1103),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_cic.samp_en [0])
);
  FD1S3DX \u_comps.DATAA_R_pipe  (
	.D(\u_comps.un3_data_M [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [0])
);
  FD1S3DX \u_comps.DATAA_R_pipe_1  (
	.D(\u_comps.data_Lf [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [0])
);
  FD1S3DX \u_comps.DATAA_R_pipe_10  (
	.D(\u_comps.data_Lf [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [3])
);
  FD1S3DX \u_comps.DATAA_R_pipe_12  (
	.D(\u_comps.un3_data_M [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [4])
);
  FD1S3DX \u_comps.DATAA_R_pipe_13  (
	.D(\u_comps.data_Lf [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [4])
);
  FD1S3DX \u_comps.DATAA_R_pipe_15  (
	.D(\u_comps.un3_data_M [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [5])
);
  FD1S3DX \u_comps.DATAA_R_pipe_16  (
	.D(\u_comps.data_Lf [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [5])
);
  FD1S3DX \u_comps.DATAA_R_pipe_18  (
	.D(\u_comps.un3_data_M [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [6])
);
  FD1S3DX \u_comps.DATAA_R_pipe_19  (
	.D(\u_comps.data_Lf [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [6])
);
  FD1S3DX \u_comps.DATAA_R_pipe_2  (
	.D(\u_comps.data_M7f ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_M7f_0f )
);
  FD1S3DX \u_comps.DATAA_R_pipe_21  (
	.D(\u_comps.un3_data_M [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [7])
);
  FD1S3DX \u_comps.DATAA_R_pipe_22  (
	.D(\u_comps.data_Lf [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [7])
);
  FD1S3DX \u_comps.DATAA_R_pipe_24  (
	.D(\u_comps.un3_data_M [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [8])
);
  FD1S3DX \u_comps.DATAA_R_pipe_25  (
	.D(\u_comps.data_Lf [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [8])
);
  FD1S3DX \u_comps.DATAA_R_pipe_27  (
	.D(\u_comps.un3_data_M [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [9])
);
  FD1S3DX \u_comps.DATAA_R_pipe_28  (
	.D(\u_comps.data_Lf [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [9])
);
  FD1S3DX \u_comps.DATAA_R_pipe_2_fast  (
	.D(\u_comps.data_M7f ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_M7f_0f_fast )
);
  FD1S3DX \u_comps.DATAA_R_pipe_2_rep1  (
	.D(\u_comps.data_M7f ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_M7f_0f_rep1 )
);
  FD1S3DX \u_comps.DATAA_R_pipe_3  (
	.D(\u_comps.un3_data_M [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [1])
);
  FD1S3DX \u_comps.DATAA_R_pipe_30  (
	.D(\u_comps.un3_data_M [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [10])
);
  FD1S3DX \u_comps.DATAA_R_pipe_31  (
	.D(\u_comps.data_Lf [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [10])
);
  FD1S3DX \u_comps.DATAA_R_pipe_33  (
	.D(\u_comps.un3_data_M [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [11])
);
  FD1S3DX \u_comps.DATAA_R_pipe_34  (
	.D(\u_comps.data_Lf [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [11])
);
  FD1S3DX \u_comps.DATAA_R_pipe_36  (
	.D(\u_comps.un3_data_M [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [12])
);
  FD1S3DX \u_comps.DATAA_R_pipe_37  (
	.D(\u_comps.data_Lf [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [12])
);
  FD1S3DX \u_comps.DATAA_R_pipe_39  (
	.D(\u_comps.un3_data_M [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [13])
);
  FD1S3DX \u_comps.DATAA_R_pipe_4  (
	.D(\u_comps.data_Lf [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [1])
);
  FD1S3DX \u_comps.DATAA_R_pipe_40  (
	.D(\u_comps.data_Lf [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [13])
);
  FD1S3DX \u_comps.DATAA_R_pipe_42  (
	.D(\u_comps.un3_data_M [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [14])
);
  FD1S3DX \u_comps.DATAA_R_pipe_43  (
	.D(\u_comps.data_Lf [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [14])
);
  FD1S3DX \u_comps.DATAA_R_pipe_6  (
	.D(\u_comps.un3_data_M [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [2])
);
  FD1S3DX \u_comps.DATAA_R_pipe_7  (
	.D(\u_comps.data_Lf [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lff [2])
);
  FD1S3DX \u_comps.DATAA_R_pipe_9  (
	.D(\u_comps.un3_data_M [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.un3_data_Mf [3])
);
// @7:170
  FD1S3BX \u_comps.caddr_reg[4]  (
	.D(\u_comps.caddr_3 [4]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr [4])
);
// @7:180
  FD1S3BX \u_comps.caddr_r_reg[4]  (
	.D(\u_comps.caddr [4]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr_r [4])
);
// @7:180
  FD1S3BX \u_comps.caddr_r_reg[3]  (
	.D(\u_comps.caddr [3]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr_r [3])
);
// @7:170
  FD1S3BX \u_comps.caddr_reg[3]  (
	.D(\u_comps.caddr_3 [3]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr [3])
);
// @7:180
  FD1S3BX \u_comps.caddr_r_reg[2]  (
	.D(\u_comps.caddr [2]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr_r [2])
);
// @7:170
  FD1S3BX \u_comps.caddr_reg[2]  (
	.D(\u_comps.caddr_3 [2]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr [2])
);
// @7:170
  FD1S3BX \u_comps.caddr_reg[1]  (
	.D(\u_comps.caddr_3 [1]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr [1])
);
// @7:180
  FD1S3BX \u_comps.caddr_r_reg[1]  (
	.D(\u_comps.caddr [1]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr_r [1])
);
// @7:170
  FD1S3BX \u_comps.caddr_reg[0]  (
	.D(\u_comps.caddr_3 [0]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr [0])
);
// @7:180
  FD1S3BX \u_comps.caddr_r_reg[0]  (
	.D(\u_comps.caddr [0]),
	.CK(pdm_clk),
	.PD(pdm_rst),
	.Q(\u_comps.caddr_r [0])
);
  FD1S3DX \u_comps.data_M_pipe_1  (
	.D(\u_comps.data_L [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [15])
);
  FD1S3DX \u_comps.data_M_pipe_10  (
	.D(\u_comps.data_L [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [8])
);
  FD1S3DX \u_comps.data_M_pipe_11  (
	.D(\u_comps.data_L [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [7])
);
  FD1S3DX \u_comps.data_M_pipe_12  (
	.D(\u_comps.data_L [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [6])
);
  FD1S3DX \u_comps.data_M_pipe_13  (
	.D(\u_comps.data_L [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [5])
);
  FD1S3DX \u_comps.data_M_pipe_14  (
	.D(\u_comps.data_L [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [4])
);
  FD1S3DX \u_comps.data_M_pipe_15  (
	.D(\u_comps.data_L [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [3])
);
  FD1S3DX \u_comps.data_M_pipe_16  (
	.D(\u_comps.data_L [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [2])
);
  FD1S3DX \u_comps.data_M_pipe_17  (
	.D(\u_comps.data_L [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [1])
);
  FD1S3DX \u_comps.data_M_pipe_18  (
	.D(\u_comps.data_L [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [0])
);
  FD1S3DX \u_comps.data_M_pipe_2  (
	.D(\u_comps.data_M7 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_M7f )
);
  FD1S3DX \u_comps.data_M_pipe_20  (
	.D(\u_comps.data_R [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [0])
);
  FD1S3DX \u_comps.data_M_pipe_21  (
	.D(\u_comps.data_R [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [1])
);
  FD1S3DX \u_comps.data_M_pipe_22  (
	.D(\u_comps.data_R [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [2])
);
  FD1S3DX \u_comps.data_M_pipe_23  (
	.D(\u_comps.data_R [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [3])
);
  FD1S3DX \u_comps.data_M_pipe_24  (
	.D(\u_comps.data_R [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [4])
);
  FD1S3DX \u_comps.data_M_pipe_25  (
	.D(\u_comps.data_R [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [5])
);
  FD1S3DX \u_comps.data_M_pipe_26  (
	.D(\u_comps.data_R [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [6])
);
  FD1S3DX \u_comps.data_M_pipe_27  (
	.D(\u_comps.data_R [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [7])
);
  FD1S3DX \u_comps.data_M_pipe_28  (
	.D(\u_comps.data_R [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [8])
);
  FD1S3DX \u_comps.data_M_pipe_29  (
	.D(\u_comps.data_R [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [9])
);
  FD1S3DX \u_comps.data_M_pipe_3  (
	.D(\u_comps.data_L [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [14])
);
  FD1S3DX \u_comps.data_M_pipe_30  (
	.D(\u_comps.data_R [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [10])
);
  FD1S3DX \u_comps.data_M_pipe_31  (
	.D(\u_comps.data_R [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [11])
);
  FD1S3DX \u_comps.data_M_pipe_32  (
	.D(\u_comps.data_R [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [12])
);
  FD1S3DX \u_comps.data_M_pipe_33  (
	.D(\u_comps.data_R [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [13])
);
  FD1S3DX \u_comps.data_M_pipe_34  (
	.D(\u_comps.data_R [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [14])
);
  FD1S3DX \u_comps.data_M_pipe_35  (
	.D(\u_comps.data_R [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Rf [15])
);
  FD1S3DX \u_comps.data_M_pipe_5  (
	.D(\u_comps.data_L [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [13])
);
  FD1S3DX \u_comps.data_M_pipe_6  (
	.D(\u_comps.data_L [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [12])
);
  FD1S3DX \u_comps.data_M_pipe_7  (
	.D(\u_comps.data_L [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [11])
);
  FD1S3DX \u_comps.data_M_pipe_8  (
	.D(\u_comps.data_L [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [10])
);
  FD1S3DX \u_comps.data_M_pipe_9  (
	.D(\u_comps.data_L [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.data_Lf [9])
);
// @7:105
  FD1S3DX \u_comps.din_even_reg  (
	.D(N_4486),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.din_even )
);
// @7:349
  FD1P3DX \u_comps.dout[23]  (
	.D(\u_comps.mac_sum [27]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[23])
);
// @7:349
  FD1P3DX \u_comps.dout[22]  (
	.D(\u_comps.dout_4 [22]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[22])
);
// @7:349
  FD1P3DX \u_comps.dout[21]  (
	.D(\u_comps.dout_4 [21]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[21])
);
// @7:349
  FD1P3DX \u_comps.dout[20]  (
	.D(\u_comps.dout_4 [20]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[20])
);
// @7:349
  FD1P3DX \u_comps.dout[19]  (
	.D(\u_comps.dout_4 [19]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[19])
);
// @7:349
  FD1P3DX \u_comps.dout[18]  (
	.D(\u_comps.dout_4 [18]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[18])
);
// @7:349
  FD1P3DX \u_comps.dout[17]  (
	.D(\u_comps.dout_4 [17]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[17])
);
// @7:349
  FD1P3DX \u_comps.dout[16]  (
	.D(\u_comps.dout_4 [16]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[16])
);
// @7:349
  FD1P3DX \u_comps.dout[15]  (
	.D(\u_comps.dout_4 [15]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[15])
);
// @7:349
  FD1P3DX \u_comps.dout[14]  (
	.D(\u_comps.dout_4 [14]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[14])
);
// @7:349
  FD1P3DX \u_comps.dout[13]  (
	.D(\u_comps.dout_4 [13]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[13])
);
// @7:349
  FD1P3DX \u_comps.dout[12]  (
	.D(\u_comps.dout_4 [12]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[12])
);
// @7:349
  FD1P3DX \u_comps.dout[11]  (
	.D(\u_comps.dout_4 [11]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[11])
);
// @7:349
  FD1P3DX \u_comps.dout[10]  (
	.D(\u_comps.dout_4 [10]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[10])
);
// @7:349
  FD1P3DX \u_comps.dout[9]  (
	.D(\u_comps.dout_4 [9]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[9])
);
// @7:349
  FD1P3DX \u_comps.dout[8]  (
	.D(\u_comps.dout_4 [8]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[8])
);
// @7:349
  FD1P3DX \u_comps.dout[7]  (
	.D(\u_comps.dout_4 [7]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[7])
);
// @7:349
  FD1P3DX \u_comps.dout[6]  (
	.D(\u_comps.dout_4 [6]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[6])
);
// @7:349
  FD1P3DX \u_comps.dout[5]  (
	.D(\u_comps.dout_4 [5]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[5])
);
// @7:161
  FD1S3DX \u_comps.dout_en[5]  (
	.D(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_dvalid)
);
// @7:161
  FD1S3DX \u_comps.dout_en_0[4]  (
	.D(N_4903),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.dout_en [4])
);
// @7:349
  FD1P3DX \u_comps.dout[4]  (
	.D(\u_comps.dout_4 [4]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[4])
);
// @7:161
  FD1S3DX \u_comps.dout_en[3]  (
	.D(N_4902),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(N_4903)
);
// @7:349
  FD1P3DX \u_comps.dout[3]  (
	.D(\u_comps.dout_4 [3]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[3])
);
// @7:161
  FD1S3DX \u_comps.dout_en[2]  (
	.D(N_4901),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(N_4902)
);
// @7:349
  FD1P3DX \u_comps.dout[2]  (
	.D(\u_comps.dout_4 [2]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[2])
);
// @7:161
  FD1S3DX \u_comps.dout_en[1]  (
	.D(N_4900),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(N_4901)
);
// @7:349
  FD1P3DX \u_comps.dout[1]  (
	.D(\u_comps.dout_4 [1]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[1])
);
// @7:349
  FD1P3DX \u_comps.dout[0]  (
	.D(\u_comps.dout_4 [0]),
	.SP(\u_comps.dout_en [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(dec_data[0])
);
// @7:161
  FD1S3DX \u_comps.dout_en[0]  (
	.D(\u_comps.dout_en_2 [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(N_4900)
);
// @7:114
  FD1S3DX \u_comps.dstart_r_reg[5]  (
	.D(\u_comps.dstart_r [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.dstart_r [5])
);
// @7:114
  FD1S3DX \u_comps.dstart_r_0[4]  (
	.D(N_4895),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.dstart_r [4])
);
// @7:114
  FD1S3DX \u_comps.dstart_r[3]  (
	.D(N_4894),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(N_4895)
);
// @7:114
  FD1S3DX \u_comps.dstart_r[2]  (
	.D(N_4893),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(N_4894)
);
// @7:114
  FD1S3DX \u_comps.dstart_r[1]  (
	.D(N_4892),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(N_4893)
);
// @7:114
  FD1S3DX \u_comps.dstart_r[0]  (
	.D(\u_comps.dstart_r_2 [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(N_4892)
);
// @7:122
  FD1S3DX \u_comps.dvalid_r_reg  (
	.D(cic_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.dvalid_r )
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[31]  (
	.D(\u_comps.mac_B_4 [31]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [31])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[30]  (
	.D(\u_comps.mac_B_4 [30]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [30])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[29]  (
	.D(\u_comps.mac_B_4 [29]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [29])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[28]  (
	.D(\u_comps.mac_B_4 [28]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [28])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[27]  (
	.D(\u_comps.mac_B_4 [27]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [27])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[26]  (
	.D(\u_comps.mac_B_4 [26]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [26])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[25]  (
	.D(\u_comps.mac_B_4 [25]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [25])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[24]  (
	.D(\u_comps.mac_B_4 [24]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [24])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[23]  (
	.D(\u_comps.mac_B_4 [23]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [23])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[22]  (
	.D(\u_comps.mac_B_4 [22]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [22])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[21]  (
	.D(\u_comps.mac_B_4 [21]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [21])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[20]  (
	.D(\u_comps.mac_B_4 [20]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [20])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[19]  (
	.D(\u_comps.mac_B_4 [19]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [19])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[18]  (
	.D(\u_comps.mac_B_4 [18]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [18])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[17]  (
	.D(\u_comps.mac_B_4 [17]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [17])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[16]  (
	.D(\u_comps.mac_B_4 [16]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [16])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[15]  (
	.D(\u_comps.mac_B_4 [15]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [15])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[14]  (
	.D(\u_comps.mac_B_4 [14]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [14])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[13]  (
	.D(\u_comps.mac_B_4 [13]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [13])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[12]  (
	.D(\u_comps.mac_B_4 [12]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [12])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[11]  (
	.D(\u_comps.mac_B_4 [11]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [11])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[10]  (
	.D(\u_comps.mac_B_4 [10]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [10])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[9]  (
	.D(\u_comps.mac_B_4 [9]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [9])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[8]  (
	.D(\u_comps.mac_B_4 [8]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [8])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[7]  (
	.D(\u_comps.mac_B_4 [7]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [7])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[6]  (
	.D(\u_comps.mac_B_4 [6]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [6])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[5]  (
	.D(\u_comps.mac_B_4 [5]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [5])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[4]  (
	.D(\u_comps.mac_B_4 [4]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [4])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[3]  (
	.D(\u_comps.mac_B_4 [3]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [3])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[2]  (
	.D(\u_comps.mac_B_4 [2]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [2])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[1]  (
	.D(\u_comps.mac_B_4 [1]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [1])
);
// @7:337
  FD1P3DX \u_comps.mac_B_reg[0]  (
	.D(\u_comps.mac_B_4 [0]),
	.SP(\u_comps.un1_run_even_r_2 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B [0])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[27]  (
	.D(\u_comps.mac_T_4 [27]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [27])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[26]  (
	.D(\u_comps.mac_T_4 [26]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [26])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[25]  (
	.D(\u_comps.mac_T_4 [25]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [25])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[24]  (
	.D(\u_comps.mac_T_4 [24]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [24])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[23]  (
	.D(\u_comps.mac_T_4 [23]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [23])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[22]  (
	.D(\u_comps.mac_T_4 [22]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [22])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[21]  (
	.D(\u_comps.mac_T_4 [21]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [21])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[20]  (
	.D(\u_comps.mac_T_4 [20]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [20])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[19]  (
	.D(\u_comps.mac_T_4 [19]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [19])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[18]  (
	.D(\u_comps.mac_T_4 [18]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [18])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[17]  (
	.D(\u_comps.mac_T_4 [17]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [17])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[16]  (
	.D(\u_comps.mac_T_4 [16]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [16])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[15]  (
	.D(\u_comps.mac_T_4 [15]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [15])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[14]  (
	.D(\u_comps.mac_T_4 [14]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [14])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[13]  (
	.D(\u_comps.mac_T_4 [13]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [13])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[12]  (
	.D(\u_comps.mac_T_4 [12]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [12])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[11]  (
	.D(\u_comps.mac_T_4 [11]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [11])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[10]  (
	.D(\u_comps.mac_T_4 [10]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [10])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[9]  (
	.D(\u_comps.mac_T_4 [9]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [9])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[8]  (
	.D(\u_comps.mac_T_4 [8]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [8])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[7]  (
	.D(\u_comps.mac_T_4 [7]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [7])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[6]  (
	.D(\u_comps.mac_T_4 [6]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [6])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[5]  (
	.D(\u_comps.mac_T_4 [5]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [5])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[4]  (
	.D(\u_comps.mac_T_4 [4]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [4])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[3]  (
	.D(\u_comps.mac_T_4 [3]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [3])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[2]  (
	.D(\u_comps.mac_T_4 [2]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [2])
);
// @7:327
  FD1P3DX \u_comps.mac_T_reg[1]  (
	.D(\u_comps.mac_T_4 [1]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_T [1])
);
// @7:327
  FD1P3DX \u_comps.mac_T[0]  (
	.D(\u_comps.mac_T_4 [0]),
	.SP(\u_comps.un1_run_en_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_sum_scalar )
);
// @7:196
  FD1P3DX \u_comps.raddr_L_reg[5]  (
	.D(\u_comps.raddr_L_lm [5]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_L [5])
);
// @7:196
  FD1P3DX \u_comps.raddr_L_reg[4]  (
	.D(\u_comps.raddr_L_lm [4]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_L [4])
);
// @7:196
  FD1P3DX \u_comps.raddr_L_reg[3]  (
	.D(\u_comps.raddr_L_lm [3]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_L [3])
);
// @7:196
  FD1P3DX \u_comps.raddr_L_reg[2]  (
	.D(\u_comps.raddr_L_lm [2]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_L [2])
);
// @7:196
  FD1P3DX \u_comps.raddr_L_reg[1]  (
	.D(\u_comps.raddr_L_lm [1]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_L [1])
);
// @7:196
  FD1P3DX \u_comps.raddr_L_reg[0]  (
	.D(\u_comps.raddr_L_lm [0]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_L [0])
);
// @7:206
  FD1P3DX \u_comps.raddr_R_reg[5]  (
	.D(\u_comps.raddr_R_lm [5]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_R [5])
);
// @7:206
  FD1P3DX \u_comps.raddr_R_reg[4]  (
	.D(\u_comps.raddr_R_lm [4]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_R [4])
);
// @7:206
  FD1P3DX \u_comps.raddr_R_reg[3]  (
	.D(\u_comps.raddr_R_lm [3]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_R [3])
);
// @7:206
  FD1P3DX \u_comps.raddr_R_reg[2]  (
	.D(\u_comps.raddr_R_lm [2]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_R [2])
);
// @7:206
  FD1P3DX \u_comps.raddr_R_reg[1]  (
	.D(\u_comps.raddr_R_lm [1]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_R [1])
);
// @7:206
  FD1P3DX \u_comps.raddr_R_reg[0]  (
	.D(\u_comps.raddr_R_lm [0]),
	.SP(\u_comps.raddr_Le ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.raddr_R [0])
);
// @7:130
  FD1P3DX \u_comps.run_en_reg  (
	.D(\u_comps.dstart_r_2 [0]),
	.SP(\u_comps.un1_dstart_r_1 ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_en )
);
// @7:150
  FD1S3DX \u_comps.run_en_r_reg[3]  (
	.D(\u_comps.run_en_r [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_en_r [3])
);
// @7:150
  FD1S3DX \u_comps.run_en_r_reg[2]  (
	.D(\u_comps.run_en_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_en_r [2])
);
// @7:150
  FD1S3DX \u_comps.run_en_r_reg[1]  (
	.D(\u_comps.run_en_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_en_r [1])
);
// @7:150
  FD1S3DX \u_comps.run_en_r_reg[0]  (
	.D(\u_comps.run_en ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_en_r [0])
);
// @7:140
  FD1P3DX \u_comps.run_even_reg  (
	.D(\u_comps.run_even_3 ),
	.SP(\u_comps.un1_dstart_r ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_even )
);
// @7:150
  FD1S3DX \u_comps.run_even_r_reg[3]  (
	.D(\u_comps.run_even_r [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_even_r [3])
);
// @7:150
  FD1S3DX \u_comps.run_even_r_reg[2]  (
	.D(\u_comps.run_even_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_even_r [2])
);
// @7:150
  FD1S3DX \u_comps.run_even_r_reg[1]  (
	.D(\u_comps.run_even_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_even_r [1])
);
// @7:150
  FD1S3DX \u_comps.run_even_r_reg[0]  (
	.D(\u_comps.run_even ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.run_even_r [0])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAA_R_reg[15]  (
	.D(\u_comps.data_M [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAA_R [15])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[15]  (
	.D(\u_comps.cdata [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [15])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[14]  (
	.D(\u_comps.cdata [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [14])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[13]  (
	.D(\u_comps.cdata [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [13])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[12]  (
	.D(\u_comps.cdata [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [12])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[11]  (
	.D(\u_comps.cdata [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [11])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[10]  (
	.D(\u_comps.cdata [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [10])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[9]  (
	.D(\u_comps.cdata [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [9])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[8]  (
	.D(\u_comps.cdata [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [8])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[7]  (
	.D(\u_comps.cdata [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [7])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[6]  (
	.D(\u_comps.cdata [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [6])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[5]  (
	.D(\u_comps.cdata [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [5])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[4]  (
	.D(\u_comps.cdata [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [4])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[3]  (
	.D(\u_comps.cdata [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [3])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[2]  (
	.D(\u_comps.cdata [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [2])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[1]  (
	.D(\u_comps.cdata [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [1])
);
// @10:120
  FD1S3DX \u_comps.u_mult.DATAB_R_reg[0]  (
	.D(\u_comps.cdata [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.DATAB_R [0])
);
// @10:120
  FD1S3DX \u_comps.u_mult.PRODUCT_R[7]  (
	.D(\u_comps.u_mult.PRODUCT_R_2 [7]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mult_result [7])
);
// @10:120
  FD1S3DX \u_comps.u_mult.PRODUCT_R[6]  (
	.D(\u_comps.u_mult.PRODUCT_R_2 [6]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mult_result [6])
);
// @10:120
  FD1S3DX \u_comps.u_mult.PRODUCT_R[5]  (
	.D(\u_comps.u_mult.PRODUCT_R_2 [5]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mult_result [5])
);
// @10:120
  FD1S3DX \u_comps.u_mult.PRODUCT_R[4]  (
	.D(\u_comps.u_mult.PRODUCT_R_2 [4]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mult_result [4])
);
// @10:120
  FD1S3DX \u_comps.u_mult.PRODUCT_R[3]  (
	.D(\u_comps.u_mult.PRODUCT_R_2 [3]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mult_result [3])
);
// @10:120
  FD1S3DX \u_comps.u_mult.PRODUCT_R[2]  (
	.D(\u_comps.u_mult.PRODUCT_R_2 [2]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mult_result [2])
);
// @10:120
  FD1S3DX \u_comps.u_mult.PRODUCT_R[1]  (
	.D(\u_comps.u_mult.PRODUCT_R_2 [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mult_result [1])
);
// @10:120
  FD1S3DX \u_comps.u_mult.PRODUCT_R[0]  (
	.D(\u_comps.u_mult.PRODUCT_R_2 [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mult_result [0])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_16  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B_4_2 )
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_17  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [16]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [16])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_18  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [17]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [17])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_19  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [18]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [18])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_20  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [19]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [19])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_21  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [20]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [20])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_22  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [21]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [21])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_23  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [22]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [22])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_24  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [23]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [23])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_25  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [24]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [24])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_26  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [25]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [25])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_27  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [26]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [26])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_28  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [27]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [27])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_29  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [28]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [28])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_30  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [29]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [29])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_31  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [30]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [30])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_32  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_9 [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B_4_0 )
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_33  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_2 [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [9])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_34  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_10 [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [10])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_35  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_10 [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [11])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_36  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [12])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_37  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [13])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_38  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_13 [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_13f [14])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_39  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [15])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_40  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [16]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [16])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_41  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [17]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [17])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_42  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [18]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [18])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_43  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [19]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [19])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_44  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [20]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [20])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_45  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [21]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [21])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_46  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [22]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [22])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_47  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [23]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [23])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_48  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [24]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [24])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_49  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [8]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.mac_B_4_scalar )
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_50  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [9]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [9])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_51  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [10]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [10])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_52  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [11]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [11])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_53  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [12]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [12])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_54  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [13]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [13])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_55  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [14]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [14])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_56  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [15]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [15])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_57  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [16]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [16])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_58  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [17]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [17])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_59  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [18]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [18])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_60  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [19]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [19])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_61  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [20]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [20])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_62  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [21]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [21])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_63  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [22]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [22])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_64  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [23]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [23])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_65  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_12 [24]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_12f [24])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_66  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [25]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [25])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_67  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [26]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [26])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_68  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [27]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [27])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_69  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [28]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [28])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_70  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [29]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [29])
);
  FD1S3DX \u_comps.u_mult.PRODUCT_R_2.PRODUCT_R_pipe_71  (
	.D(\u_comps.u_mult.PRODUCT_R_2.madd_11 [30]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.u_mult.PRODUCT_R_2.madd_11f [30])
);
// @7:188
  FD1P3DX \u_comps.waddr_reg[6]  (
	.D(\u_comps.waddr_s [6]),
	.SP(\u_comps.din_we ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.waddr [6])
);
// @7:188
  FD1P3DX \u_comps.waddr_reg[5]  (
	.D(\u_comps.waddr_s [5]),
	.SP(\u_comps.din_we ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.waddr [5])
);
// @7:188
  FD1P3DX \u_comps.waddr_reg[4]  (
	.D(\u_comps.waddr_s [4]),
	.SP(\u_comps.din_we ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.waddr [4])
);
// @7:188
  FD1P3DX \u_comps.waddr_reg[3]  (
	.D(\u_comps.waddr_s [3]),
	.SP(\u_comps.din_we ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.waddr [3])
);
// @7:188
  FD1P3DX \u_comps.waddr_reg[2]  (
	.D(\u_comps.waddr_s [2]),
	.SP(\u_comps.din_we ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.waddr [2])
);
// @7:188
  FD1P3DX \u_comps.waddr_reg[1]  (
	.D(\u_comps.waddr_s [1]),
	.SP(\u_comps.din_we ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.waddr [1])
);
// @7:188
  FD1P3DX \u_comps.waddr_reg[0]  (
	.D(\u_comps.waddr_s [0]),
	.SP(\u_comps.din_we ),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_comps.waddr [0])
);
// @8:103
  FD1P3DX \u_dcc.dout[23]  (
	.D(\u_dcc.sum [24]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[23])
);
// @8:103
  FD1P3DX \u_dcc.dout[22]  (
	.D(\u_dcc.dout_4 [22]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[22])
);
// @8:103
  FD1P3DX \u_dcc.dout[21]  (
	.D(\u_dcc.dout_4 [21]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[21])
);
// @8:103
  FD1P3DX \u_dcc.dout[20]  (
	.D(\u_dcc.dout_4 [20]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[20])
);
// @8:103
  FD1P3DX \u_dcc.dout[19]  (
	.D(\u_dcc.dout_4 [19]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[19])
);
// @8:103
  FD1P3DX \u_dcc.dout[18]  (
	.D(\u_dcc.dout_4 [18]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[18])
);
// @8:103
  FD1P3DX \u_dcc.dout[17]  (
	.D(\u_dcc.dout_4 [17]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[17])
);
// @8:103
  FD1P3DX \u_dcc.dout[16]  (
	.D(\u_dcc.dout_4 [16]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[16])
);
// @8:103
  FD1P3DX \u_dcc.dout[15]  (
	.D(\u_dcc.dout_4 [15]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[15])
);
// @8:103
  FD1P3DX \u_dcc.dout[14]  (
	.D(\u_dcc.dout_4 [14]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[14])
);
// @8:103
  FD1P3DX \u_dcc.dout[13]  (
	.D(\u_dcc.dout_4 [13]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[13])
);
// @8:103
  FD1P3DX \u_dcc.dout[12]  (
	.D(\u_dcc.dout_4 [12]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[12])
);
// @8:103
  FD1P3DX \u_dcc.dout[11]  (
	.D(\u_dcc.dout_4 [11]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[11])
);
// @8:103
  FD1P3DX \u_dcc.dout[10]  (
	.D(\u_dcc.dout_4 [10]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[10])
);
// @8:103
  FD1P3DX \u_dcc.dout[9]  (
	.D(\u_dcc.dout_4 [9]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[9])
);
// @8:103
  FD1P3DX \u_dcc.dout[8]  (
	.D(\u_dcc.dout_4 [8]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[8])
);
// @8:103
  FD1P3DX \u_dcc.dout[7]  (
	.D(\u_dcc.dout_4 [7]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[7])
);
// @8:103
  FD1P3DX \u_dcc.dout[6]  (
	.D(\u_dcc.dout_4 [6]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[6])
);
// @8:103
  FD1P3DX \u_dcc.dout[5]  (
	.D(\u_dcc.dout_4 [5]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[5])
);
// @8:103
  FD1P3DX \u_dcc.dout[4]  (
	.D(\u_dcc.dout_4 [4]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[4])
);
// @8:103
  FD1P3DX \u_dcc.dout[3]  (
	.D(\u_dcc.dout_4 [3]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[3])
);
// @8:103
  FD1P3DX \u_dcc.dout[2]  (
	.D(\u_dcc.dout_4 [2]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[2])
);
// @8:103
  FD1P3DX \u_dcc.dout[1]  (
	.D(\u_dcc.dout_4 [1]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[1])
);
// @8:103
  FD1P3DX \u_dcc.dout[0]  (
	.D(\u_dcc.dout_4 [0]),
	.SP(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_data[0])
);
// @8:117
  FD1S3DX \u_dcc.dvalid_r[2]  (
	.D(\u_dcc.dvalid_r [1]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(pcm_dvalid)
);
// @8:117
  FD1S3DX \u_dcc.dvalid_r_reg[1]  (
	.D(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.dvalid_r [1])
);
// @8:117
  FD1S3DX \u_dcc.dvalid_r_reg[0]  (
	.D(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.dvalid_r [0])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[23]  (
	.D(dec_data[23]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [23])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[22]  (
	.D(dec_data[22]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [22])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[21]  (
	.D(dec_data[21]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [21])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[20]  (
	.D(dec_data[20]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [20])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[19]  (
	.D(dec_data[19]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [19])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[18]  (
	.D(dec_data[18]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [18])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[17]  (
	.D(dec_data[17]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [17])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[16]  (
	.D(dec_data[16]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [16])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[15]  (
	.D(dec_data[15]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [15])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[14]  (
	.D(dec_data[14]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [14])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[13]  (
	.D(dec_data[13]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [13])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[12]  (
	.D(dec_data[12]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [12])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[11]  (
	.D(dec_data[11]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [11])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[10]  (
	.D(dec_data[10]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [10])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[9]  (
	.D(dec_data[9]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [9])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[8]  (
	.D(dec_data[8]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [8])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[7]  (
	.D(dec_data[7]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [7])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[6]  (
	.D(dec_data[6]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [6])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[5]  (
	.D(dec_data[5]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [5])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[4]  (
	.D(dec_data[4]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [4])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[3]  (
	.D(dec_data[3]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [3])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[2]  (
	.D(dec_data[2]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [2])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[1]  (
	.D(dec_data[1]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [1])
);
// @8:57
  FD1P3DX \u_dcc.previ_reg[0]  (
	.D(dec_data[0]),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.previ [0])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[23]  (
	.D(pcm_data[23]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [23])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[22]  (
	.D(pcm_data[22]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [22])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[21]  (
	.D(pcm_data[21]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [21])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[20]  (
	.D(pcm_data[20]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [20])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[19]  (
	.D(pcm_data[19]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [19])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[18]  (
	.D(pcm_data[18]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [18])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[17]  (
	.D(pcm_data[17]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [17])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[16]  (
	.D(pcm_data[16]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [16])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[15]  (
	.D(pcm_data[15]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [15])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[14]  (
	.D(pcm_data[14]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [14])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[13]  (
	.D(pcm_data[13]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [13])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[12]  (
	.D(pcm_data[12]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [12])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[11]  (
	.D(pcm_data[11]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [11])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[10]  (
	.D(pcm_data[10]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [10])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[9]  (
	.D(pcm_data[9]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [9])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[8]  (
	.D(pcm_data[8]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [8])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[7]  (
	.D(pcm_data[7]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [7])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[6]  (
	.D(pcm_data[6]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [6])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[5]  (
	.D(pcm_data[5]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [5])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[4]  (
	.D(pcm_data[4]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [4])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[3]  (
	.D(pcm_data[3]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [3])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[2]  (
	.D(pcm_data[2]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [2])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[1]  (
	.D(pcm_data[1]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [1])
);
// @8:73
  FD1P3DX \u_dcc.prevo_reg[0]  (
	.D(pcm_data[0]),
	.SP(pcm_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.prevo [0])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[24]  (
	.D(N_1541),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [24])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[23]  (
	.D(N_1540),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [23])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[22]  (
	.D(N_1539),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [22])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[21]  (
	.D(N_1538),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [21])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[20]  (
	.D(N_1537),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [20])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[19]  (
	.D(N_1536),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [19])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[18]  (
	.D(N_1535),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [18])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[17]  (
	.D(N_1534),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [17])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[16]  (
	.D(N_1533),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [16])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[15]  (
	.D(N_1532),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [15])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[14]  (
	.D(N_1531),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [14])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[13]  (
	.D(N_1530),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [13])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[12]  (
	.D(N_1529),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [12])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[11]  (
	.D(N_1528),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [11])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[10]  (
	.D(N_1527),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [10])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[9]  (
	.D(N_1526),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [9])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[8]  (
	.D(N_1525),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [8])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[7]  (
	.D(N_1524),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [7])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[6]  (
	.D(N_1523),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [6])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[5]  (
	.D(N_1522),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [5])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[4]  (
	.D(N_1521),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [4])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[3]  (
	.D(N_1520),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [3])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[2]  (
	.D(N_1519),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [2])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[1]  (
	.D(N_1518),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [1])
);
// @8:65
  FD1P3DX \u_dcc.subi_reg[0]  (
	.D(\u_dcc.un2_subi_axb_0_i ),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subi [0])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[23]  (
	.D(N_1516),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [23])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[22]  (
	.D(N_1515),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [22])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[21]  (
	.D(N_1514),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [21])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[20]  (
	.D(N_1513),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [20])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[19]  (
	.D(N_1512),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [19])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[18]  (
	.D(N_1511),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [18])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[17]  (
	.D(N_1510),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [17])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[16]  (
	.D(N_1509),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [16])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[15]  (
	.D(N_1508),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [15])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[14]  (
	.D(N_1507),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [14])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[13]  (
	.D(N_1506),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [13])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[12]  (
	.D(N_1505),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [12])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[11]  (
	.D(N_1504),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [11])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[10]  (
	.D(N_1503),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [10])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[9]  (
	.D(N_1502),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [9])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[8]  (
	.D(N_1501),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [8])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[7]  (
	.D(N_1500),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [7])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[6]  (
	.D(N_1499),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [6])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[5]  (
	.D(N_1498),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [5])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[4]  (
	.D(N_1497),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [4])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[3]  (
	.D(N_1496),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [3])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[2]  (
	.D(N_1495),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [2])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[1]  (
	.D(N_1494),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [1])
);
// @8:85
  FD1P3DX \u_dcc.subo_reg[0]  (
	.D(\u_dcc.un1_subo_axb_0_i ),
	.SP(dec_dvalid),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.subo [0])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[24]  (
	.D(\u_dcc.un1_sum [24]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [24])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[23]  (
	.D(\u_dcc.un1_sum [23]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [23])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[22]  (
	.D(\u_dcc.un1_sum [22]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [22])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[21]  (
	.D(\u_dcc.un1_sum [21]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [21])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[20]  (
	.D(\u_dcc.un1_sum [20]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [20])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[19]  (
	.D(\u_dcc.un1_sum [19]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [19])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[18]  (
	.D(\u_dcc.un1_sum [18]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [18])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[17]  (
	.D(\u_dcc.un1_sum [17]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [17])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[16]  (
	.D(\u_dcc.un1_sum [16]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [16])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[15]  (
	.D(\u_dcc.un1_sum [15]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [15])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[14]  (
	.D(\u_dcc.un1_sum [14]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [14])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[13]  (
	.D(\u_dcc.un1_sum [13]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [13])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[12]  (
	.D(\u_dcc.un1_sum [12]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [12])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[11]  (
	.D(\u_dcc.un1_sum [11]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [11])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[10]  (
	.D(\u_dcc.un1_sum [10]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [10])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[9]  (
	.D(\u_dcc.un1_sum [9]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [9])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[8]  (
	.D(\u_dcc.un1_sum [8]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [8])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[7]  (
	.D(\u_dcc.un1_sum [7]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [7])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[6]  (
	.D(\u_dcc.un1_sum [6]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [6])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[5]  (
	.D(\u_dcc.un1_sum [5]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [5])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[4]  (
	.D(\u_dcc.un1_sum [4]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [4])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[3]  (
	.D(\u_dcc.un1_sum [3]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [3])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[2]  (
	.D(\u_dcc.un1_sum [2]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [2])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[1]  (
	.D(\u_dcc.un1_sum [1]),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [1])
);
// @8:95
  FD1P3DX \u_dcc.sum_reg[0]  (
	.D(\u_dcc.un1_sum_axb_0 ),
	.SP(\u_dcc.dvalid_r [0]),
	.CK(pdm_clk),
	.CD(pdm_rst),
	.Q(\u_dcc.sum [0])
);
// @7:105
  LUT4 \u_comps.din_even_0  (
	.A(cic_dvalid),
	.B(\u_comps.din_even ),
	.C(VCC),
	.D(VCC),
	.Z(N_4486)
);
defparam \u_comps.din_even_0 .init=16'h6666;
  LUT4 \u_comps.raddr_R_RNO[5]  (
	.A(\u_comps.un2_raddr_L [5]),
	.B(\u_comps.raddr_R_s [5]),
	.C(\u_comps.din_even ),
	.D(cic_dvalid),
	.Z(\u_comps.raddr_R_lm [5])
);
defparam \u_comps.raddr_R_RNO[5] .init=16'hCACC;
  LUT4 \u_comps.raddr_L_RNO[5]  (
	.A(\u_comps.un2_raddr_L [5]),
	.B(\u_comps.raddr_L_s [5]),
	.C(\u_comps.din_even ),
	.D(cic_dvalid),
	.Z(\u_comps.raddr_L_lm [5])
);
defparam \u_comps.raddr_L_RNO[5] .init=16'hCACC;
  LUT4 \u_comps.run_en_RNO  (
	.A(\u_comps.un13_dout_en ),
	.B(\u_comps.run_even ),
	.C(\u_comps.din_even ),
	.D(cic_dvalid),
	.Z(\u_comps.un1_dstart_r_1 )
);
defparam \u_comps.run_en_RNO .init=16'h8F88;
  LUT4 \u_comps.u_mult.PRODUCT_R_2.a0_b[0]  (
	.A(\u_comps.u_mult.DATAB_R [0]),
	.B(\u_comps.un3_data_Mf [0]),
	.C(\u_comps.data_M7f_0f_fast ),
	.D(\u_comps.data_Lff [0]),
	.Z(\u_comps.u_mult.PRODUCT_R_2 [0])
);
defparam \u_comps.u_mult.PRODUCT_R_2.a0_b[0] .init=16'hA808;
  LUT4 \u_comps.raddr_R_RNO[0]  (
	.A(\u_comps.waddr [1]),
	.B(\u_comps.raddr_R_s [0]),
	.C(\u_comps.din_even ),
	.D(cic_dvalid),
	.Z(\u_comps.raddr_R_lm [0])
);
defparam \u_comps.raddr_R_RNO[0] .init=16'hC5CC;
  LUT4 \u_comps.raddr_L_RNO[0]  (
	.A(\u_comps.waddr [1]),
	.B(\u_comps.raddr_L_s [0]),
	.C(\u_comps.din_even ),
	.D(cic_dvalid),
	.Z(\u_comps.raddr_L_lm [0])
);
defparam \u_comps.raddr_L_RNO[0] .init=16'hC5CC;
  LUT4 \u_comps.caddr_RNO[1]  (
	.A(\u_comps.un1_caddr [1]),
	.B(\u_comps.din_even ),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.caddr_3 [1])
);
defparam \u_comps.caddr_RNO[1] .init=16'hBABA;
  LUT4 \u_comps.caddr_RNO[2]  (
	.A(\u_comps.un1_caddr [2]),
	.B(\u_comps.din_even ),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.caddr_3 [2])
);
defparam \u_comps.caddr_RNO[2] .init=16'hBABA;
  LUT4 \u_comps.caddr_RNO[3]  (
	.A(\u_comps.un1_caddr [3]),
	.B(\u_comps.din_even ),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.caddr_3 [3])
);
defparam \u_comps.caddr_RNO[3] .init=16'hBABA;
  LUT4 \u_comps.caddr_RNO[4]  (
	.A(\u_comps.un1_caddr [4]),
	.B(\u_comps.din_even ),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.caddr_3 [4])
);
defparam \u_comps.caddr_RNO[4] .init=16'hBABA;
  LUT4 \u_comps.run_even_RNO  (
	.A(\u_comps.run_even ),
	.B(\u_comps.din_even ),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.run_even_3 )
);
defparam \u_comps.run_even_RNO .init=16'h4545;
  LUT4 \u_comps.run_even_RNO_0  (
	.A(\u_comps.run_en ),
	.B(\u_comps.din_even ),
	.C(cic_dvalid),
	.D(VCC),
	.Z(\u_comps.un1_dstart_r )
);
defparam \u_comps.run_even_RNO_0 .init=16'hBABA;
  VHI VCC_0 (
	.Z(VCC)
);
  VLO GND_0 (
	.Z(GND)
);
//  GSR GSR_INST (
//	.GSR(VCC)
//);
//  PUR PUR_INST (
//	.PUR(VCC)
//);
endmodule

