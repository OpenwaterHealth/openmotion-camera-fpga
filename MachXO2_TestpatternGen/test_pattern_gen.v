module grayscale_color_bar (
    input wire clk,            // 133.00 MHz clock
    input wire reset_n,        // Active low reset
    output reg [9:0] pixel_out,// 10-bit grayscale pixel
    output reg line_valid,     // Line valid signal
    output reg frame_valid     // Frame valid signal
);

    // Constants
    localparam FRAME_WIDTH = 320;
    localparam FRAME_HEIGHT = 240;
    localparam LINE_BLANK_CYCLES = 400;
    localparam PIXELS_PER_LINE = FRAME_WIDTH;
    localparam CYCLES_PER_LINE = FRAME_WIDTH + LINE_BLANK_CYCLES;
    localparam PIXELS_PER_FRAME = FRAME_WIDTH * FRAME_HEIGHT;
    localparam FRAME_DELAY_CYCLES = 475000 - (FRAME_HEIGHT * CYCLES_PER_LINE);

    // Grayscale bar values (10-bit values from 0 to 1023)
    localparam [9:0] GRAYSCALE_BAR_0 = 10'b0000000000;  // Black
    localparam [9:0] GRAYSCALE_BAR_1 = 10'b0011111111;  // Dark gray
    localparam [9:0] GRAYSCALE_BAR_2 = 10'b0111111111;  // Gray
    localparam [9:0] GRAYSCALE_BAR_3 = 10'b1011111111;  // Light gray
    localparam [9:0] GRAYSCALE_BAR_4 = 10'b1111111111;  // White
    localparam [9:0] GRAYSCALE_BAR_5 = 10'b1001111111;  // Light gray-blue
    localparam [9:0] GRAYSCALE_BAR_6 = 10'b1101111111;  // Lighter gray
    localparam [9:0] GRAYSCALE_BAR_7 = 10'b0101111111;  // Another gray variant
	
    // Registers to track positions
    reg [18:0] pixel_counter;  // Counter for pixels within a frame (19 bits to hold up to 240x180 pixels)
    reg [11:0] line_counter;   // Counter for lines
    reg [31:0] delay_counter;  // Counter for frame delay
    reg frame_active;          // Track if frame is being transmitted
    reg blanking_active;       // Track blanking period

    // Main logic
    always @(posedge clk or negedge reset_n) begin
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
                        // pixel_out <= pixel_counter % 1024;  // Wrapping grayscale values
						// Divide the frame into 8 equal vertical segments of 40 pixels each
                        if (pixel_counter < 40) begin
                            pixel_out <= GRAYSCALE_BAR_0;
                        end else if (pixel_counter < 80) begin
                            pixel_out <= GRAYSCALE_BAR_1;
                        end else if (pixel_counter < 120) begin
                            pixel_out <= GRAYSCALE_BAR_2;
                        end else if (pixel_counter < 160) begin
                            pixel_out <= GRAYSCALE_BAR_3;
                        end else if (pixel_counter < 200) begin
                            pixel_out <= GRAYSCALE_BAR_4;
                        end else if (pixel_counter < 240) begin
                            pixel_out <= GRAYSCALE_BAR_5;
                        end else if (pixel_counter < 280) begin
                            pixel_out <= GRAYSCALE_BAR_6;
                        end else if (pixel_counter < 320) begin
                            pixel_out <= GRAYSCALE_BAR_7;
                        end
                        
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
