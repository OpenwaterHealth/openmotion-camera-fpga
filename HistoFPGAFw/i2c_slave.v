// i2c_slave.v — synthesizable 7-bit-address I2C slave, byte register interface.
// Oversampling design: SCL/SDA are double-flop synchronized to clk and all
// edges are detected in the clk domain. clk must be >= ~20x the SCL rate
// (24 MHz oscillator vs 400 kHz - 1 MHz bus). No clock stretching.
// Write:  S addr+W [ptr] [data]+ P      (pointer auto-increments per data byte)
// Read:   S addr+W [ptr] Sr addr+R [data]+ P   (auto-increments per byte)
module i2c_slave #(
    parameter [6:0] I2C_ADDR = 7'h5A
) (
    input  wire       clk,
    input  wire       reset,       // active-high synchronous
    input  wire       scl_i,
    input  wire       sda_i,
    output reg        sda_oe,      // 1 = pull SDA low
    output reg  [7:0] reg_addr,
    output reg  [7:0] wr_data,
    output reg        wr_strobe,   // 1-clk pulse: commit wr_data to reg_addr
    input  wire [7:0] rd_data      // combinational read of reg_addr
);

  reg [1:0] scl_sync, sda_sync /* synthesis syn_preserve=1 */;
  reg scl_q, sda_q;
  wire scl = scl_sync[1];
  wire sda = sda_sync[1];
  always @(posedge clk) begin
    scl_sync <= {scl_sync[0], scl_i};
    sda_sync <= {sda_sync[0], sda_i};
    scl_q <= scl;
    sda_q <= sda;
  end
  wire scl_rise   = scl & ~scl_q;
  wire scl_fall   = ~scl & scl_q;
  wire start_cond = scl & scl_q & sda_q & ~sda;
  wire stop_cond  = scl & scl_q & ~sda_q & sda;

  localparam [3:0] ST_IDLE    = 4'd0,
                   ST_ADDR    = 4'd1,
                   ST_ACK_A   = 4'd2,
                   ST_PTR     = 4'd3,
                   ST_ACK_P   = 4'd4,
                   ST_WDATA   = 4'd5,
                   ST_ACK_W   = 4'd6,
                   ST_RD_LOAD = 4'd7,
                   ST_RDATA   = 4'd8;

  reg [3:0] state;
  reg [3:0] bit_cnt;
  reg [7:0] sh;
  reg       rw_bit;
  reg       ack_rx;

  always @(posedge clk) begin
    wr_strobe <= 1'b0;
    if (reset) begin
      state <= ST_IDLE; sda_oe <= 1'b0; bit_cnt <= 4'd0;
      rw_bit <= 1'b0; ack_rx <= 1'b0;
      reg_addr <= 8'h00; wr_data <= 8'h00; sh <= 8'h00;
    end else if (start_cond) begin
      state <= ST_ADDR; bit_cnt <= 4'd0; sda_oe <= 1'b0;
    end else if (stop_cond) begin
      state <= ST_IDLE; sda_oe <= 1'b0;
    end else begin
      case (state)
        ST_IDLE: sda_oe <= 1'b0;   // hardening: never hold the bus while idle

        ST_ADDR: begin
          if (scl_rise && bit_cnt < 4'd8) begin
            sh <= {sh[6:0], sda}; bit_cnt <= bit_cnt + 4'd1;
          end
          if (scl_fall && bit_cnt == 4'd8) begin
            if (sh[7:1] == I2C_ADDR) begin
              rw_bit <= sh[0]; sda_oe <= 1'b1; state <= ST_ACK_A;
            end else state <= ST_IDLE;
          end
        end

        ST_ACK_A: if (scl_fall) begin
          bit_cnt <= 4'd0;
          if (rw_bit) begin sda_oe <= 1'b0; state <= ST_RD_LOAD; end
          else        begin sda_oe <= 1'b0; state <= ST_PTR;     end
        end

        ST_PTR: begin
          if (scl_rise && bit_cnt < 4'd8) begin
            sh <= {sh[6:0], sda}; bit_cnt <= bit_cnt + 4'd1;
          end
          if (scl_fall && bit_cnt == 4'd8) begin
            reg_addr <= sh; sda_oe <= 1'b1; state <= ST_ACK_P;
          end
        end

        ST_ACK_P: if (scl_fall) begin
          bit_cnt <= 4'd0; sda_oe <= 1'b0; state <= ST_WDATA;
        end

        ST_WDATA: begin
          if (scl_rise && bit_cnt < 4'd8) begin
            sh <= {sh[6:0], sda}; bit_cnt <= bit_cnt + 4'd1;
          end
          if (scl_fall && bit_cnt == 4'd8) begin
            wr_data <= sh; wr_strobe <= 1'b1;
            sda_oe <= 1'b1; state <= ST_ACK_W;
          end
        end

        ST_ACK_W: if (scl_fall) begin
          bit_cnt <= 4'd0; sda_oe <= 1'b0;
          reg_addr <= reg_addr + 8'd1;
          state <= ST_WDATA;
        end

        ST_RD_LOAD: begin        // one clk to settle rd_data after pointer change
          sh <= rd_data;
          sda_oe <= ~rd_data[7]; // present MSB (SCL is low here)
          bit_cnt <= 4'd0;
          state <= ST_RDATA;
        end

        ST_RDATA: begin
          if (scl_fall) begin
            if (bit_cnt < 4'd7) begin
              sda_oe <= ~sh[6];
              sh <= {sh[6:0], 1'b0};
              bit_cnt <= bit_cnt + 4'd1;
            end else if (bit_cnt == 4'd7) begin
              sda_oe <= 1'b0;              // release for master ACK/NACK
              bit_cnt <= 4'd8;
            end else if (bit_cnt == 4'd9) begin
              reg_addr <= reg_addr + 8'd1;
              if (ack_rx) state <= ST_RD_LOAD;
              else        state <= ST_IDLE;   // await STOP / repeated START
            end
          end
          if (scl_rise && bit_cnt == 4'd8) begin
            ack_rx <= ~sda; bit_cnt <= 4'd9;
          end
        end

        default: begin state <= ST_IDLE; sda_oe <= 1'b0; end
      endcase
    end
  end
endmodule
