

module simple_fsm (
    input  clk,
    input  reset,
    input start,
    output out
);
  reg [1:0] state, next_state;

  localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;  // binary 


  /* Timer Definitions */
  //reg         timer_enable = 0;
  reg  [31:0] clock_frequency = 100;  //100_000_000;  // 100 MHz
  reg  [31:0] time_in_seconds = 2;  // 2 seconds
  //reg         state_changed;
  wire        timer_done;

  // Instantiate Timer module
  Timer timer_i (
      .clk(clk),
      .enable(timer_enable),
      .clock_frequency(clock_frequency),
      .time_in_seconds(time_in_seconds),
      .timer_done(timer_done)
  );
  
  wire timer_enable = (state == S0 || state == S1) && ~timer_done;
  assign out = (state == S1);
  wire state_changed = (state != next_state);

  //State Machine Definitions
  always @(*) begin : next_state_logic
    case (state)
      S0: begin
        if (timer_done) begin
          //        timer_enable = 0;
          next_state = S1;
        end else begin
          //        timer_enable = 1;
          next_state = S0;
        end
      end
      S1: begin
        if (timer_done) begin
          //        timer_enable = 0;
          next_state = S2;
        end else begin
          //        timer_enable = 1;
          next_state = S1;
        end
      end
      S2: begin
        if (reset) next_state = S1;
        else next_state = S2;
      end
      default: next_state = S0;
    endcase
  end

  always @(posedge clk) begin : state_assignment
    state <= next_state;
  end
endmodule
