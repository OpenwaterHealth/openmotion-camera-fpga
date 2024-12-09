module rom_i (
    input [11:0] Address,
    input OutClock,
    input OutClockEn,
    input Reset,
    output reg [23:0] Q
);

reg [23:0] mem [0:1099];

initial begin
    $readmemh("i2c_pipeline/camera_map.mem", mem);
end

always @(posedge OutClock or negedge Reset) begin
    if (!Reset)
        Q <= 24'h000000;
    else
        Q <= mem[Address];
end

endmodule