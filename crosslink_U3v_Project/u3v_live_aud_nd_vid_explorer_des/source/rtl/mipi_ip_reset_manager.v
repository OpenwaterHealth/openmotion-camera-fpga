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
//	Module Name:	MIPI IP Reset Manager
//	Target Devices:	LIF-MD6000
//	Description:	This module manages MIPI IP reset mechanism when video resolution changes.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module mipi_ip_reset_manager
  #
  (
   // Parameter for reference clock
   parameter REF_CLOCK_VALUE_I = 48_000_000,

   // Parameter for MIPI IP reset duration in micro seconds.
   parameter MIPI_IP_RESET_LOW_TIME_IN_MS_I = 500
  )
  (
    input      clk,
    input      reset_n,

    input      cam_app_en_i,
    input      aud_app_en_i,

    output reg mipi_reset_n_o,
    output     reset_counter_is_low_o,
    output     reset_counter_is_high_o

  );

//----------------------------------
//
// Local Parameters
//
//----------------------------------

  // Maximum value of counter
  localparam RESET_COUNTER_MAX_VALUE = ( ( REF_CLOCK_VALUE_I/32'd1_000 ) * (MIPI_IP_RESET_LOW_TIME_IN_MS_I) );

  // Logic Low Value
  localparam LOW  = 1'b0;

  // Logic High Value
  localparam HIGH = 1'b1;


//----------------------------------
//
// Local Variables
//
//----------------------------------

  reg  [31:0] reset_counter;


//----------------------------------
//
// Reset Counter
//
//----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          reset_counter <= 32'd0;
        end
      else if ( cam_app_en_i )
        begin
          reset_counter <= 32'd0;
        end
      else if ( aud_app_en_i )
        begin
          if ( reset_counter == RESET_COUNTER_MAX_VALUE )
            begin
              reset_counter <= reset_counter;
            end
          else
            begin
              reset_counter <= reset_counter + 1'd1;
            end
        end
    end

  assign reset_counter_is_low_o  = ( reset_counter == 1'd0 );
  assign reset_counter_is_high_o = ( reset_counter == RESET_COUNTER_MAX_VALUE );


//----------------------------------
//
// Reset
//
//----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          mipi_reset_n_o <= LOW;
        end
      else if ( ( cam_app_en_i ) |
                ( ( ~cam_app_en_i ) & ( aud_app_en_i ) & ( reset_counter == RESET_COUNTER_MAX_VALUE ) )
              )
        begin
          mipi_reset_n_o <= HIGH;
        end
      else
        begin
          mipi_reset_n_o <= cam_app_en_i;
        end
    end



endmodule