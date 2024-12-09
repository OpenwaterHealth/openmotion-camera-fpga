`timescale 1 ns / 1 ps

`include "histogram_pipeline/soft_ram_dp.v"

module ram_dp_tb;
    reg [9:0] WrAddress = 10'b0;
    reg [31:0] Data = 32'b0;
    reg WrClock = 0;
    reg WE = 0;
    reg WrClockEn = 0;
    reg [9:0] RdAddress = 10'b0;
    wire [31:0] Q;

    integer i0 = 0, i1 = 0, i2 = 0, i3 = 0, i4 = 0, i5 = 0, i6 = 0;

    //GSR GSR_INST (.GSR(1'b1));
    //PUR PUR_INST (.PUR(1'b1));

    soft_ram_dp u1 (
        .WrAddress(WrAddress),
        .Data(Data),
        .WrClock(WrClock),
        .WE(WE), 
        .WrClockEn(WrClockEn),
        .RdAddress(RdAddress),
        .Q(Q)
    );

    // Dump file declaration
    initial begin
        $dumpfile("out/ram_dp_tb.vcd");
        $dumpvars(0, ram_dp_tb); // Dump all signals
    end

    initial begin
        WrAddress <= 0;
        #100;
        #10;
        for (i1 = 0; i1 < 2054; i1 = i1 + 1) begin
            @(posedge WrClock);
            #1  WrAddress <= WrAddress + 1'b1;
        end
    end

    initial begin
        Data <= 0;
        #100;
        #10;
        for (i2 = 0; i2 < 1027; i2 = i2 + 1) begin
            @(posedge WrClock);
            #1  Data <= Data + 1'b1;
        end
    end

    always #5.00 WrClock <= ~WrClock;

    initial begin
        WE <= 0; //1'b0;
        #10;
        for (i4 = 0; i4 < 1027; i4 = i4 + 1) begin
            @(posedge WrClock);
            #1  WE <= 0; //1'b1;
        end
        WE <= 1'b1;
    end

    initial begin
        WrClockEn <= 1'b0;
        #100;
        #10;
        WrClockEn <= 1'b1;
    end

    initial begin
        RdAddress <= 0;
        #100;
        #10;
        for (i6 = 0; i6 < 2054; i6 = i6 + 1) begin
            #10;
            RdAddress <= RdAddress + 1'b1;
        end
        #100000
        $display("Memory verification completed.");
        $finish;
    end
endmodule
