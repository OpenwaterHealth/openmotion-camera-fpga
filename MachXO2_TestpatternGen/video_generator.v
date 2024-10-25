module video_generator_10bit (
    input wire clk,       // 48 MHz clock input
    input wire rst,       // Reset signal
    output wire hsync,    // Horizontal sync signal
    output wire vsync,    // Vertical sync signal
    output reg [9:0] pixel_data, // 10-bit monochrome pixel data
    output wire active_video // Video valid signal
);

    // Parameters for 320x240 resolution, 8 bars
    localparam H_PIXELS = 320;
    localparam V_LINES = 240;
    localparam H_TOTAL = 400; // Horizontal total including blanking
    localparam V_TOTAL = 262; // Vertical total including blanking
    localparam BAR_WIDTH = H_PIXELS / 8; // Width of each bar (40 pixels)

    // Pixel clock division
    reg [3:0] clk_div = 0;
    wire pixel_clk = clk_div[3]; // Divide 48 MHz by 16 to get ~3 MHz pixel clock

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    // Horizontal and vertical counters
    reg [9:0] h_counter = 0;
    reg [9:0] v_counter = 0;

    // Generate horizontal sync, vertical sync, and active video signals
    assign hsync = (h_counter < (H_TOTAL - 80)) ? 1 : 0; // Horizontal sync timing (example values)
    assign vsync = (v_counter < (V_TOTAL - 22)) ? 1 : 0; // Vertical sync timing (example values)
    assign active_video = (h_counter < H_PIXELS) && (v_counter < V_LINES); // Video active region

    // Horizontal and vertical counters logic
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            h_counter <= 0;
            v_counter <= 0;
        end else begin
            if (h_counter < H_TOTAL - 1) begin
                h_counter <= h_counter + 1;
            end else begin
                h_counter <= 0;
                if (v_counter < V_TOTAL - 1) begin
                    v_counter <= v_counter + 1;
                end else begin
                    v_counter <= 0;
                end
            end
        end
    end

    // Generate the 8 monochrome bars with 10-bit grayscale values
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            pixel_data <= 10'b0;
        end else if (active_video) begin
            if (h_counter < BAR_WIDTH * 1) pixel_data <= 10'b0000000000; // Black
            else if (h_counter < BAR_WIDTH * 2) pixel_data <= 10'b0011111111; // Dark gray
            else if (h_counter < BAR_WIDTH * 3) pixel_data <= 10'b0111111111; // Gray
            else if (h_counter < BAR_WIDTH * 4) pixel_data <= 10'b1011111111; // Light gray
            else if (h_counter < BAR_WIDTH * 5) pixel_data <= 10'b1100000000; // Lighter gray
            else if (h_counter < BAR_WIDTH * 6) pixel_data <= 10'b1110000000; // Even lighter gray
            else if (h_counter < BAR_WIDTH * 7) pixel_data <= 10'b1111100000; // Near white
            else pixel_data <= 10'b1111111111; // White
        end else begin
            pixel_data <= 10'b0; // Blanking period, output black
        end
    end
endmodule
