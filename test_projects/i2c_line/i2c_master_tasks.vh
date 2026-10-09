// I2C bit-bang master tasks. Open-drain: master pulls low via m_sda_drive_low/m_scl=0.
// T_I2C is the half-bit delay in ns; bit period = 4*T_I2C, so 1250 -> ~200 kHz bus.
// Declared as a variable (not localparam) so the including TB can override it at
// runtime (e.g. T_I2C = 250 -> ~1 MHz) for bus-speed margin tests.
integer T_I2C = 1250;

task i2c_start;   // also repeated start
  begin
    m_sda_drive_low = 0; #(T_I2C);
    m_scl = 1;           #(T_I2C);
    m_sda_drive_low = 1; #(T_I2C);   // SDA falls while SCL high
    m_scl = 0;           #(T_I2C);
  end
endtask

task i2c_stop;
  begin
    m_sda_drive_low = 1; #(T_I2C);
    m_scl = 1;           #(T_I2C);
    m_sda_drive_low = 0; #(T_I2C);   // SDA rises while SCL high
  end
endtask

task i2c_write_byte(input [7:0] b, output ack);
  integer i;
  begin
    for (i = 7; i >= 0; i = i - 1) begin
      m_sda_drive_low = ~b[i]; #(T_I2C);
      m_scl = 1; #(2*T_I2C); m_scl = 0; #(T_I2C);
    end
    m_sda_drive_low = 0;       // release for slave ACK
    #(T_I2C); m_scl = 1; #(T_I2C);
    ack = ~sda_bus;            // low = ACK
    #(T_I2C); m_scl = 0; #(T_I2C);
  end
endtask

task i2c_read_byte(input send_ack, output [7:0] b);
  integer i;
  begin
    m_sda_drive_low = 0;       // release — slave drives
    for (i = 7; i >= 0; i = i - 1) begin
      #(T_I2C); m_scl = 1; #(T_I2C);
      b[i] = sda_bus;
      #(T_I2C); m_scl = 0; #(T_I2C);
    end
    m_sda_drive_low = send_ack; #(T_I2C);
    m_scl = 1; #(2*T_I2C); m_scl = 0; #(T_I2C);
    m_sda_drive_low = 0;
  end
endtask
