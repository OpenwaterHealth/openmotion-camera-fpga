
module histogram (
    input wire rst,          // reset - zeros the histogram
    input wire clk,          // clock
    input wire rw,           // read/write, when reading outputs histo data/bin num until done
    input wire fast_clk,
    input  wire [9:0] pixel,  // 10 bit data for each pixel
    input wire pixel_valid,
    input wire image_done,
    output reg histo_done, // flips high when 
    input wire[ 9:0] bin,
    output reg [23:0] data       //    when writing, on every rising edge of CLK adds one to the histogram
    );

    // Parameters
    parameter NUM_BINS = 1024;
    parameter READ = 0, WRITE = 1;

    // Clock and reset
    wire mem_clk = fast_clk;
    wire mem_reset = rst;
    wire mem_write;
    assign mem_write = fast_clk;

    reg [9:0] mem_addr;

    // Histogram output
    reg [23:0] hist_i;
    wire [23:0] hist_o;

    always @(posedge fast_clk) begin
        if(image_done) begin
            histo_done = 1;
        end else begin
            histo_done = 0;
        end
    end

    // RAM module instance
    ram_dq ram_inst (
        .Clock(mem_clk),
        .ClockEn(~mem_reset), // Enable clock only when not in reset
        .Reset(mem_reset),
        .WE(mem_write), // Always write-enable
        .Address(mem_addr),
        .Data(hist_i), // Data input 
        .Q(hist_o) // Output data
    );
    always @(posedge fast_clk) begin
        if(rw == WRITE) begin           // if write mode, read and increment the counter
            if(pixel_valid) begin
                mem_addr = pixel;
                hist_i = hist_o + 1;
            end else begin
                hist_i = hist_o;
                mem_addr = pixel;    
            end
            data = 0;
        end else begin                  // if read mode... 
            mem_addr = bin;    // increment the address being read
            //data = hist_o;
            hist_i = 0;
        end
    end
    
    always @(negedge rw) begin  // reset mem_addr when going from write to read mode
        mem_addr = 0;
    end

    reg [9:0] prev_mem_addr = 0;
    reg new_addr;
    always @(posedge fast_clk) begin
        new_addr = (mem_addr!= prev_mem_addr);
        prev_mem_addr = mem_addr;
    end
    always @(negedge new_addr) begin
        data = hist_o;
    end
/*    always @(negedge rw) begin          // on the negative edge of the clock, reset addr to 0
            /// figure out how to reset the mem address
    end
*/
endmodule
