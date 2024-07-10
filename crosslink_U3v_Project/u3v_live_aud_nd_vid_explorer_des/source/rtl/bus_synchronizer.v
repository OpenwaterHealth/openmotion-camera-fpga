////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	(c) 2020-2021, Cypress Semiconductor Corporation (an Infineon company) or an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
//
//	This software, including source code, documentation and related materials ("Software") is owned by Cypress Semiconductor Corporation or one of its affiliates
//	("Cypress") and is protected by and subject to worldwide patent protection (United States and foreign), United States copyright laws and international treaty
//	provisions.  Therefore, you may use this Software only as provided in the license agreement accompanying the software package from which you obtained this 
//	Software ("EULA").
//	If no EULA applies, Cypress hereby grants you a personal, non-exclusive, non-transferable license to copy, modify, and compile the Software source code solely 
//	for use in connection with Cypress's integrated circuit products.  Any reproduction, modification, translation, compilation, or representation of this Software 
//	except as specified above is prohibited without the express written permission of Cypress.
//
//	Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED 
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress reserves the right to make changes to the Software without notice. Cypress does 
//	not assume any liability arising out of the application or use of the Software or any product or circuit described in the Software. Cypress does not authorize 
//	its products for use in any products where a malfunction or failure of the Cypress product may reasonably be expected to result in significant property damage, 
//	injury or death ("High Risk Product"). By including Cypress's product in a High Risk Product, the manufacturer of such system or application assumes all risk of 
//	such use and in doing so agrees to indemnify Cypress against all liability.
//
//	Design Name:		 
//	Module Name:		bus_sync_mod
//	Target Devices:
//	Description:		This module synchronises the input bus data from clk_src_i clock doamin to clk_sync_i domain at enable signal.
// 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps

module bus_sync_mod 
#( parameter BUS_WDT=32	)
(
  input		clk_src_i,	// Source clock
  input		clk_sync_i,	// Synchronizing clock
  input		en_sync_i,	// Synchronizing clock enable
  input [(BUS_WDT-1):0]	data_src_i,	// Input signal
  output [(BUS_WDT-1):0]data_sync_o	// Synchronized data out
);


//***************************************************************************
// Register and Net declarations
//***************************************************************************

reg	[(BUS_WDT-1):0]	data_src_r=0;
reg	[(BUS_WDT-1):0] data_m1_r=0;

assign data_sync_o = data_m1_r;

//	Resister data once at source clock
always @(posedge clk_src_i)
	data_src_r <= data_src_i;

//	Latch the data in destination clock at enable signal
always @(posedge clk_sync_i) begin
	if(en_sync_i)
		data_m1_r <= data_src_r;
end

endmodule