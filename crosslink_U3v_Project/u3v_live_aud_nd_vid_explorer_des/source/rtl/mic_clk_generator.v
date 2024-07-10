//////////////////////////////////////////////////////////////////////////////////
//	(c) 2020-2021, Cypress Semiconductor Corporation (an Infineon company) or
// an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
//
//	This software, including source code, documentation and related materials
// ("Software") is owned by Cypress Semiconductor Corporation or one of its
// affiliates ("Cypress") and is protected by and subject to worldwide patent
// protection (United States and foreign), United States copyright laws and
// international treaty provisions.  Therefore, you may use this Software only
// as provided in the license agreement accompanying the software package from
// which you obtained this Software ("EULA"). If no EULA applies, Cypress hereby
// grants you a personal, non-exclusive, non-transferable license to copy, modify,
// and compile the Software source code solely for use in connection with Cypress's
// integrated circuit products.  Any reproduction, modification, translation,
// compilation, or representation of this Software except as specified above is
// prohibited without the express written permission of Cypress.
//
//	Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
// Cypress reserves the right to make changes to the Software without notice.
// Cypress does not assume any liability arising out of the application or use
// of the Software or any product or circuit described in the Software.
// Cypress does not authorize its products for use in any products where a
// malfunction or failure of the Cypress product may reasonably be expected to
// result in significant property damage, injury or death ("High Risk Product").
// By including Cypress's product in a High Risk Product, the manufacturer of
// such system or application assumes all risk of such use and in doing so agrees
// to indemnify Cypress against all liability.
//
// Design Name    :	Test pattern for Explorer Kit
// Module Name    :	mic_clk_generator
// Target Devices : All
// Description    : This module generates the clock based on the parameter value
//                  given.
//
//////////////////////////////////////////////////////////////////////////////////

module mic_clk_generator
  #
  (
   // Input Clock Value
   parameter INPUT_CLK_VALUE  = 32'd8400_0000,

   // Output Clock Value (Should be less than INPUT_CLK_VALUE/2)
   parameter OUTPUT_CLK_VALUE = 32'd500_000
  )
  (
   input      clk,
   input      reset_n,

   output reg data_o
  );
//-4------11

  //----------------------------------
  //
  // Local Parameters
  //
  //----------------------------------

  // Half value as IO will be toggled after half interval of a clock (0.5MHz)
  // i.e. duty cycle is 50 %
  localparam OUTPUT_CLK_HALF_VALUE = ( OUTPUT_CLK_VALUE << 1'd1 );

  // Number of clock pulses required to toggle the IO
  localparam NO_OF_CLK_PULSES = ( INPUT_CLK_VALUE / OUTPUT_CLK_HALF_VALUE );


  //----------------------------------
  //
  // Local Variables
  //
  //----------------------------------

  reg  [31:0] intr_counter;


  //----------------------------------
  //
  // Counter is running from 0 to
  // COUNTER_HALF_VALUE - 1
  //
  //----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          intr_counter <= 32'h0;
        end
      else if ( intr_counter == ( NO_OF_CLK_PULSES - 1'd1 ) )
        begin
          intr_counter <= 32'h0;
        end
      else
        begin
          intr_counter <= ( intr_counter + 1'b1 );
        end
    end


  //----------------------------------
  //
  // Clock IO for Mic
  //
  //----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          data_o <= 1'h0;
        end
      else if ( intr_counter == ( NO_OF_CLK_PULSES - 1'd1 ) )
        begin
          data_o <= ~data_o;
        end
    end


endmodule