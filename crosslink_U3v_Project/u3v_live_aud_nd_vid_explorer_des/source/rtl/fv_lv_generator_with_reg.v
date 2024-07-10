module fv_lv_generator_with_reg
  #
  (
   // Input Clock Value
   parameter REF_CLK_PULSES_IN_S_I  = 32'd83_750_000,

   // Image Height
   // parameter IMAGE_HEIGHT_IN_PIXELS_I = 32'd1080,

   // Image Width
   // parameter IMAGE_WIDTH_IN_PIXELS_I = 32'd1920,

   // Frame Rate
   // parameter FRAME_RATE_I = 32'd30,

   // Line Blanking Time in Clock Pulses
   // parameter LINE_BLANKING_CLK_PULSES_I = 32'd100,

   // Data Width
   parameter DATA_WIDTH_I = 6'd32
  )
  (
   input                           clk,
   input                           reset_n,

   input      [15:0]               image_width_i,
   input      [15:0]               image_height_i,
   input      [15:0]               line_blanking_clk_pulses_i,

   // input      [31:0]               pclk_pulses_i,
   input      [ 7:0]               img_fps_i,

   output reg                      fv_o,
   output reg                      lv_o,
   output reg [(DATA_WIDTH_I-1):0] data_o,

   output                          no_of_clk_pulses_in_fv_o
   // output                          no_of_clk_pulses_in_fv_low_time_o
  );


//----------------------------------
//
// Local Parameters
//
//----------------------------------

  // High Value
  localparam HIGH = 1'b1;

  // Low Value
  localparam LOW  = 1'b0;

  // Duration of a FV cycle
  // localparam NO_OF_CLK_PULSES_IN_FV_CYCLE     = ( REF_CLK_PULSES_IN_S_I/FRAME_RATE_I );

  // LV High Time
  // localparam NO_OF_CLK_PULSES_IN_LV_HIGH_TIME = IMAGE_WIDTH_IN_PIXELS_I;

  // LV Low Time
  // localparam NO_OF_CLK_PULSES_IN_LV_LOW_TIME  = LINE_BLANKING_CLK_PULSES_I;

  // FV High Time
  // localparam NO_OF_CLK_PULSES_IN_FV_HIGH_TIME = ( IMAGE_WIDTH_IN_PIXELS_I + LINE_BLANKING_CLK_PULSES_I ) * IMAGE_HEIGHT_IN_PIXELS_I;

  // FV Low Time
  // localparam NO_OF_CLK_PULSES_IN_FV_LOW_TIME  = NO_OF_CLK_PULSES_IN_FV_CYCLE - NO_OF_CLK_PULSES_IN_FV_HIGH_TIME;

  // Colour Band Counter
  // As there are total 8 bands of colour, 'NO_OF_CLK_PULSES_IN_LV_HIGH_TIME' is divided by 8.
  // localparam COLOUR_BAND_COUNTER_MAX_VALUE    = ( IMAGE_WIDTH_IN_PIXELS_I >> 2'd3 );

  // White Colour
  localparam WHITE  = 32'hff80ff80;

  // Yellow
  localparam YELLOW = 32'hff94ff00;

  // Blue
  localparam BLUE   = 32'hc81ac8bf;

  // Green
  localparam GREEN  = 32'hca4aca55;

  // Pink
  localparam PINK   = 32'h96f3969f;

  // Red
  localparam RED    = 32'h4cff4c54;

  // Violet
  localparam VIOLET = 32'h409e40d3;

  // Black
  localparam BLACK  = 32'h00800080;


//----------------------------------
//
// Local Variables
//
//----------------------------------

  reg        pixel_counter_type;
  reg  [31:0] pixel_counter;
  reg  [15:0] colour_band_counter;
  reg  [ 2:0] colour_band;

  reg         fv_counter_type;
  reg  [31:0] fv_counter;
  reg  [15:0] line_counter;
  reg  [31:0] no_of_clk_pulses_in_fv;
  reg  [31:0] no_of_clk_pulses_in_fv_high_time;
  reg  [31:0] no_of_clk_pulses_in_fv_low_time;
  reg         lv_f1;
  reg         lv_f2;


  wire        lv_ne_pl;
  wire [15:0] colour_band_counter_max_value;

