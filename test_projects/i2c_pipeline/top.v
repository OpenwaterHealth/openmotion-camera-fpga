`timescale 1ps / 1ps

`include "i2c_pipeline/timer.v"
`include "i2c_pipeline/i2c_regmap.v"

module top (
    input clk_osc,
    input reset,
    input i2c_done,
    inout scl,
    inout sda,
    output q,
    output wire clock_out,
    output wire serial_out,
    output CMOS_IO_2
);

  /*-----------------------------I2C SETUP ------------------------------------*/
  localparam DATA_WIDTH = 8;
  localparam REGISTER_WIDTH = 16;
  localparam ADDRESS_WIDTH = 7;
  localparam CLOCK_FREQUENCY = 24_000_000;  //50_000_000;
  localparam CLOCK_PERIOD = 1e9 / CLOCK_FREQUENCY;

  wire i2c_master_reset_n = reset && (state == S_WRITE_CONFIG || state == S_READ_TEMP);
  wire [REGISTER_WIDTH-1:0] i2c_master_register_address;
  reg [15:0] i2c_master_divider = 16'h001d;  // calculated using 
  wire [7:0] i2c_master_mosi_data;

  wire i2c_master_clock;
  wire i2c_master_enable;
  wire i2c_master_read_write;
  wire [ADDRESS_WIDTH-1:0] i2c_master_device_address;
  wire [DATA_WIDTH-1:0] i2c_master_miso_data;
  //  wire                      i2c_master_busy;  // fix when insterting again later
  wire cmd;  // ~readwrite
  //  wire                      i2c_done;         // fix when insterting again later
  //reg i2c_done = 1;  // this needs to become a square wave to get the simulation to work
  wire config_done;
  wire i2c_enable;

  assign i2c_master_enable     = i2c_enable;  //q && ~config_done && i2c_done;
  assign i2c_master_read_write = ~cmd;
  //  assign i2c_done                    = ~i2c_master_busy;
  wire register_list = (state == S_WRITE_CONFIG) ? 1 : 0;
  i2c_regmap i2c_regmap_inst (
      .rst_n        (i2c_master_reset_n),
      .clk          (i2c_master_clock),
      .config_done  (config_done),
      .cmd          (cmd),
      .i2c_done     (i2c_done),            //
      .i2c_rqt      (),
      .register_list(register_list),

      .addr_dev  (i2c_master_device_address),
      .addr_reg_H(i2c_master_register_address[15:8]),
      .addr_reg_L(i2c_master_register_address[7:0]),
      .data_wr_H (i2c_master_mosi_data),
      .data_wr_L (),
      .data_rd   ()                                    //????
  );

  /*----------------- OSCI -------------------------*/
  /*
  wire clk_osc;  // clock out wired to I1
  defparam I1.HFCLKDIV = 4;  // 1,2,4,8
  OSCI I1 (
      .HFOUTEN (1'b1),
      .HFCLKOUT(clk_osc),
      .LFCLKOUT(LFCLKOUT)
  );*/

  assign clock_out    =  clk_osc; // pixel clock out
  assign i2c_master_clock    =   clk_osc; // clock to i2c


  /*------------TIMER ---------------------*/
  reg [31:0] InputFrequency = 32'h000bc20;  //32'h0bebc20;
  wire TimerEnable;
  wire [31:0] TimerTime;
  wire TimerDone;

  Timer timer_i (
      .clk            (clk_osc),         // Clock input
      .enable         (TimerEnable),     // Enable input
      .clock_frequency(InputFrequency),  // Clock frequency input (in Hz)
      .time_in_seconds(TimerTime),       // Time in seconds
      .timer_done     (TimerDone)        // Output indicating timer expiration
  );


  /*------------STATE MACHINE-------------*/
  /* 
	State Machine Definition
	Start in IDLE
	Immediately write the registers to the camera
	Wait 1S
	Read the camera temperature
	Idle until
	Read camera temperature after 30 seconds
	Execute I2C command
	*/

  localparam S_IDLE = 8'h00;
  localparam S_START = 8'h01;
  localparam S_WAIT_1S = 8'h02;
  localparam S_WAIT_30S = 8'h03;
  localparam S_WRITE_CONFIG = 8'h04;
  localparam S_READ_TEMP = 8'h05;

  reg                                         [7:0] state = 1;
  reg                                         [7:0] next_state = 0;
  reg                                               initialized = 0;

  //Wire up state machine outputs
  wire state_changed = (state != next_state);
  assign q = TimerDone;
  assign i2c_enable = (state == S_WRITE_CONFIG || state == S_READ_TEMP);
  assign TimerEnable = (state == S_START || state == S_WAIT_1S || state == S_WAIT_30S) && ~TimerDone;
  assign TimerTime = (state == S_WAIT_30S) ? 32'h00000009 : (state == S_WAIT_1S) ? 32'h00000001 : 32'h00000001;
  assign uart_enable = i2c_enable;

  wire camera_reset;
  assign camera_reset = (state == S_START);
  assign CMOS_IO_2 = camera_reset;

  always @(*) begin

    case (state)
      S_START: begin
        if (TimerDone) begin  // when the counter reaches 
          next_state = S_IDLE;
        end else begin
          next_state = S_START;
        end
      end
      S_IDLE: begin
        if (~initialized) begin  // start S_WRITE_CONFIG if not initialized
          next_state = S_WRITE_CONFIG;
        end else begin  // loop back to idle if no 
          next_state = S_IDLE;
        end

      end
      S_WRITE_CONFIG: begin
        if (config_done && i2c_done) begin  //???
          next_state = S_WAIT_30S;
        end else begin
          next_state = S_WRITE_CONFIG;
        end
      end
      S_WAIT_30S: begin
        if (TimerDone) begin  // when the counter reaches 
          next_state = S_READ_TEMP;
        end else begin
          next_state = S_WAIT_30S;
        end
      end
      S_WAIT_1S: begin
        if (TimerDone) begin  // when the counter reaches 
          next_state = S_WAIT_30S;
        end else begin
          next_state = S_WAIT_1S;
        end
      end
      S_READ_TEMP: begin
        if (config_done && i2c_done) begin  // when the counter reaches 
          next_state = S_WAIT_30S;
        end else begin
          next_state = S_READ_TEMP;
        end
      end
    endcase

  end

  always @(posedge clk_osc) begin : state_assignment
    state <= next_state;
  end

endmodule
