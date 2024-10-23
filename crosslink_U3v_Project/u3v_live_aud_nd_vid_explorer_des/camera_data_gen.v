module camera_data_gen (
    input  wire        en,          // enable
    input  wire       clk,         // System clock input
    output reg        line_valid,   // Line synchronization signal
    output reg        frame_valid,  // Frame synchronization signal
    output reg  [9:0] pixel_data,   // 16-bit bus for pixel data
    output wire done
);

  // Parameters for image dimensions
  localparam WIDTH = 1920;  // Example width of the image
  localparam HEIGHT = 1280;  // Example height of the image
  localparam TICKS_TO_WAIT_LV = 10;
  localparam TICKS_TO_WAIT_FV = 100;

  // Memory to store image data (initialized with example image data)
  reg [9:0] image_data[0:WIDTH*HEIGHT-1];

  // Load image data from raw file (replace this example with actual initialization code)
  initial begin
    $readmemh("test_1920x1280.txt", image_data);
  end

  // Internal counters and signals
  reg [19:0] pixel_count = 0;  // Counter for pixels within a line
  reg [19:0] line_count = 0;  // Counter for frames
  reg [7:0] wait_counter = 0;

  reg out_en = 0;
  assign done = (pixel_count == (0)) && (line_count == (HEIGHT));
  
  reg [23:0] pixel_number = 0;
  
  always @(posedge clk) begin
    if (out_en) begin
      if(wait_counter > 0) begin
        wait_counter <= wait_counter - 1;
        line_valid <= 0;
        pixel_data <= 0;
      end else begin
        // Increment pixel count
        pixel_count <= pixel_count + 1;

        // Check for end of line
        if (pixel_count == WIDTH + 1 ) begin
          pixel_count <= 0;
          line_valid   <= 0;  // Assert line sync at the beginning of a line
          wait_counter <= TICKS_TO_WAIT_LV; 
        end else begin
          line_valid <= 1;
        end

        // Check for end of frame
        if (pixel_count == 0 && line_count == HEIGHT ) begin  // at the end of the frame...
          line_count <= 0;
          frame_valid <= 0; 
          //wait_counter <= TICKS_TO_WAIT_FV; // not necessary since the frames are synced to FSIN

        end else if (pixel_count == 0) begin
          line_count <= line_count + 1;
          frame_valid <= 1;
        end else if (pixel_count ==1 && line_count == 0) begin
          frame_valid <= 1;
        end

        // Output pixel data
        //pixel_number <= line_count*WIDTH + (pixel_count-1);
        pixel_data <= image_data[(line_count-1) * WIDTH + (pixel_count-1)]; // Ignore Blue channel (in this example)
      end

    end else begin
        line_count <= 0;
        pixel_count <= 0;
        frame_valid <= 0;
    end
  end

  always @(posedge en, posedge done) begin 
    if(done) begin out_en <= 0; end
    else  begin out_en <= 1; end
  end
endmodule
