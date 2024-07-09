module Timer(
    input wire clk,       // Clock input
    input wire enable,    // Enable input
    input wire [31:0] clock_frequency,  // Clock frequency input (in Hz)
    input wire [31:0] time_in_seconds,  // Time in seconds
    output reg timer_done  // Output indicating timer expiration
);

reg [31:0] counter;

always @(posedge clk) begin
    if (enable) begin
        if (counter == clock_frequency * time_in_seconds - 1) begin
            counter <= 0;
            timer_done <= 1;
        end
        else begin
            counter <= counter + 1;
            timer_done <= 0;
        end
    end
    else begin
        counter <= 0;
        timer_done <= 0;
    end
end

endmodule
