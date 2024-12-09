module camera_emulator (
    input wire clk_19mhz,   // 19 MHz input clock
    input wire reset_n,     // Active low reset signal
    output reg [9:0] pixel_data,  // 10-bit grayscale pixel data
    output reg hsync,       // Horizontal sync
    output reg vsync,       // Vertical sync
    output reg pclk         // Pixel clock
);

    // Timing parameters for 320x240 resolution at 15 FPS
    parameter H_ACTIVE = 320;        // Active horizontal pixels
    parameter H_FRONT_PORCH = 8;     // Front porch
    parameter H_SYNC_PULSE = 96;     // Sync pulse width
    parameter H_BACK_PORCH = 16;     // Back porch
    parameter H_TOTAL = H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
    
    parameter V_ACTIVE = 240;        // Active vertical lines
    parameter V_FRONT_PORCH = 2;     // Front porch
    parameter V_SYNC_PULSE = 2;      // Sync pulse width
    parameter V_BACK_PORCH = 4;      // Back porch
    parameter V_TOTAL = V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;
    
    // Pixel clock generation (divide 19 MHz clock)
    reg [15:0] clk_div;
    always @(posedge clk_19mhz or negedge reset_n) begin
        if (!reset_n) begin
            clk_div <= 0;
            pclk <= 0;
        end else begin
            if (clk_div == 15) begin  // Divide 19 MHz by 16 to get ~1.1875 MHz pixel clock
                pclk <= ~pclk;
                clk_div <= 0;
            end else begin
                clk_div <= clk_div + 1;
            end
        end
    end

    // Horizontal and vertical counters
    reg [9:0] h_count;
    reg [9:0] v_count;

    // Sync signal and pixel data generation
    always @(posedge pclk or negedge reset_n) begin
        if (!reset_n) begin
            h_count <= 0;
            v_count <= 0;
            hsync <= 1;
            vsync <= 1;
            pixel_data <= 10'b0;
        end else begin
            // Horizontal counter
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                // Vertical counter
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end

            // HSYNC generation
            if (h_count < H_SYNC_PULSE)
                hsync <= 0;
            else
                hsync <= 1;

            // VSYNC generation
            if (v_count < V_SYNC_PULSE)
                vsync <= 0;
            else
                vsync <= 1;

            // Pixel data generation (grayscale bars)
            if (h_count < H_ACTIVE && v_count < V_ACTIVE) begin
                pixel_data <= h_count[9:0];  // Generate grayscale pattern
            end else begin
                pixel_data <= 10'b0;  // Blank pixels outside active area
            end
        end
    end

endmodule
