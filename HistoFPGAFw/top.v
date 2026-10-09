module topmod
  (
    //I2C Interface
    inout			SDA,
    input			SCL,

    output          FSIN,
    input			GPIO0,
    input			GPIO1,


    // Camera MIPI input
    inout 			CK_P,
    inout 			CK_N,
    inout 			D0_P,
    inout 			D0_N,
    inout 			D1_P,
    inout 			D1_N,

    // Diff Interface
    output          DIFF_P,
    output          DIFF_N
  );

  /*------------------Clocks and Resets--------------------*/
  wire reset_n_i; // pull gpio0 low when you want to do a reset
  wire clk_osc, clk_pixel, clk_pixel_hs, pll_lock, clk_mipi;
  wire clk_lf;

  defparam int_osc.HFCLKDIV = 4'd1;
  OSCI int_osc
       (
         .HFOUTEN	(1'b1),
         .HFCLKOUT	(clk_osc),
         .LFCLKOUT	(clk_lf)
       );

  pll_i pll_inst (
          .CLKI	( clk_mipi  ),  // 83 MHz, from the mipi clk
          .CLKOP	(clk_pixel),    // 84 MHz, buffered
          .CLKOS  (clk_pixel_hs), // 132.8MHz
          .LOCK	(pll_lock)
        );

  wire clk_fsin;
  clk_divider_40Hz __ (
                     .clk_48MHz 	(clk_lf),
                     .reset		(~reset_n_i),
                     .clk_40Hz	(clk_fsin)
                   );

  // (legacy clk_osc reset bridge removed — clk_osc never runs; see the
  //  control-plane section below. reset_n_i/GPIO0 is also unused: firmware
  //  drives the GPIO0 net low permanently, so gating on it holds the design
  //  in reset forever — hardware-verified 2026-07-05.)

  /*------------------Camera Communication--------------------*/
  //	MIPI DPHY to CMOS module : It converts the MIPI camera input to Parallel video data at clock "clk_pixel"
  wire [19:0] cmos_data;
  wire cmos_fv;
  wire cmos_lv;
  mipidphy2cmos mipidphy2cmos
                (
                  // Self-releasing: the module's internal reset bridges (on the
                  // MIPI byte clock) handle synchronized release. Previously fed
                  // by reset_n_HFCLKOUT, whose release requires clk_osc edges —
                  // and the OSCI HF oscillator provably never runs in these
                  // builds (hardware-verified 2026-07-05: free-running divider
                  // on clk_osc never advanced), which held the DPHY in reset.
                  .reset_n_i			(1'b1),
                  .rx_clk_p_i			(CK_P),
                  .rx_clk_n_i			(CK_N),
                  .rx_d0_p_i			(D0_P),
                  .rx_d0_n_i			(D0_N),
                  .rx_d1_p_i			(D1_P),
                  .rx_d1_n_i			(D1_N),
                  .pd0_o				( cmos_data ),
                  .fv_o				(  cmos_fv ),
                  .lv_o				(  cmos_lv ),
                  .rx_clk_byte_fr_o	(clk_mipi),
                  .clk_pixel_i		(clk_pixel_hs),
                  .pll_lock_i			(pll_lock)
                );

  /*------------------I2C control plane (clk_pixel_hs domain)-------------*/
  // Clocked from the MIPI-derived pixel clock, NOT clk_osc: the OSCI HF
  // oscillator does not run in these builds (hardware-verified — see note at
  // mipidphy2cmos), so anything clocked from it is dead. Consequence: the
  // register interface responds only while the camera streams (MIPI clock
  // active) — the capture flow already orders enable_camera before register
  // writes. Reset self-releases two pixel clocks after the MIPI clock starts.
  wire reset_n_pix;
  reset_bridge rst_brg_pix (
      .clk_i           (clk_pixel_hs),
      .ext_resetn_i    (1'b1),
      .sync_resetn_out (reset_n_pix));
  wire osc_reset = ~reset_n_pix;
  wire [7:0] r_addr, r_wdata, r_rdata;
  wire r_wstrobe, sda_oe;
  wire mode_image;
  wire [11:0] line_value, sent_line;
  wire line_req_toggle, line_ack_toggle, line_sent_toggle, img_active;

  i2c_slave #(.I2C_ADDR(7'h5A)) i2c_slave_i (
      .clk(clk_pixel_hs), .reset(osc_reset),
      .scl_i(SCL), .sda_i(SDA), .sda_oe(sda_oe),
      .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
      .rd_data(r_rdata));

  fpga_regs fpga_regs_i (
      .clk(clk_pixel_hs), .reset(osc_reset),
      .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
      .rd_data(r_rdata),
      .pll_lock_i(pll_lock), .fv_i(cmos_fv),
      .line_sent_toggle_i(line_sent_toggle), .sent_line_i(sent_line),
      .img_active_i(img_active),
      .line_ack_toggle_i(line_ack_toggle),
      .mode_image_o(mode_image), .line_value_o(line_value),
      .line_req_toggle_o(line_req_toggle));

  /*------------------Readout producers (clk_pixel_hs domain)-------------*/
  // mode bit into the pixel domain
  reg [1:0] mode_sync /* synthesis syn_preserve=1 */;
  always @(posedge clk_pixel_hs) mode_sync <= {mode_sync[0], mode_image};
  wire mode_pix = mode_sync[1];
  wire pix_reset = ~reset_n_pix;

  wire ser_done;
  wire [31:0] hm_word, lc_word;
  wire hm_active, lc_active;

  histogram_module histogram_module_i (
      .clk(clk_pixel_hs), .reset(pix_reset), .enable(~mode_pix),
      .pixel_data(cmos_data), .frame_valid(cmos_fv), .line_valid(cmos_lv),
      .serializer_done_i(ser_done),
      .word_o(hm_word), .serialize_active_o(hm_active),
      .debug(), .debug2());

  line_capture line_capture_i (
      .clk(clk_pixel_hs), .reset(pix_reset), .enable(mode_pix),
      .pixel_data(cmos_data), .frame_valid(cmos_fv), .line_valid(cmos_lv),
      .line_value_i(line_value), .line_req_toggle_i(line_req_toggle),
      .line_ack_toggle_o(line_ack_toggle),
      .line_sent_toggle_o(line_sent_toggle), .sent_line_o(sent_line),
      .img_active_o(img_active),
      .serializer_done(ser_done),
      .word_o(lc_word), .serialize_active_o(lc_active));

  /*------------------Shared Serializer + SPI-----------------------------*/
  wire spi_mosi, spi_clk;
  Serializer serializer_i (
      .fast_clk_in(clk_pixel_hs),
      .reset(pix_reset | ~(hm_active | lc_active)),
      .data_in(lc_active ? lc_word : hm_word),
      .serial_out(spi_mosi), .slow_clk_out(spi_clk),
      .done(ser_done), .debug());

  /*------------------Output Pin Assignments------------------------------*/
  assign SDA = sda_oe ? 1'b0 : 1'bz;   // open-drain data
  assign FSIN = 1'bz;
  assign DIFF_P = spi_clk;
  assign DIFF_N = spi_mosi;
  assign reset_n_i = GPIO0;
endmodule
