
module histogram_module (
    input clk,
    input reset,
    input [19:0] pixel_data,
    input frame_valid,
    input line_valid,
    input spi_clk_i,
    output spi_mosi_o,
    output spi_clk_o,
    input spi_en,
    output [5:0] debug,
    output [9:0] debug2
  );

  // Histogram generator
  wire [23:0] data;
  reg [9:0] bin;

  // Control
  wire serializer_done;
  reg prev_serializer_done;
  reg serializer_total_done =0;
  reg flag = 0;
  reg [7:0] frame_counter;
  
  wire pixel_valid = frame_valid && line_valid;

  wire [9:0] pixel_a = pixel_data[9:0];
  wire [9:0] pixel_b = pixel_data[19:10];

  wire [23:0] data_a;
  wire [23:0] data_b;

  parameter IDLE = 2'b00, HISTO = 2'b01, SERIALIZE = 2'b11;
  reg [1:0] state = IDLE;

  always @(posedge clk)
  begin
    if (reset)
    begin
      state <= IDLE;
    end
    else
    begin
      case (state)
        IDLE:
        begin
          if (frame_valid)
            state <= HISTO;
        end
        HISTO:
        begin
          if (!frame_valid)
            state <= SERIALIZE;
        end
        SERIALIZE:
        begin
          if (serializer_done && bin == 10'h0 && flag == 1)
            state <= IDLE;
        end
      endcase
    end
  end

  always @(posedge clk)
  begin
    if (reset | state !=SERIALIZE)
    begin
      bin <= 10'h3ff;
      prev_serializer_done <= 1'b0;
      flag <= 0; // set the flag low to show that a serialization has ended
    end
    else
    begin
      prev_serializer_done <= serializer_done; // Store the previous state of serializer_done
      if (state == SERIALIZE && !prev_serializer_done && serializer_done)
      begin
        bin <= bin + 10'b0000000001; // Increment on the positive edge of serializer_done
      end

      if(bin == 1)
        flag <= 1; // set the flag high to show that a serialization has started
    end
  end
  
  histogram3 histo_a (
               .clk(clk),          // reset - zeros the histogram
               .rst(reset),          // clock
               .rw(frame_valid),           // read/write, when reading outputs histo data/bin num until done

               .pixel (pixel_a),  // 10 bit data for each pixel
               .line_valid (line_valid),
			   .frame_valid (frame_valid),
               .data(data_a),       //    when writing, on every rising edge of CLK adds one to the histogram
               .bin(bin)
             );

  assign data = data_a + data_b;
  
  wire [7:0] spacer = (bin == 10'h3ff) ? frame_counter : 8'b0;
  always @(negedge frame_valid, posedge reset) begin
    if(reset)
      frame_counter <= 8'b0;
    else
      frame_counter <= frame_counter + 8'b1;
  end
   
  Serializer seralizer_i (
               .fast_clk_in(spi_clk_i),
               .reset(reset | (state != SERIALIZE)),
               .data_in({spacer,data}),
               .serial_out(spi_mosi_o),
               .slow_clk_out(spi_clk_o),
               .done(serializer_done),
               .debug ()
             ); 
  assign debug2 = frame_valid ? pixel_data : bin;
  //assign debug2 = data[9:0];


  assign debug[0] = spi_clk_o;
  assign debug[1] = spi_mosi_o;
  assign debug[2] = line_valid;
  assign debug[3] = frame_valid;
  assign debug[4] = state[0];
  assign debug[5] = state[1];

  assign dbg = bin[0];


endmodule
