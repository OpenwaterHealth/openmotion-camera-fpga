#=============================================================================
# Eval sim script generated by IPExpress/Clarity   10/28/2024    17:45:05 
# Lattice IP Core Simulation Script for Evaluation (Verilog)                  
# Copyright(c) 2015 Lattice Semiconductor Corporation. All rights reserved.   
#=============================================================================

# WARNING - Changes to this file should be performed by re-running IPexpress or
# modifying the .LPC file and regenerating the core. Other changes may lead to 
# inconsistent simulation and/or implementation results.                       

#-- Set Diamond SW installation directory -- 
#-- Modify this path for localization of "Diamond" 
set diamond_dir C:/lscc/diamond/3.13 

#-- Simulation work library creation -- 
cd "C:/Users/ethanhead/Desktop/gen3-cam-fw/HistoFPGAFw/byte_pixel/byte2pix/byte2pixel_eval/byte2pix/sim/aldec"
     workspace create byte2pixel_space
     design create byte2pix_design .
     design open byte2pix_design

#-- Lattice device library support -- 
cd "C:/Users/ethanhead/Desktop/gen3-cam-fw/HistoFPGAFw/byte_pixel/byte2pix/byte2pixel_eval/byte2pix/sim/aldec"
set diamond_dir C:/lscc/diamond/3.13 
set sim_working_folder .

do byte2pixel_rtl.do
run -all 
