module ram_dq (
    input wire Clock,
    input wire ClockEn,
    input wire Reset,
    input wire WE,
    input wire [9:0] Address,
    input wire [23:0] Data,
    output reg [23:0] Q
);
    integer i = 0;
    reg [23:0] memory [0:1023]; // Assuming 1024 words of 32 bits each

    always @(posedge Clock) begin
        if (Reset) begin
            // Reset logic
            for (i = 0; i < 1024; i = i + 1) begin
                memory[i] <= 24'h00_0000;
            end
        end else if (ClockEn) begin
            // Write enable
            if (WE) begin
                memory[Address] <= Data;
            end
            // Read operation
            Q <= memory[Address];
        end
    end

endmodule
