module grayscale_histogram (
    input wire clk,               // Clock input (133 MHz)
    input wire reset_n,           // Active-low reset input
    input wire frame_valid,       // Frame valid signal
    input wire line_valid,        // Line valid signal
    input wire [9:0] pixel_out,   // 10-bit pixel output from test pattern generator
    input wire rd_en,             // Read enable during blanking period
    input wire [9:0] rd_addr,     // Read address (for accessing histogram bins)
    input wire clear,             // Clear signal to reset histogram bins
    output reg [15:0] rd_data     // Read data (number of occurrences in histogram)
);

    reg [15:0] histogram [1023:0]; // 1024 bins for 10-bit pixel values (16-bit counters)
    reg [9:0] pixel_val;           // Register for holding the current pixel value

    integer i;

    // Histogram reset and update logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n || clear) begin
            // Reset histogram or clear when clear signal is high
            for (i = 0; i < 1024; i = i + 1)
                histogram[i] <= 16'b0;
        end else if (frame_valid && line_valid) begin
            // Increment histogram bin for the current pixel value
            pixel_val <= pixel_out;
            histogram[pixel_val] <= histogram[pixel_val] + 1'b1;
        end
    end

    // Readout logic (during blanking period)
    always @(posedge clk) begin
        if (!frame_valid && rd_en) begin
            // Output the histogram bin value based on rd_addr during blanking period
            rd_data <= histogram[rd_addr];
        end
    end

endmodule
