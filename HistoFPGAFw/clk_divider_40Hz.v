module clk_divider_40Hz (
    input wire clk_48MHz,    // 48 MHz input clock
    input wire reset,        // Reset signal
    output reg clk_40Hz      // 40 Hz output clock
  );

  // Calculate the counter limit
  // 48 MHz / 40 Hz = 1,200,000 counts
  localparam integer COUNT_MAX = 251 / 2;  // Divide by 2 because we toggle the output every half cycle

  reg [20:0] counter = 0;  // 21-bit counter to handle up to 1200000 counts

  always @(posedge clk_48MHz)
  begin
    if (reset)
    begin
      counter <= 0;
      clk_40Hz <= 0;
    end
    else if (counter == COUNT_MAX - 1)
    begin
      counter <= 0;
      clk_40Hz <= ~clk_40Hz;  // Toggle the 40 Hz clock
    end
    else
    begin
      counter <= counter + 21'b1;
    end
  end

endmodule