//----------------------------------
//
// LV Counter Type
//
//----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          pixel_counter_type <= LOW;
        end
      else if ( ~fv_o )
        begin
          pixel_counter_type <= LOW;
        end
      else if ( ( pixel_counter_type == HIGH ) & ( pixel_counter == image_width_i - 1'b1 ) )
        begin
          pixel_counter_type <= LOW;
        end
      else if ( ( pixel_counter_type == LOW ) & ( pixel_counter == line_blanking_clk_pulses_i - 1'b1 ) )
        begin
          pixel_counter_type <= HIGH;
        end
    end


//----------------------------------
//
// LV Counter
//
//----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          pixel_counter <= 32'h0;
        end
      else if ( ~fv_o )
        begin
          pixel_counter <= 32'h0;
        end
      else if ( ( ( pixel_counter_type == HIGH ) & ( pixel_counter == image_width_i - 1'b1 ) ) |
                ( ( pixel_counter_type == LOW  ) & ( pixel_counter == line_blanking_clk_pulses_i - 1'b1  ) )
              )
        begin
          pixel_counter <= 32'h0;
        end
      else
        begin
          pixel_counter <= ( pixel_counter + 1'b1 );
        end
    end

//----------------------------------
//
// LV
//
//----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          lv_o <= 1'h0;
        end
      else if ( ~fv_o )
        begin
          lv_o <= 1'h0;
        end
      else if ( ( ( pixel_counter_type == HIGH ) & ( pixel_counter == image_width_i - 1'b1 ) ) |
                ( ( pixel_counter_type == LOW  ) & ( pixel_counter == line_blanking_clk_pulses_i - 1'b1  ) )
              )
        begin
          lv_o <= ~lv_o;
        end
    end

  // Flop of LV
  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          lv_f1 <= 1'h0;
          lv_f2 <= 1'h0;
        end
      else
        begin
          lv_f1 <= lv_o;
          lv_f2 <= lv_f1;
        end
    end

  // Falling Edge of LV.
  assign lv_ne_pl = ( ( ~lv_f1 ) & ( lv_f2 ) );

  // Counter for number of lines
  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          line_counter <= 16'h0;
        end
      else if ( ~fv_o )
        begin
          line_counter <= 16'h0;
        end
      else if ( lv_ne_pl )
        begin
          line_counter <= line_counter + 1'b1;
        end
    end

//  // Counter to count lines
//  always @ ( posedge clk or negedge reset_n )
//    begin
//      if ( ~reset_n )
//        begin
//          line_counter <= 32'h0;
//        end
//      else if ( ( pixel_counter_type == HIGH ) & ( pixel_counter == NO_OF_CLK_PULSES_IN_LV_HIGH_TIME - 1'b1 ) )
//        begin
//          if ( line_counter == ( IMAGE_HEIGHT_IN_PIXELS_I - 1'b1 ) )
//            begin
//              line_counter <= 32'h0;
//            end
//          else
//            begin
//              line_counter <= line_counter + 1'b1;
//            end
//        end
//    end
//
//  assign line_counter_full_o = ( ( ( pixel_counter_type == HIGH ) & ( pixel_counter == NO_OF_CLK_PULSES_IN_LV_HIGH_TIME - 1'b1 ) ) &
//                                 ( line_counter == ( IMAGE_HEIGHT_IN_PIXELS_I - 1'b1 ) )
//                               );


//----------------------------------
//
// FV High Time
//
//----------------------------------

  // How many number of clock cycles are in FV High time?
  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          no_of_clk_pulses_in_fv_high_time <= 32'h0;
        end
      else if ( ( fv_counter_type == HIGH ) &
                ( pixel_counter   == image_width_i  - 1'b1 ) &
                ( line_counter    == image_height_i - 1'b1 )
              )
        begin
          no_of_clk_pulses_in_fv_high_time <= fv_counter;
        end
    end

  // How many number of clock cycles are in FV cycle?
  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          no_of_clk_pulses_in_fv <= 32'b0;
        end
      else
        begin

          case ( img_fps_i )

            8'd15  : no_of_clk_pulses_in_fv <= 32'd56_00_000;

            8'd30  : no_of_clk_pulses_in_fv <= 32'd28_00_000;

            8'd60  : no_of_clk_pulses_in_fv <= 32'd14_00_000;

            default : no_of_clk_pulses_in_fv <= 32'd28_00_000;

          endcase

        end
    end

  assign no_of_clk_pulses_in_fv_o          = (no_of_clk_pulses_in_fv == 32'd14_00_000);
  // assign no_of_clk_pulses_in_fv_low_time_o = (no_of_clk_pulses_in_fv_low_time == NO_OF_CLK_PULSES_IN_FV_LOW_TIME);

  // How many number of clock cycles are in FV Low time?
  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          no_of_clk_pulses_in_fv_low_time <= 32'b0;
        end
      else
        begin
          no_of_clk_pulses_in_fv_low_time <= ( no_of_clk_pulses_in_fv - no_of_clk_pulses_in_fv_high_time );
        end
    end

//----------------------------------
//
// FV Counter Type
//
//----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          fv_counter_type <= LOW;
        end
      else if ( ( fv_counter_type == HIGH ) &
                ( pixel_counter   == image_width_i  - 1'b1 ) &
                ( line_counter    == image_height_i - 1'b1 )
              )
        begin
          fv_counter_type <= LOW;
        end
      else if ( ( fv_counter_type == LOW ) & ( fv_counter == no_of_clk_pulses_in_fv_low_time - 1'b1 ) )
        begin
          fv_counter_type <= HIGH;
        end
    end

//----------------------------------
//
// FV Counter
//
//----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          fv_counter <= 32'h0;
        end
      else if ( ( ( fv_counter_type == HIGH ) &
                  ( pixel_counter   == image_width_i  - 1'b1 ) &
                  ( line_counter    == image_height_i - 1'b1 )
                )   |
                ( ( fv_counter_type == LOW  ) & ( fv_counter == no_of_clk_pulses_in_fv_low_time - 1'b1  ) )
              )
        begin
          fv_counter <= 32'h0;
        end
      else
        begin
          fv_counter <= ( fv_counter + 1'b1 );
        end
    end


//----------------------------------
//
// FV
//
//----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          fv_o <= 1'h0;
        end
      else if ( ( ( fv_counter_type == HIGH ) &
                  ( pixel_counter   == image_width_i  - 1'b1 ) &
                  ( line_counter    == image_height_i - 1'b1 )
                )   |
                ( ( fv_counter_type == LOW  ) & ( fv_counter == no_of_clk_pulses_in_fv_low_time - 1'b1  ) )
              )        begin
          fv_o <= ~fv_o;
        end
    end


//----------------------------------
//
// Colour Band Counter
//
//----------------------------------

  // Maximum value of colour band counter
  assign colour_band_counter_max_value = ( image_width_i >> 2'd3 );

  // Colour band counter
  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          colour_band_counter <= 16'h0;
        end
      else if ( ~lv_o )
        begin
          colour_band_counter <= 16'h0;
        end
      else
        begin
          if ( colour_band_counter == ( colour_band_counter_max_value - 1'b1 ) )
            begin
              colour_band_counter <= 16'h0;
            end
          else
            begin
              colour_band_counter <= colour_band_counter + 1'b1;
            end
        end
    end


  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          colour_band <= 3'h0;
        end
      else if ( ~lv_o )
        begin
          colour_band <= 3'h0;
        end
      else if ( colour_band_counter == ( colour_band_counter_max_value - 2'd2 ) )
        begin
          colour_band <= colour_band + 1'b1;
        end
    end


  // assign colour_band_counter_full_o = ( colour_band_counter == colour_band_counter_max_value - 1);
//----------------------------------
//
// Data
//
//----------------------------------

  always @ ( posedge clk or negedge reset_n )
    begin
      if ( ~reset_n )
        begin
          data_o <= WHITE;
        end
      else
        begin
          case ( colour_band )

            3'd0 : data_o <= WHITE/* [31*(colour_band_counter[0]) -: 15] */;
            3'd1 : data_o <= YELLOW;
            3'd2 : data_o <= BLUE;
            3'd3 : data_o <= GREEN;
            3'd4 : data_o <= PINK;
            3'd5 : data_o <= RED;
            3'd6 : data_o <= VIOLET;
            3'd7 : data_o <= BLACK;

          endcase
        end
    end

endmodule
