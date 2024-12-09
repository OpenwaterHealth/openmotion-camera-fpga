module grayscale_color_bar (
    input wire clk,            // 133.00 MHz clock
    input wire reset_n,        // Active low reset
    output reg [9:0] pixel_out,// 10-bit grayscale pixel
    output reg line_valid,     // Line valid signal
    output reg frame_valid     // Frame valid signal
);

    // Constants
    localparam FRAME_WIDTH = 960; // should be 1920 but beause we're throwing two pixels at a time, cut it in half
    localparam FRAME_HEIGHT = 1280;
    localparam LINE_BLANK_CYCLES = 236;
    localparam PIXELS_PER_LINE = FRAME_WIDTH;
    localparam CYCLES_PER_LINE = FRAME_WIDTH + LINE_BLANK_CYCLES;
    localparam PIXELS_PER_FRAME = FRAME_WIDTH * FRAME_HEIGHT;
    localparam FRAME_DELAY_CYCLES = 3250000 - (FRAME_HEIGHT * CYCLES_PER_LINE);
	
	localparam IMAGE_PATTERN = 4'd4;

    // Registers to track positions
    reg [18:0] pixel_counter;  // Counter for pixels within a frame (19 bits to hold up to 240x180 pixels)
    reg [11:0] line_counter;   // Counter for lines
    reg [31:0] delay_counter;  // Counter for frame delay
    reg frame_active;          // Track if frame is being transmitted
    reg blanking_active;       // Track blanking period

    // Main logic
    always @(posedge clk) begin
        if (!reset_n) begin
            pixel_counter <= 0;
            line_counter <= 0;
            delay_counter <= 0;
            frame_valid <= 0;
            line_valid <= 0;
            frame_active <= 1;
            blanking_active <= 0;
            pixel_out <= 10'b0;
        end else begin
            if (frame_active) begin
                frame_valid <= 1;

                if (!blanking_active) begin
                    // Line valid signal during active pixels
                    if (pixel_counter < PIXELS_PER_LINE) begin
                        line_valid <= 1;
						case(IMAGE_PATTERN)
							4'd0: pixel_out <= 0;  //10'h3ff;// Wrapping grayscale values
							4'd1: pixel_out <= 10'b1111111111;  //10'h3ff;// Wrapping grayscale values
							4'd2: pixel_out <= pixel_counter % 1024;  //10'h3ff;// Wrapping grayscale values
							4'd3: pixel_out <= 10'h2ff; //Wrapping grayscale values
							4'd4: pixel_out <= line_counter % 1024;  //10'h3ff;// Wrapping grayscale values
							4'd5: pixel_out <= pixel_counter % 2;  //10'h3ff;// Wrapping grayscale values
							default: pixel_out <= pixel_counter % 1024;  //10'h3ff;// Wrapping grayscale values
							
						endcase
						pixel_counter <= pixel_counter + 1;
                    end else begin 
                        // Start blanking period
                        line_valid <= 0;
                        blanking_active <= 1;
                        pixel_counter <= 0;
                    end
                end else begin
                    // Handle blanking period
                    if (pixel_counter < LINE_BLANK_CYCLES - 1) begin
                        pixel_counter <= pixel_counter + 1;
                    end else begin
                        blanking_active <= 0;
                        pixel_counter <= 0;
                        line_counter <= line_counter + 1;
                        if (line_counter == FRAME_HEIGHT - 1) begin
                            frame_active <= 0;
                            line_counter <= 0;
                        end
                    end
                end
            end else begin
                // Handle frame delay
                if (delay_counter < FRAME_DELAY_CYCLES) begin
                    delay_counter <= delay_counter + 1;
                end else begin
                    delay_counter <= 0;
                    frame_active <= 1;
                end
                frame_valid <= 0;
            end
        end
    end
endmodule