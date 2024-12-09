module soft_ram_dp (
    input [9:0] WrAddress,
    input [31:0] Data,
    input WrClock,
    input WE,
    input WrClockEn,
    input [9:0] RdAddress,
    output reg [31:0] Q
);

    reg [31:0] mem [0:1023];  // Define memory array

    // Write logic
    always @(posedge WrClock) begin
        if (WrClockEn) begin
            if (WE) begin
                mem[WrAddress] <= Data;
            end
        end
    end

    // Read logic
    always @(posedge WrClock) begin
        if (WrClockEn) begin
            Q <= mem[RdAddress];
        end
    end

endmodule
