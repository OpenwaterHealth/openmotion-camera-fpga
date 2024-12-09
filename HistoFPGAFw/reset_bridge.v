`timescale 1 ps / 1 ps

module reset_bridge (
  input			clk_i,	// Destination clock
  input			ext_resetn_i,	// Asynchronous reset signal
  output reg	sync_resetn_out	// Synchronized reset signal
);


//-----------------------------------------------------------------------------
//	Wire and Register declarations
//-----------------------------------------------------------------------------

    reg     rst_meta=0;             // After sampling the rst_meta, this has a high probability of being metastable. The second sampling (sync_resetn_out) has a much lower probability of being metastable.
    wire    async_reset;

  assign async_reset = ext_resetn_i;

  always @(posedge clk_i or negedge async_reset)
  begin
    if (!async_reset)
    begin
      rst_meta        <= 1'b0;
      sync_resetn_out  <= 1'b0;
    end
    else
    begin
      rst_meta        <= 1'b1;
      sync_resetn_out  <= rst_meta;
    end
  end

endmodule