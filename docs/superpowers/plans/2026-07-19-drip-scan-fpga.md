# Drip-Scan Single-Frame FPGA RTL Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the FPGA half of drip-scan (spec §4.1/§4.3): sweep mode that captures every line ≥ a start line from one exposure into ping/pong line RAMs and streams each as a 2408-B packed-RAW10 push with a sensor-fw-compatible CRC-16, with overrun tripwire, register map v2, and the histogram envelope bit-identical to feature/5.

**Architecture:** Three new modules — `crc16` (byte-wise CRC-16/CCITT-FALSE), `raw10_pack` (20-bit pixel-pair → byte little-endian gearbox), `image_pusher` (2408-B push builder feeding the existing shared 32-bit Serializer) — plus a double-buffered `line_capture` v2 and `fpga_regs` v2 that publishes the sweep bit atomically with the start line over the existing req/ack toggle handshake. The histogram path, Serializer, SPI master, and legacy single-line envelope are untouched.

**Tech Stack:** Verilog-2005, Icarus Verilog + vvp for simulation (batch runners in `test_projects/`), Lattice Diamond for the bitstream (user-driven, final task is a checklist). Repo: `C:/Users/ethan/Projects/openmotion-camera-fpga`, branch `feature/8-drip-scan-single-frame` (already checked out).

---

### Task 0: Orientation, pinned facts, and issue tracking

**Files:**
- Read: `docs/superpowers/specs/2026-07-19-drip-scan-single-frame-design.md` (authoritative spec)
- Read: `HistoFPGAFw/line_capture.v`, `HistoFPGAFw/fpga_regs.v`, `HistoFPGAFw/histo_serializer.v`, `HistoFPGAFw/spi_master.v`, `HistoFPGAFw/top.v`
- Read: `test_projects/i2c_line/integration_tb.v`, `test_projects/i2c_line/run.bat`

All commands in this plan run from the repo root `C:\Users\ethan\Projects\openmotion-camera-fpga` in PowerShell. Simulations use the existing batch runner pattern: `.\test_projects\i2c_line\run.bat <tb_name>` compiles `test_projects/i2c_line/<tb_name>.v` with `C:\iverilog\bin\iverilog.exe -g2005 -o out\<tb_name>.vvp -I .` (cwd = `test_projects`) and runs it with `C:\iverilog\bin\vvp.exe`. Task 1 clones this runner into `test_projects/drip_scan/`. Never commit `test_projects/out/` artifacts.

**Facts you must internalize before writing any code (verified against the real sources):**

1. **CRC convention** (`C:/Users/ethan/Projects/openmotion-sensor-fw/Core/Src/utils.c` lines 59–68 + table at lines 16–49): `util_crc16` is **CRC-16/CCITT-FALSE** — polynomial **0x1021**, init **0xFFFF**, **no input/output reflection** (bytes folded MSB-first: `crc = (crc<<8) ^ crc16_tab[(crc>>8)^byte]`), **no final XOR**. The 256-entry table was regenerated from poly 0x1021 and matches entry-for-entry. On the wire the CRC is appended **high byte first** (`uart_comms.c` lines 151–153: `crc >> 8` then `crc & 0xFF`), so push byte [2406] = crc[15:8], [2407] = crc[7:0].
2. **Link bit order**: the SPI master transmits each byte **LSB-first** (`spi_master.v` lines 177–205, the modified MOSI block with `r_TX_Bit_Count` counting up from 0). The CRC operates on **byte values**, not wire bits, so the FPGA folds each assembled byte before serialization; bit order on the wire is irrelevant to the CRC definition. All TB SPI monitors assemble bytes LSB-first (`cur = {spi_mosi, cur[7:1]}`), matching the existing TBs.
3. **Pinned CRC test vectors** (computed by executing the actual `utils.c` table algorithm; the "123456789" value also matches the published CRC-16/CCITT-FALSE check value):
   - `crc("123456789")` = `0x29B1`
   - `crc(B6 01 05 00 01 00)` = `0x5D78`
   - `crc(00)` = `0xE1F0`
   - `crc(AA 55)` = `0xE5EA`
4. **Serializer behavior** (`histo_serializer.v`): consumes a 32-bit word per 4 bytes, transmitting `data_in[7:0]` first (little-endian lanes). `done` pulses once per completed word — **plus one "phantom" done immediately after its reset releases**, before any byte is sent (select==2'b11 while `o_TX_Ready` rises out of reset). The legacy envelope exploits this; `image_pusher` must explicitly skip it. Byte period ≈ 38 `clk_pixel_hs` cycles, so a producer has ~150 cycles per word — huge slack.
5. **Push layout (pinned, spec §4.1)**: 2408 B = `[0]`=0xB6 magic, `[1]`=0x01 format version, `[2]`=line[7:0], `[3]`={flags[3:0], line[11:8]} (flag bit0 = overrun-since-sweep-start), `[4]`=frame_cnt[7:0], `[5]`=0x00, `[6..2405]`=2400 B packed RAW10 (4 px → 5 B: pixel *k* of a group in readout order occupies bits [10k+9:10k] of a 40-bit little-endian group, low byte first), `[2406..2407]`=CRC-16 over bytes 0..2405, high byte first. 2408 B = exactly 602 Serializer words.
6. **RAW10 = little-endian gearbox**: the MIPI front-end delivers pixel **pairs** (`pixel_data[19:0]` = {pixB, pixA}). Treating the 2400-B payload as one little-endian bitstream where pair *n* occupies bits [20n+19:20n] produces exactly the pinned group layout (two consecutive pairs = one 40-bit group). So the packer is a 20-bit-in / 8-bit-out little-endian bit gearbox — no group logic needed.
7. **Register map v2** (spec §4.3, I2C 0x5A): VERSION 0x01→**0x02**; CTRL(0x03) gains bit1 = **SWEEP** (valid only with bit0 image mode, sampled at frame-valid boundary); LINE_L/H (0x04/0x05) reused as **sweep start line**; STATUS(0x09) gains bit2 = **overrun latch** (cleared on sweep arm). The sweep bit crosses to the pixel domain **atomically with the line value** on the existing req/ack toggle handshake in `fpga_regs.v` (one publish carries {sweep, line}), so an arm can never pair with a stale start line.
8. **Overrun policy (spec §4.3)**: in sweep mode every line ≥ start_line is captured ping/pong; a completed buffer hands off to `image_pusher` immediately. If a line completes while the pusher is still draining, the line is **dropped**, a sticky latch is set (STATUS bit2 + header flag bit0 on subsequent pushes), and capture continues. Latch clears on the next sweep arm edge. Open-loop with a tripwire.
9. **Firmware-facing constants (context only — not implemented in this repo)**: USB stream type 0x03 `OW_IMAGE_PACKET` (`openmotion-sdk/omotion/config.py:123`), new opcode `OW_CAMERA_IMAGE_MODE = 0x30`, sensor sweep retiming HTS=38400 / VTS=1312 / tc_r_initial=1308 / exposure=1 row / FSIN 0.8 Hz. Do not add anything for these here; they land in sensor-fw/SDK companion work.

**Steps:**

- [ ] **Step 1: Read the spec and the six RTL files listed above end-to-end.** Do not skip `histo_serializer.v`/`spi_master.v` — the phantom-done and LSB-first facts above come from them and every TB depends on both.
- [ ] **Step 2: Verify branch and clean tree.** Run `git status` and `git log --oneline -3`. Expect branch `feature/8-drip-scan-single-frame`, tip `eb372aa docs: drip-scan single-exposure full-frame readout design spec`, clean tree.
- [ ] **Step 3: Issue tracking.** Comment the planned approach on issue #8 and move it to In progress on Project #11:
  ```powershell
  gh issue comment 8 -R OpenwaterHealth/openmotion-camera-fpga --body "Starting FPGA RTL per the approved spec (docs/superpowers/specs/2026-07-19-drip-scan-single-frame-design.md). Plan: crc16 + raw10_pack + image_pusher modules, line_capture double-buffer sweep mode with overrun tripwire, fpga_regs v2 (VERSION 0x02, CTRL bit1 SWEEP, STATUS bit2 overrun), top.v wiring. TDD with Icarus TBs in test_projects/drip_scan/, incl. byte-exact 2408-B push checks with CRC-16 vectors computed from sensor-fw utils.c. Commits land on feature/8-drip-scan-single-frame."
  gh project item-list 11 --owner OpenwaterHealth --format json --limit 500 > $env:TEMP\board.json
  # find the item whose content.url ends in openmotion-camera-fpga/issues/8, note its "id", then:
  gh project item-edit --id <ITEM_ID> --project-id PVT_kwDOAif52c4BVgTu --field-id PVTSSF_lADOAif52c4BVgTuzhQ7qcU --single-select-option-id 47fc9ee4
  ```

---

### Task 1: `crc16` module (byte-wise CRC-16/CCITT-FALSE)

**Files:**
- Create: `test_projects/drip_scan/run.bat`
- Create: `test_projects/drip_scan/crc16_tb.v`
- Create: `HistoFPGAFw/crc16.v`
- Test: `test_projects/drip_scan/crc16_tb.v`

**Steps:**

- [ ] **Step 1: Create the drip_scan batch runner** — exact clone of `test_projects/i2c_line/run.bat` with the directory changed. Write `test_projects/drip_scan/run.bat`:
  ```bat
  @echo off
  rem Usage: run.bat <tb_name_without_extension>
  setlocal
  set IVERILOG=C:\iverilog\bin\iverilog.exe
  set VVP=C:\iverilog\bin\vvp.exe
  cd /d %~dp0..
  if not exist out mkdir out
  %IVERILOG% -g2005 -o out\%1.vvp -I . drip_scan\%1.v || exit /b 1
  %VVP% out\%1.vvp
  ```

- [ ] **Step 2: Write the failing testbench** `test_projects/drip_scan/crc16_tb.v`. What it proves: the RTL CRC is byte-identical to sensor-fw `util_crc16` — every check value below was computed by executing the actual `utils.c` table code, so a pass here is a proof of wire compatibility, including init value and bit order:
  ```verilog
  `timescale 1ns / 1ps
  // crc16_tb.v — proves crc16.v == sensor-fw util_crc16 (utils.c): poly
  // 0x1021, init 0xFFFF, MSB-first byte folding, no final XOR. All expected
  // values below were computed with the actual crc16_tab from utils.c.
  `include "../HistoFPGAFw/crc16.v"

  module crc16_tb;
    reg clk = 0; always #3.75 clk = ~clk;   // ~133 MHz, like clk_pixel_hs
    reg init = 0, byte_en = 0;
    reg [7:0] byte_in = 8'h00;
    wire [15:0] crc;

    crc16 dut (.clk(clk), .init(init), .byte_en(byte_en),
               .byte_in(byte_in), .crc(crc));

    integer errors = 0;
    task check(input cond, input [511:0] msg);
      if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
    endtask

    task crc_init;
      begin @(posedge clk); init <= 1; @(posedge clk); init <= 0; @(posedge clk); end
    endtask
    task crc_byte(input [7:0] b);
      begin byte_in <= b; byte_en <= 1; @(posedge clk); byte_en <= 0; @(posedge clk); end
    endtask

    reg [71:0] s;
    integer i;
    initial begin
      $dumpfile("out/crc16_tb.vcd"); $dumpvars(0, crc16_tb);
      #100;

      // T1: init value
      crc_init;
      check(crc == 16'hFFFF, "T1: init -> 0xFFFF");

      // T2: standard check string "123456789" -> 0x29B1 (CRC-16/CCITT-FALSE)
      s = "123456789";
      for (i = 8; i >= 0; i = i - 1) crc_byte(s[8*i +: 8]);
      check(crc == 16'h29B1, "T2: crc(123456789) == 0x29B1");

      // T3: drip-scan header example B6 01 05 00 01 00 -> 0x5D78
      crc_init;
      crc_byte(8'hB6); crc_byte(8'h01); crc_byte(8'h05);
      crc_byte(8'h00); crc_byte(8'h01); crc_byte(8'h00);
      check(crc == 16'h5D78, "T3: crc(header B6 01 05 00 01 00) == 0x5D78");

      // T4: single zero byte -> 0xE1F0 (catches init/table-index mistakes)
      crc_init;
      crc_byte(8'h00);
      check(crc == 16'hE1F0, "T4: crc(00) == 0xE1F0");

      // T5: AA 55 -> 0xE5EA (bit-order sentinel: reflected variants differ)
      crc_init;
      crc_byte(8'hAA); crc_byte(8'h55);
      check(crc == 16'hE5EA, "T5: crc(AA 55) == 0xE5EA");

      // T6: re-init discards history
      crc_init;
      check(crc == 16'hFFFF, "T6: re-init -> 0xFFFF");

      if (errors == 0) $display("ALL TESTS PASSED");
      else $display("%0d ERRORS", errors);
      $finish;
    end

    initial begin
      #1_000_000;
      $display("FAIL: watchdog timeout");
      $finish;
    end
  endmodule
  ```

- [ ] **Step 3: Run and verify it fails.** `.\test_projects\drip_scan\run.bat crc16_tb` — expect an iverilog compile error naming the missing include, e.g. `drip_scan/crc16_tb.v:5: Include file ../HistoFPGAFw/crc16.v not found`, and a nonzero exit from run.bat. This confirms the TB is actually exercising the file you are about to create.

- [ ] **Step 4: Write the module** `HistoFPGAFw/crc16.v`. One byte folded per clock via an 8-step unrolled MSB-first bit loop — mathematically identical to the utils.c table algorithm (the table entry for index *i* is exactly 8 of these bit steps applied to `i<<8`):
  ```verilog
  // crc16.v — byte-wise CRC-16/CCITT-FALSE: poly 0x1021, init 0xFFFF, bytes
  // folded MSB-first, no reflection, no final XOR. Byte-identical to
  // sensor-fw util_crc16 (Core/Src/utils.c: crc = (crc<<8) ^ tab[(crc>>8)^b]).
  // The SPI link transmits bytes LSB-first (spi_master.v) but the CRC is
  // defined over byte VALUES, so bytes are folded pre-serialization.
  // One byte per byte_en pulse; 8 unrolled XOR stages — trivial at 133 MHz.
  module crc16 (
      input  wire        clk,
      input  wire        init,        // 1-clk pulse: crc <= 16'hFFFF
      input  wire        byte_en,     // 1-clk pulse: fold byte_in into crc
      input  wire [7:0]  byte_in,
      output reg  [15:0] crc
  );

    function [15:0] crc_step8(input [15:0] c, input [7:0] b);
      integer k;
      reg [15:0] t;
      reg fb;
      begin
        t = c;
        for (k = 7; k >= 0; k = k - 1) begin
          fb = t[15] ^ b[k];                       // MSB of the byte first
          t = {t[14:0], 1'b0} ^ (fb ? 16'h1021 : 16'h0000);
        end
        crc_step8 = t;
      end
    endfunction

    always @(posedge clk) begin
      if (init) crc <= 16'hFFFF;
      else if (byte_en) crc <= crc_step8(crc, byte_in);
    end
  endmodule
  ```

- [ ] **Step 5: Run and verify pass.** `.\test_projects\drip_scan\run.bat crc16_tb` — expect the last line `ALL TESTS PASSED` (and no `FAIL:` lines).

- [ ] **Step 6: Commit.**
  ```powershell
  git add HistoFPGAFw/crc16.v test_projects/drip_scan/run.bat test_projects/drip_scan/crc16_tb.v
  git commit -m "feat: crc16 module - CRC-16/CCITT-FALSE matching sensor-fw util_crc16" -m "Byte-wise, poly 0x1021 / init 0xFFFF / MSB-first / no final XOR; TB vectors computed from the actual utils.c table. Refs #8"
  ```

---

### Task 2: `raw10_pack` gearbox (20-bit pair → RAW10 bytes)

**Files:**
- Create: `test_projects/drip_scan/raw10_pack_tb.v`
- Create: `HistoFPGAFw/raw10_pack.v`
- Test: `test_projects/drip_scan/raw10_pack_tb.v`

**Steps:**

- [ ] **Step 1: Write the failing testbench** `test_projects/drip_scan/raw10_pack_tb.v`. What it proves: the gearbox emits exactly the pinned RAW10 byte layout for a hand-computed 8-pixel vector (both the sequential path and the simultaneous push+pop path — a classic gearbox bug site), and `clear` really empties it. Hand vector: pixels px0..px7 = 3FF, 000, 155, 2AA, 0AB, 30C, 11E, 25D → pairs {pixB,pixA} = 0x003FF, 0xAA955, 0xC30AB, 0x9751E → wire bytes `FF 03 50 95 AA AB 30 EC 51 97` (verified against the spec's 40-bit-group formulation: identical):
  ```verilog
  `timescale 1ns / 1ps
  // raw10_pack_tb.v — pinned bit-layout test. px0..7 = 3FF,000,155,2AA,
  // 0AB,30C,11E,25D packs to FF 03 50 95 AA AB 30 EC 51 97 (hand-computed
  // per spec §4.1: pixel k of a 4-px group at group bits [10k+9:10k],
  // low byte first; equivalently pair n at payload bits [20n+19:20n]).
  `include "../HistoFPGAFw/raw10_pack.v"

  module raw10_pack_tb;
    reg clk = 0; always #3.75 clk = ~clk;
    reg clear = 0, pair_en = 0, byte_take = 0;
    reg [19:0] pair_in = 20'd0;
    wire [7:0] byte_out;
    wire byte_avail, pair_room;

    raw10_pack dut (
      .clk(clk), .clear(clear),
      .pair_en(pair_en), .pair_in(pair_in),
      .byte_take(byte_take), .byte_out(byte_out),
      .byte_avail(byte_avail), .pair_room(pair_room));

    integer errors = 0;
    task check(input cond, input [511:0] msg);
      if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
    endtask

    reg [19:0] pairs [0:3];
    reg [7:0]  exp [0:9];
    reg [7:0]  got [0:9];
    initial begin
      pairs[0] = 20'h003FF; pairs[1] = 20'hAA955;
      pairs[2] = 20'hC30AB; pairs[3] = 20'h9751E;
      exp[0]=8'hFF; exp[1]=8'h03; exp[2]=8'h50; exp[3]=8'h95; exp[4]=8'hAA;
      exp[5]=8'hAB; exp[6]=8'h30; exp[7]=8'hEC; exp[8]=8'h51; exp[9]=8'h97;
    end

    task do_clear;
      begin @(posedge clk); clear <= 1; @(posedge clk); clear <= 0; @(posedge clk); end
    endtask
    task do_push(input [19:0] p);
      begin
        while (!pair_room) @(posedge clk);
        pair_in <= p; pair_en <= 1;
        @(posedge clk);
        pair_en <= 0; @(posedge clk);
      end
    endtask
    task do_pop(output [7:0] b);
      begin
        while (!byte_avail) @(posedge clk);
        b = byte_out;                 // value presented BEFORE the take edge
        byte_take <= 1;
        @(posedge clk);
        byte_take <= 0; @(posedge clk);
      end
    endtask
    task do_push_pop(input [19:0] p, output [7:0] b);
      begin
        b = byte_out;
        pair_in <= p; pair_en <= 1; byte_take <= 1;
        @(posedge clk);
        pair_en <= 0; byte_take <= 0; @(posedge clk);
      end
    endtask

    integer pi, bi, both;
    initial begin
      $dumpfile("out/raw10_pack_tb.vcd"); $dumpvars(0, raw10_pack_tb);
      #100;
      do_clear;

      // A: sequential stream — push whenever dry, pop 10 bytes
      pi = 0;
      for (bi = 0; bi < 10; bi = bi + 1) begin
        while (!byte_avail) begin do_push(pairs[pi]); pi = pi + 1; end
        do_pop(got[bi]);
      end
      for (bi = 0; bi < 10; bi = bi + 1)
        check(got[bi] == exp[bi], "A: packed byte value");
      check(!byte_avail, "A: drained empty");
      check(pi == 4, "A: consumed exactly 4 pairs");

      // B: same stream with simultaneous push+pop cycles interleaved —
      // proves the combined-update arm of the accumulator is correct
      do_clear;
      do_push(pairs[0]);
      pi = 1; bi = 0; both = 0;
      while (bi < 10) begin
        if (pi < 4 && pair_room && byte_avail) begin
          do_push_pop(pairs[pi], got[bi]); pi = pi + 1; bi = bi + 1; both = both + 1;
        end else if (byte_avail) begin
          do_pop(got[bi]); bi = bi + 1;
        end else begin
          do_push(pairs[pi]); pi = pi + 1;
        end
      end
      for (bi = 0; bi < 10; bi = bi + 1)
        check(got[bi] == exp[bi], "B: packed byte value (simultaneous path)");
      check(both >= 1, "B: at least one simultaneous push+pop exercised");
      check(!byte_avail, "B: drained empty");

      // C: clear discards buffered bits
      do_clear;
      do_push(20'hFFFFF);
      do_clear;
      check(!byte_avail, "C: cleared empty");
      pi = 0;
      for (bi = 0; bi < 10; bi = bi + 1) begin
        while (!byte_avail) begin do_push(pairs[pi]); pi = pi + 1; end
        do_pop(got[bi]);
      end
      for (bi = 0; bi < 10; bi = bi + 1)
        check(got[bi] == exp[bi], "C: clean stream after clear");

      if (errors == 0) $display("ALL TESTS PASSED");
      else $display("%0d ERRORS", errors);
      $finish;
    end

    initial begin
      #2_000_000;
      $display("FAIL: watchdog timeout");
      $finish;
    end
  endmodule
  ```

- [ ] **Step 2: Run and verify it fails.** `.\test_projects\drip_scan\run.bat raw10_pack_tb` — expect `Include file ../HistoFPGAFw/raw10_pack.v not found`.

- [ ] **Step 3: Write the module** `HistoFPGAFw/raw10_pack.v`:
  ```verilog
  // raw10_pack.v — little-endian bit gearbox: 20-bit pixel-pair pushes in,
  // RAW10 payload bytes out. Pair n of a line occupies payload bits
  // [20n+19:20n]; bytes pop low-bits-first. This IS the spec §4.1 layout
  // (4 px -> 5 B, pixel k of a group at bits [10k+9:10k], low byte first):
  // two consecutive pairs form one 40-bit group and the byte boundaries
  // fall out of the same little-endian bitstream. 960 pairs -> 2400 bytes.
  //
  // Contract (caller-enforced, keeps the datapath minimal):
  //   - pair_en only when pair_room (cnt <= 12; worst case 12+20 = 32 bits)
  //   - byte_take only when byte_avail (cnt >= 8)
  //   - simultaneous pair_en+byte_take is legal and handled
  module raw10_pack (
      input  wire        clk,
      input  wire        clear,       // 1-clk pulse: empty the accumulator
      input  wire        pair_en,
      input  wire [19:0] pair_in,
      input  wire        byte_take,
      output wire [7:0]  byte_out,
      output wire        byte_avail,
      output wire        pair_room
  );

    reg [31:0] acc;
    reg [5:0]  cnt;

    assign byte_out   = acc[7:0];
    assign byte_avail = (cnt >= 6'd8);
    assign pair_room  = (cnt <= 6'd12);

    always @(posedge clk) begin
      if (clear) begin
        acc <= 32'd0; cnt <= 6'd0;
      end else begin
        case ({pair_en, byte_take})
          2'b10: begin
            acc <= acc | ({12'd0, pair_in} << cnt);
            cnt <= cnt + 6'd20;
          end
          2'b01: begin
            acc <= acc >> 8;
            cnt <= cnt - 6'd8;
          end
          2'b11: begin
            acc <= (acc >> 8) | ({12'd0, pair_in} << (cnt - 6'd8));
            cnt <= cnt + 6'd12;
          end
          default: ;
        endcase
      end
    end
  endmodule
  ```

- [ ] **Step 4: Run and verify pass.** `.\test_projects\drip_scan\run.bat raw10_pack_tb` — expect `ALL TESTS PASSED`.

- [ ] **Step 5: Commit.**
  ```powershell
  git add HistoFPGAFw/raw10_pack.v test_projects/drip_scan/raw10_pack_tb.v
  git commit -m "feat: raw10_pack - 20-bit pair to RAW10 byte gearbox" -m "Little-endian 20->8 gearbox; pinned 8-pixel bit-layout vector incl. simultaneous push+pop. Refs #8"
  ```

---

### Task 3: `image_pusher` (2408-B push builder for the shared Serializer)

**Files:**
- Create: `test_projects/drip_scan/image_pusher_tb.v`
- Create: `HistoFPGAFw/image_pusher.v`
- Test: `test_projects/drip_scan/image_pusher_tb.v`

**Steps:**

- [ ] **Step 1: Write the failing testbench** `test_projects/drip_scan/image_pusher_tb.v`. What it proves: a full 2408-B push is byte-exact end-to-end through the real Serializer + SPI master — header fields, RAW10 payload from a sync-read RAM, and the CRC — against both a TB reference model and **pinned constants computed offline from the utils.c table** (anchoring the reference model itself). Push 2 proves the overrun header flag and that a second push (fresh CRC init, fresh byte counters) is clean:
  ```verilog
  `timescale 1ns / 1ps
  // image_pusher_tb.v — byte-exact 2408-B push through the REAL Serializer
  // + SPI master. Pinned anchors (computed with the sensor-fw utils.c CRC
  // table): for RAM pairs C<16 patterned pixA=(2C+5)&3FF pixB=(2C+6)&3FF,
  // rest zero, header line=5 frame=1 flags=0:
  //   payload[0..9]  = 05 18 70 00 02 09 28 B0 00 03
  //   payload[35..40]= 21 88 30 02 09 00
  //   CRC over bytes 0..2405 = 0x3C22 -> wire bytes 3C 22
  `include "../HistoFPGAFw/crc16.v"
  `include "../HistoFPGAFw/raw10_pack.v"
  `include "../HistoFPGAFw/image_pusher.v"
  `include "../HistoFPGAFw/histo_serializer.v"
  `include "../HistoFPGAFw/spi_master.v"
  `include "i2c_line/ram_dp_s_beh.v"

  module image_pusher_tb;
    reg clk = 0; always #3.75 clk = ~clk;
    reg reset = 1;

    reg start = 0;
    reg [11:0] line = 12'd0;
    reg [7:0]  frame = 8'd0;
    reg ovr = 0;
    wire busy;
    wire [9:0] ram_addr;
    wire [23:0] ram_q;
    wire ser_done, ser_active;
    wire [31:0] word;

    image_pusher dut (
      .clk(clk), .reset(reset),
      .start_i(start), .line_i(line), .frame_i(frame), .ovr_flag_i(ovr),
      .busy_o(busy),
      .ram_addr_o(ram_addr), .ram_q_i(ram_q),
      .serializer_done(ser_done),
      .word_o(word), .serialize_active_o(ser_active));

    // sync-read line RAM (behavioral DP8KE stand-in); write port unused,
    // contents preloaded hierarchically below
    ram_dp_s line_ram (
      .Reset(reset),
      .RdClock(clk), .RdClockEn(1'b1), .RdAddress(ram_addr), .Q(ram_q),
      .WrClock(clk), .WrClockEn(1'b0), .WrAddress(10'd0),
      .Data(24'd0), .WE(1'b0));

    wire spi_clk, spi_mosi;
    Serializer ser (
      .fast_clk_in(clk), .reset(reset | ~ser_active), .data_in(word),
      .serial_out(spi_mosi), .slow_clk_out(spi_clk), .done(ser_done), .debug());

    // SPI monitor: LSB-first bytes into a flat stream
    reg [7:0] cur; integer nbits = 0;
    integer bytes_lifetime = 0;
    reg [7:0] wire_bytes [0:8191];
    always @(posedge spi_clk) begin
      cur = {spi_mosi, cur[7:1]};
      nbits = nbits + 1;
      if (nbits == 8) begin
        wire_bytes[bytes_lifetime] = cur;
        bytes_lifetime = bytes_lifetime + 1;
        nbits = 0;
      end
    end

    integer errors = 0;
    task check(input cond, input [1023:0] msg);
      if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
    endtask
    integer t0;
    task wait_total_bytes(input integer target, input integer max_ns);
      begin
        t0 = $time;
        while (bytes_lifetime < target && ($time - t0) < max_ns) #10000;
        #50000;
      end
    endtask

    // ---- reference model ----
    function [19:0] tb_pair(input [11:0] fline, input integer idx);
      tb_pair = (idx < 16)
        ? ((((2*idx + 1 + fline) & 10'h3FF) << 10) | ((2*idx + fline) & 10'h3FF))
        : 20'd0;
    endfunction
    function [15:0] crc16_ref(input [15:0] c, input [7:0] b);
      integer k; reg [15:0] t; reg fb;
      begin
        t = c;
        for (k = 7; k >= 0; k = k - 1) begin
          fb = t[15] ^ b[k];
          t = {t[14:0], 1'b0} ^ (fb ? 16'h1021 : 16'h0000);
        end
        crc16_ref = t;
      end
    endfunction
    reg [7:0] exp_push [0:2407];
    reg [39:0] gval;
    reg [15:0] ecrc;
    integer ep, eb;
    task build_expected_push(input [11:0] hline, input [11:0] pline,
                             input [7:0] eframe, input [3:0] eflags);
      begin
        exp_push[0] = 8'hB6; exp_push[1] = 8'h01;
        exp_push[2] = hline[7:0];
        exp_push[3] = {eflags, hline[11:8]};
        exp_push[4] = eframe; exp_push[5] = 8'h00;
        for (ep = 0; ep < 480; ep = ep + 1) begin
          gval = {tb_pair(pline, 2*ep + 1), tb_pair(pline, 2*ep)};
          for (eb = 0; eb < 5; eb = eb + 1)
            exp_push[6 + 5*ep + eb] = gval >> (8*eb);
        end
        ecrc = 16'hFFFF;
        for (eb = 0; eb < 2406; eb = eb + 1)
          ecrc = crc16_ref(ecrc, exp_push[eb]);
        exp_push[2406] = ecrc[15:8];        // high byte first (uart_comms.c)
        exp_push[2407] = ecrc[7:0];
      end
    endtask
    integer ci, mism;
    task check_push(input integer base, input [11:0] hline, input [11:0] pline,
                    input [7:0] eframe, input [3:0] eflags,
                    input [1023:0] label);
      begin
        build_expected_push(hline, pline, eframe, eflags);
        mism = 0;
        for (ci = 0; ci < 2408; ci = ci + 1)
          if (wire_bytes[base+ci] !== exp_push[ci]) begin
            if (mism == 0)
              $display("  first mismatch at byte %0d: got %02x want %02x",
                       ci, wire_bytes[base+ci], exp_push[ci]);
            mism = mism + 1;
          end
        check(mism == 0, label);
      end
    endtask

    task do_start(input [11:0] l, input [7:0] f, input o);
      begin
        @(posedge clk);
        line <= l; frame <= f; ovr <= o; start <= 1;
        @(posedge clk);
        start <= 0;
      end
    endtask

    integer i, base;
    initial begin
      $dumpfile("out/image_pusher_tb.vcd"); $dumpvars(0, image_pusher_tb);
      for (i = 0; i < 1024; i = i + 1)
        line_ram.mem[i] = {4'b0, tb_pair(12'd5, i)};
      #100 reset = 0; #100;

      // ---- push 1: line=5 frame=1 flags=0 (pinned anchor vector) ----
      base = bytes_lifetime;
      do_start(12'd5, 8'd1, 1'b0);
      @(posedge clk);
      check(busy, "push1: busy during push");
      wait_total_bytes(base + 2408, 2_000_000);
      check(bytes_lifetime == base + 2408, "push1: exactly 2408 bytes");
      check(!busy, "push1: busy deasserts after drain");
      check(wire_bytes[base+0] == 8'hB6, "push1: [0] magic 0xB6");
      check(wire_bytes[base+1] == 8'h01, "push1: [1] format version 0x01");
      check(wire_bytes[base+2] == 8'h05, "push1: [2] line[7:0] == 5");
      check(wire_bytes[base+3] == 8'h00, "push1: [3] flags/line_h == 0x00");
      check(wire_bytes[base+4] == 8'h01, "push1: [4] frame_cnt == 1");
      check(wire_bytes[base+5] == 8'h00, "push1: [5] reserved 0x00");
      check(wire_bytes[base+6]  == 8'h05 && wire_bytes[base+7]  == 8'h18 &&
            wire_bytes[base+8]  == 8'h70 && wire_bytes[base+9]  == 8'h00 &&
            wire_bytes[base+10] == 8'h02 && wire_bytes[base+11] == 8'h09 &&
            wire_bytes[base+12] == 8'h28 && wire_bytes[base+13] == 8'hB0 &&
            wire_bytes[base+14] == 8'h00 && wire_bytes[base+15] == 8'h03,
            "push1: pinned payload[0..9] == 05 18 70 00 02 09 28 B0 00 03");
      check(wire_bytes[base+41] == 8'h21 && wire_bytes[base+42] == 8'h88 &&
            wire_bytes[base+43] == 8'h30 && wire_bytes[base+44] == 8'h02 &&
            wire_bytes[base+45] == 8'h09 && wire_bytes[base+46] == 8'h00,
            "push1: pinned payload[35..40] == 21 88 30 02 09 00");
      check(wire_bytes[base+2406] == 8'h3C && wire_bytes[base+2407] == 8'h22,
            "push1: pinned CRC bytes 3C 22 (utils.c table, high byte first)");
      check_push(base, 12'd5, 12'd5, 8'd1, 4'h0, "push1: byte-exact vs model");

      // ---- push 2: same RAM, line=6 frame=2 overrun flag set ----
      base = bytes_lifetime;
      do_start(12'd6, 8'd2, 1'b1);
      wait_total_bytes(base + 2408, 2_000_000);
      check(bytes_lifetime == base + 2408, "push2: exactly 2408 bytes");
      check(wire_bytes[base+3] == 8'h10, "push2: [3] flags bit0 set");
      check_push(base, 12'd6, 12'd5, 8'd2, 4'h1, "push2: byte-exact (flag + fresh CRC)");

      if (errors == 0) $display("ALL TESTS PASSED");
      else $display("%0d ERRORS", errors);
      $finish;
    end

    initial begin
      #20_000_000;
      $display("FAIL: watchdog timeout");
      $finish;
    end
  endmodule
  ```

- [ ] **Step 2: Run and verify it fails.** `.\test_projects\drip_scan\run.bat image_pusher_tb` — expect `Include file ../HistoFPGAFw/image_pusher.v not found`.

- [ ] **Step 3: Write the module** `HistoFPGAFw/image_pusher.v`. Design notes baked into the code: 2408 B = exactly 602 Serializer words; bytes are assembled sequentially (header → gearbox payload → CRC) into little-endian word lanes, so CRC bytes at [2406..2407] read a register that already folded byte 2405; the Serializer's **phantom done** after reset release is explicitly skipped; an independent fetch engine keeps the gearbox fed from the sync-read RAM (~150 clk/word of slack vs ≤ ~30 clk to build one):
  ```verilog
  // image_pusher.v — builds one 2408-B drip-scan line push (6-B header +
  // 2400-B packed RAW10 + CRC-16, spec §4.1) as 602 x 32-bit words for the
  // shared Serializer. Bytes assemble in wire order: CRC (crc16.v, matches
  // sensor-fw util_crc16) folds bytes 0..2405 as they are placed, then bytes
  // 2406/2407 emit crc high-then-low (uart_comms.c convention). Payload
  // bytes come from raw10_pack fed by a fetch engine reading 960 pixel
  // pairs from the handed-off line RAM (sync read, 1-clk latency).
  //
  // Serializer contract: word_o must be stable per 4-byte word and advance
  // on `done` rises — EXCEPT the first done after serialize_active_o rises,
  // which is the phantom pulse (select==11 while o_TX_Ready rises out of
  // reset, before any byte transmits — see histo_serializer.v). It is
  // filtered with phantom_seen. Timing slack: ~150 clk per wire word vs
  // <~30 clk to build one, so the builder always waits on the wire.
  //
  // Handoff contract with line_capture: start_i is a 1-clk pulse with
  // line_i/frame_i/ovr_flag_i registered on the same edge; start_i is never
  // pulsed while busy_o is high (line_capture drops the line instead).
  module image_pusher #(
      parameter [7:0] MAGIC       = 8'hB6,
      parameter [7:0] FMT_VERSION = 8'h01
  ) (
      input  wire        clk,
      input  wire        reset,
      // handoff from line_capture
      input  wire        start_i,
      input  wire [11:0] line_i,
      input  wire [7:0]  frame_i,
      input  wire        ovr_flag_i,      // header flags bit0
      output wire        busy_o,
      // line RAM read port (pair index; sync read)
      output wire [9:0]  ram_addr_o,
      input  wire [23:0] ram_q_i,
      // shared Serializer
      input  wire        serializer_done,
      output reg  [31:0] word_o,
      output reg         serialize_active_o
  );

    localparam integer N_PAIRS = 960;     // 1920 px / line
    localparam integer N_WORDS = 602;     // 2408 B / 4

    reg [11:0] line_r;
    reg [7:0]  frame_r;
    reg        ovr_r;
    reg        busy;
    assign busy_o = busy | start_i;

    // ---- serializer done edges + phantom filter ----
    reg done_q, phantom_seen;
    wire done_rise = serializer_done & ~done_q;
    wire word_done = done_rise & phantom_seen;

    // ---- pair fetch engine: keep the gearbox fed ----
    reg  [9:0] fetch_idx;
    reg        fetch_pend;                // ram_q_i holds pair[fetch_idx] now
    wire       pair_room;
    assign ram_addr_o = fetch_idx;
    always @(posedge clk) begin
      if (reset | start_i) begin
        fetch_idx <= 10'd0; fetch_pend <= 1'b0;
      end else if (fetch_pend) begin
        fetch_idx <= fetch_idx + 10'd1;   // gearbox consumed it this edge
        fetch_pend <= 1'b0;
      end else if (busy && fetch_idx < N_PAIRS && pair_room) begin
        fetch_pend <= 1'b1;               // addr presented now; Q valid next clk
      end
    end

    wire [7:0] gb_byte;
    wire       gb_avail;
    wire       pay_take;
    raw10_pack gearbox (
      .clk(clk), .clear(start_i),
      .pair_en(fetch_pend), .pair_in(ram_q_i[19:0]),
      .byte_take(pay_take), .byte_out(gb_byte),
      .byte_avail(gb_avail), .pair_room(pair_room));

    // ---- byte source mux (combinational) ----
    localparam [1:0] S_IDLE = 2'd0, S_BUILD = 2'd1, S_HAND = 2'd2, S_TAIL = 2'd3;
    reg [1:0]  state;
    reg [11:0] byte_idx;                  // 0..2407 in wire order
    reg [31:0] build;
    reg [9:0]  words_loaded;

    wire [15:0] crc;
    reg [7:0] cur_byte;
    reg       cur_rdy;
    always @(*) begin
      cur_rdy = 1'b1;
      case (byte_idx)
        12'd0: cur_byte = MAGIC;
        12'd1: cur_byte = FMT_VERSION;
        12'd2: cur_byte = line_r[7:0];
        12'd3: cur_byte = {3'b000, ovr_r, line_r[11:8]};
        12'd4: cur_byte = frame_r;
        12'd5: cur_byte = 8'h00;
        12'd2406: cur_byte = crc[15:8];   // high byte first (uart_comms.c)
        12'd2407: cur_byte = crc[7:0];
        default: begin cur_byte = gb_byte; cur_rdy = gb_avail; end
      endcase
    end
    wire is_payload = (byte_idx >= 12'd6) && (byte_idx <= 12'd2405);
    wire take_byte  = (state == S_BUILD) && cur_rdy;
    assign pay_take = take_byte && is_payload;

    crc16 crc_i (
      .clk(clk), .init(start_i),
      .byte_en(take_byte && (byte_idx < 12'd2406)),
      .byte_in(cur_byte), .crc(crc));

    // ---- builder / word-hand FSM ----
    always @(posedge clk) begin
      if (reset) begin
        state <= S_IDLE; busy <= 1'b0; serialize_active_o <= 1'b0;
        byte_idx <= 12'd0; words_loaded <= 10'd0;
        done_q <= 1'b0; phantom_seen <= 1'b0;
        line_r <= 12'd0; frame_r <= 8'd0; ovr_r <= 1'b0;
        build <= 32'd0; word_o <= 32'd0;
      end else begin
        done_q <= serializer_done;
        if (done_rise & serialize_active_o & ~phantom_seen)
          phantom_seen <= 1'b1;
        case (state)
          S_IDLE: if (start_i) begin
            busy <= 1'b1; byte_idx <= 12'd0; words_loaded <= 10'd0;
            phantom_seen <= 1'b0;
            line_r <= line_i; frame_r <= frame_i; ovr_r <= ovr_flag_i;
            state <= S_BUILD;
          end
          S_BUILD: if (cur_rdy) begin
            case (byte_idx[1:0])          // Serializer sends data_in[7:0] first
              2'b00: build[7:0]   <= cur_byte;
              2'b01: build[15:8]  <= cur_byte;
              2'b10: build[23:16] <= cur_byte;
              2'b11: build[31:24] <= cur_byte;
            endcase
            byte_idx <= byte_idx + 12'd1;
            if (byte_idx[1:0] == 2'b11) state <= S_HAND;
          end
          S_HAND: begin
            if (words_loaded == 10'd0) begin
              word_o <= build;
              words_loaded <= 10'd1;
              serialize_active_o <= 1'b1; // serializer reset releases now
              state <= S_BUILD;
            end else if (word_done) begin
              word_o <= build;
              words_loaded <= words_loaded + 10'd1;
              state <= (words_loaded == N_WORDS - 1) ? S_TAIL : S_BUILD;
            end
          end
          S_TAIL: if (word_done) begin    // last word finished on the wire
            serialize_active_o <= 1'b0;
            busy <= 1'b0;
            state <= S_IDLE;
          end
        endcase
      end
    end
  endmodule
  ```

- [ ] **Step 4: Run and verify pass.** `.\test_projects\drip_scan\run.bat image_pusher_tb` — expect `ALL TESTS PASSED`. If the pinned CRC check fails but the model comparison passes, the TB reference model and RTL share a bug — debug against the pinned constants, they are ground truth from the C table.

- [ ] **Step 5: Commit.**
  ```powershell
  git add HistoFPGAFw/image_pusher.v test_projects/drip_scan/image_pusher_tb.v
  git commit -m "feat: image_pusher - 2408-B header+RAW10+CRC16 line push" -m "602-word push through the shared Serializer; phantom-done filtered; byte-exact TB with pinned utils.c CRC anchors. Refs #8"
  ```

---

### Task 4: `fpga_regs` v2 (VERSION 0x02, SWEEP bit, overrun status, atomic publish)

**Files:**
- Modify: `test_projects/i2c_line/fpga_regs_tb.v` (instantiation lines 29–38, responder lines 41–44, VERSION check line 88, new tests after the T-lone-H block ending line 148)
- Modify: `HistoFPGAFw/fpga_regs.v` (full rewrite shown)
- Modify: `test_projects/i2c_line/integration_tb.v` (fpga_regs instantiation lines 54–63, VERSION check line 341)
- Test: `test_projects/i2c_line/fpga_regs_tb.v`, `test_projects/i2c_line/integration_tb.v`

**Steps:**

- [ ] **Step 1: Update `fpga_regs_tb.v` first (failing test).** Four edits:

  (a) Declarations — after line 26 (`wire line_req_toggle;`) add:
  ```verilog
    wire sweep_value;
    reg  overrun_i = 0;
    reg  pix_sweep = 0;
  ```
  (b) Instantiation (lines 29–38) — add the two new ports:
  ```verilog
    fpga_regs regs (
      .clk(clk), .reset(reset),
      .reg_addr(reg_addr), .wr_data(wr_data), .wr_strobe(wr_strobe),
      .rd_data(rd_data),
      .pll_lock_i(pll_lock), .fv_i(fv),
      .line_sent_toggle_i(line_sent_toggle), .sent_line_i(sent_line),
      .img_active_i(img_active),
      .overrun_i(overrun_i),
      .line_ack_toggle_i(line_ack_toggle),
      .mode_image_o(mode_image), .line_value_o(line_value),
      .sweep_value_o(sweep_value),
      .line_req_toggle_o(line_req_toggle));
  ```
  (c) Responder (lines 42–44) — capture the sweep bit with the line:
  ```verilog
    always @(line_req_toggle) if (responder_on) begin
      #100; pix_target = line_value; pix_sweep = sweep_value;
      line_ack_toggle = line_req_toggle;
    end
  ```
  (d) VERSION check (line 88): change to
  ```verilog
    rd_reg(8'h01, rb); check(rb == 8'h02, "VERSION == 0x02");
  ```
  (e) New tests — insert after the T-lone-H block (after line 148, before the FRAME_CNT test). What they prove: CTRL bit1 exists and reads back; the sweep bit is delivered to the pixel side **atomically with the line** on the same handshake; a sweep-only change republishes without disturbing the line; STATUS bit2 is a live mirror of the pixel-domain latch:
  ```verilog
      // T-sweep: CTRL bit1 write/readback; {sweep, line} publish atomically
      wr_reg(8'h04, 8'h40); wr_reg(8'h05, 8'h00);   // LINE = 0x040
      wr_reg(8'h03, 8'h03);                          // image + sweep
      rd_reg(8'h03, rb); check(rb == 8'h03, "T-sweep: CTRL image+sweep readback");
      #5000;
      check(pix_target == 12'h040, "T-sweep: CDC delivered line 0x040");
      check(pix_sweep == 1'b1, "T-sweep: sweep=1 delivered with the line");
      wr_reg(8'h03, 8'h01);                          // sweep off, image stays
      #5000;
      check(pix_sweep == 1'b0, "T-sweep: sweep=0 republished");
      check(pix_target == 12'h040, "T-sweep: line unchanged by sweep republish");

      // T-overrun: STATUS bit2 mirrors the pixel-domain latch level
      overrun_i = 1; #500;
      rd_reg(8'h09, rb); check(rb[2] == 1'b1, "T-overrun: STATUS bit2 set");
      overrun_i = 0; #500;
      rd_reg(8'h09, rb); check(rb[2] == 1'b0, "T-overrun: STATUS bit2 clear");
  ```

- [ ] **Step 2: Run and verify it fails.** `.\test_projects\i2c_line\run.bat fpga_regs_tb` — expect a compile error like ``error: port `overrun_i' is not a port of regs`` (v1 has neither new port).

- [ ] **Step 3: Rewrite `HistoFPGAFw/fpga_regs.v`** (complete file — v1 plus: VERSION 0x02 default, `mode_sweep` in CTRL, 13-bit atomic publish, `overrun_i` sync into STATUS bit2; everything else, incl. auto-increment and staging semantics, is untouched):
  ```verilog
  // fpga_regs.v — register file for the I2C control plane. clk_osc domain.
  // Owns the auto-incrementing image line counter and publishes it to the
  // pixel domain via a toggle req/ack handshake (bus stable while req
  // pending). v2 (drip-scan): VERSION 0x02; CTRL bit1 = SWEEP, published
  // ATOMICALLY with the line counter on the same handshake (one publish
  // carries {sweep, line}, so an arm can never pair with a stale start
  // line); STATUS bit2 mirrors the pixel-domain overrun latch (2FF level).
  // In sweep mode the pixel side never toggles line_sent, so the counter
  // holds the host-written sweep start line (LINE_L/H reuse, spec §4.3).
  module fpga_regs #(
      parameter [7:0] ID_VAL  = 8'h5A,
      parameter [7:0] VERSION = 8'h02
  ) (
      input  wire       clk,
      input  wire       reset,
      // i2c_slave
      input  wire [7:0] reg_addr,
      input  wire [7:0] wr_data,
      input  wire       wr_strobe,
      output reg  [7:0] rd_data,
      // async status inputs (synchronized here)
      input  wire       pll_lock_i,
      input  wire       fv_i,
      input  wire        line_sent_toggle_i,
      input  wire [11:0] sent_line_i,
      input  wire        img_active_i,
      input  wire        overrun_i,
      input  wire       line_ack_toggle_i,
      // control outputs
      output reg        mode_image_o,
      output reg [11:0] line_value_o,
      output reg        sweep_value_o,   // published with line_value_o
      output reg        line_req_toggle_o
  );

    reg [1:0] s_pll, s_fv, s_sent, s_ack, s_act, s_ovr /* synthesis syn_preserve=1 */;
    // sent_line_i is quasi-static (stable well before and after its companion
    // toggle flips), so a plain 2FF sync of the multi-bit value is valid.
    reg [11:0] s_sent_line_a, s_sent_line_b /* synthesis syn_preserve=1 */;
    reg fv_q, sent_q;
    always @(posedge clk) begin
      s_pll  <= {s_pll[0],  pll_lock_i};
      s_fv   <= {s_fv[0],   fv_i};
      s_sent <= {s_sent[0], line_sent_toggle_i};
      s_ack  <= {s_ack[0],  line_ack_toggle_i};
      s_act  <= {s_act[0],  img_active_i};
      s_ovr  <= {s_ovr[0],  overrun_i};
      s_sent_line_a <= sent_line_i;
      s_sent_line_b <= s_sent_line_a;
      fv_q   <= s_fv[1];
      sent_q <= s_sent[1];
    end
    wire fv_rise    = s_fv[1] & ~fv_q;
    wire sent_event = s_sent[1] ^ sent_q;

    reg [7:0]  scratch;
    reg [7:0]  line_stage_l;
    reg [11:0] line_counter;
    reg [7:0]  frame_cnt;
    reg        mode_sweep;

    always @(posedge clk) begin
      if (reset) begin
        scratch <= 8'hA5; mode_image_o <= 1'b0; mode_sweep <= 1'b0;
        line_stage_l <= 8'h00; line_counter <= 12'd0; frame_cnt <= 8'd0;
      end else begin
        if (fv_rise) frame_cnt <= frame_cnt + 8'd1;
        // increment only if the completed send was for OUR current target;
        // a stale toggle from before an MCU rewind is self-discarding
        if (sent_event && s_sent_line_b == line_counter)
          line_counter <= line_counter + 12'd1;
        if (wr_strobe) begin
          case (reg_addr)
            8'h02: scratch <= wr_data;
            8'h03: begin mode_image_o <= wr_data[0]; mode_sweep <= wr_data[1]; end
            8'h04: line_stage_l <= wr_data;
            8'h05: line_counter <= {wr_data[3:0], line_stage_l}; // commit; wins over sent_event
            default: ;
          endcase
        end
      end
    end

    // publish {sweep, line_counter} to the pixel domain (req/ack toggle
    // handshake; the pair is atomic — bus stable while req pending)
    reg [12:0] published;
    wire hs_idle = (line_req_toggle_o == s_ack[1]);
    always @(posedge clk) begin
      if (reset) begin
        line_req_toggle_o <= 1'b0; line_value_o <= 12'd0; sweep_value_o <= 1'b0;
        published <= 13'h1FFF;                 // != reset state forces initial publish
      end else if (hs_idle && published != {mode_sweep, line_counter}) begin
        line_value_o  <= line_counter;
        sweep_value_o <= mode_sweep;
        published     <= {mode_sweep, line_counter};
        line_req_toggle_o <= ~line_req_toggle_o;
      end
    end

    always @(*) begin
      case (reg_addr)
        8'h00: rd_data = ID_VAL;
        8'h01: rd_data = VERSION;
        8'h02: rd_data = scratch;
        8'h03: rd_data = {6'b0, mode_sweep, mode_image_o};
        8'h04: rd_data = line_stage_l;
        8'h05: rd_data = {4'b0, line_counter[11:8]};
        // LINE_CUR L/H are separate byte reads and can tear across an increment — display/debug use only; the SPI packet spacers carry the authoritative line number.
        8'h06: rd_data = line_counter[7:0];
        8'h07: rd_data = {4'b0, line_counter[11:8]};
        8'h08: rd_data = frame_cnt;
        8'h09: rd_data = {5'b0, s_ovr[1], s_act[1], s_pll[1]};
        default: rd_data = 8'h00;
      endcase
    end
  endmodule
  ```

- [ ] **Step 4: Run and verify pass.** `.\test_projects\i2c_line\run.bat fpga_regs_tb` — expect `ALL TESTS PASSED` (all feature/5 checks plus T-sweep/T-overrun).

- [ ] **Step 5: Fix the feature/5 integration regression.** `.\test_projects\i2c_line\run.bat integration_tb` currently fails its VERSION check. Edit `test_projects/i2c_line/integration_tb.v`:
  (a) line 44 area — after `wire mode_image;` add `wire sweep_value;`
  (b) fpga_regs instantiation (lines 54–63) — add `.overrun_i(1'b0),` after `.img_active_i(img_active),` and `.sweep_value_o(sweep_value),` after `.line_value_o(line_value),` (the wire dangles until Task 5 connects it to line_capture);
  (c) line 341: `check(rb == 8'h01, "I2C-SANITY: VERSION == 0x01");` → `check(rb == 8'h02, "I2C-SANITY: VERSION == 0x02");`

- [ ] **Step 6: Run and verify pass.** `.\test_projects\i2c_line\run.bat integration_tb` — expect `ALL TESTS PASSED` (feature/5 behavior is otherwise unchanged: CTRL writes of 0x00/0x01 leave sweep at 0).

- [ ] **Step 7: Commit.**
  ```powershell
  git add HistoFPGAFw/fpga_regs.v test_projects/i2c_line/fpga_regs_tb.v test_projects/i2c_line/integration_tb.v
  git commit -m "feat: fpga_regs v2 - VERSION 0x02, CTRL SWEEP bit, STATUS overrun, atomic publish" -m "Sweep bit rides the existing req/ack handshake with the line value ({sweep,line} publish is atomic). STATUS bit2 = 2FF-synced overrun level. Refs #8"
  ```

---

### Task 5: `line_capture` v2 — ping/pong sweep capture + overrun tripwire

**Files:**
- Create: `test_projects/drip_scan/sweep_tb.v`
- Modify: `HistoFPGAFw/line_capture.v` (full rewrite shown)
- Modify: `test_projects/i2c_line/line_capture_tb.v` (includes lines 2–5, DUT instantiation lines 80–87)
- Modify: `test_projects/i2c_line/integration_tb.v` (includes lines 12–19, line_capture instantiation lines 87–95)
- Test: `test_projects/drip_scan/sweep_tb.v`, `test_projects/i2c_line/line_capture_tb.v`, `test_projects/i2c_line/integration_tb.v`

**Steps:**

- [ ] **Step 1: Write the failing testbench** `test_projects/drip_scan/sweep_tb.v`. What it proves, scenario by scenario: **F1** — with sweep armed and start_line=2, exactly the lines ≥ 2 push (6 pushes), each with correct header (magic/version/line/flags=0/frame/reserved) and a self-consistent CRC (recomputed over the received bytes — the reference CRC function is itself pinned by crc16_tb); **F2** — with realistic short blanking (drain ≫ row time) only the first eligible line ships and the overrun latch trips (the tripwire); **F3** — subsequent pushes carry header flag bit0 while the latch is set; **F4** — disarmed frame produces nothing; **F5** — re-arming clears the latch and pushes are clean again:
  ```verilog
  `timescale 1ns / 1ps
  // sweep_tb.v — line_capture sweep mode: start-line gating, ping/pong
  // handoff, overrun tripwire (drop + sticky latch + header flag), latch
  // clear on re-arm. Byte-exact payloads are image_pusher_tb's and the
  // sweep integration TB's job; here headers + CRC self-consistency + push
  // accounting are asserted.
  `include "../HistoFPGAFw/crc16.v"
  `include "../HistoFPGAFw/raw10_pack.v"
  `include "../HistoFPGAFw/image_pusher.v"
  `include "../HistoFPGAFw/line_capture.v"
  `include "../HistoFPGAFw/histo_serializer.v"
  `include "../HistoFPGAFw/spi_master.v"
  `include "i2c_line/ram_dp_s_beh.v"

  module sweep_tb;
    reg clk = 0; always #3.75 clk = ~clk;
    reg reset = 1;

    localparam LINES = 8, PAIRS = 16;
    localparam PUSH_BYTES = 2408;

    reg fv = 0, lv = 0;
    reg [19:0] pd = 0;
    integer L, C;

    // CDC: TB plays the fpga_regs side (line=2, sweep=1 delivered together)
    reg [11:0] line_value = 12'd2;
    reg sweep_value = 1'b1;
    reg line_req = 0;
    reg enable = 1'b1;
    wire line_ack, line_sent;
    wire [11:0] sent_line;
    wire img_active, overrun;
    wire ser_done, ser_active;
    wire [31:0] word;

    line_capture dut (
      .clk(clk), .reset(reset), .enable(enable),
      .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
      .line_value_i(line_value), .sweep_value_i(sweep_value),
      .line_req_toggle_i(line_req),
      .line_ack_toggle_o(line_ack), .line_sent_toggle_o(line_sent),
      .sent_line_o(sent_line), .img_active_o(img_active),
      .overrun_o(overrun),
      .serializer_done(ser_done), .word_o(word),
      .serialize_active_o(ser_active));

    wire spi_clk, spi_mosi;
    Serializer ser (
      .fast_clk_in(clk), .reset(reset | ~ser_active), .data_in(word),
      .serial_out(spi_mosi), .slow_clk_out(spi_clk), .done(ser_done), .debug());

    // flat byte-stream monitor (LSB-first)
    reg [7:0] cur; integer nbits = 0;
    integer bytes_lifetime = 0;
    reg [7:0] wire_bytes [0:65535];
    always @(posedge spi_clk) begin
      cur = {spi_mosi, cur[7:1]};
      nbits = nbits + 1;
      if (nbits == 8) begin
        wire_bytes[bytes_lifetime] = cur;
        bytes_lifetime = bytes_lifetime + 1;
        nbits = 0;
      end
    end

    integer errors = 0;
    task check(input cond, input [1023:0] msg);
      if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
    endtask
    integer t0;
    task wait_total_bytes(input integer target, input integer max_ns);
      begin
        t0 = $time;
        while (bytes_lifetime < target && ($time - t0) < max_ns) #10000;
        #50000;
      end
    endtask

    // stimulus: 8 lines x 16 pairs, pixA=(2C+L)&3FF pixB=(2C+1+L)&3FF (NBA
    // per line_capture_tb rationale). send_frame = realistic short blanking
    // (overrun by construction: drain ~687us >> line ~1us). send_frame_paced
    // waits out any drain after each line = the stretched-HTS sweep timing.
    task send_frame;
      begin
        fv <= 1; #400;
        for (L = 0; L < LINES; L = L + 1) begin
          @(posedge clk); lv <= 1;
          for (C = 0; C < PAIRS; C = C + 1) begin
            pd <= ((((2*C + 1 + L) & 20'h3FF) << 10) | ((2*C + L) & 20'h3FF));
            @(posedge clk);
          end
          lv <= 0; pd <= 0;
          repeat (40) @(posedge clk);
        end
        fv <= 0;
      end
    endtask
    integer tp;
    task send_frame_paced;
      begin
        fv <= 1; #400;
        for (L = 0; L < LINES; L = L + 1) begin
          @(posedge clk); lv <= 1;
          for (C = 0; C < PAIRS; C = C + 1) begin
            pd <= ((((2*C + 1 + L) & 20'h3FF) << 10) | ((2*C + L) & 20'h3FF));
            @(posedge clk);
          end
          lv <= 0; pd <= 0;
          repeat (40) @(posedge clk);       // push starts well inside this
          tp = $time;
          while (ser_active && ($time - tp) < 1_500_000) #5000;
          #10000;
        end
        fv <= 0;
      end
    endtask

    // header + CRC-self-consistency check for one push
    function [15:0] crc16_ref(input [15:0] c, input [7:0] b);
      integer k; reg [15:0] t; reg fb;
      begin
        t = c;
        for (k = 7; k >= 0; k = k - 1) begin
          fb = t[15] ^ b[k];
          t = {t[14:0], 1'b0} ^ (fb ? 16'h1021 : 16'h0000);
        end
        crc16_ref = t;
      end
    endfunction
    reg [15:0] ecrc; integer eb; reg hok;
    task check_push_hdr(input integer base, input [11:0] eline,
                        input [7:0] eframe, input [3:0] eflags,
                        input [1023:0] label);
      begin
        hok = (wire_bytes[base+0] === 8'hB6) && (wire_bytes[base+1] === 8'h01) &&
              (wire_bytes[base+2] === eline[7:0]) &&
              (wire_bytes[base+3] === {eflags, eline[11:8]}) &&
              (wire_bytes[base+4] === eframe) && (wire_bytes[base+5] === 8'h00);
        if (!hok)
          $display("  header got %02x %02x %02x %02x %02x %02x (want line=%0d frame=%0d flags=%h)",
                   wire_bytes[base+0], wire_bytes[base+1], wire_bytes[base+2],
                   wire_bytes[base+3], wire_bytes[base+4], wire_bytes[base+5],
                   eline, eframe, eflags);
        check(hok, label);
        ecrc = 16'hFFFF;
        for (eb = 0; eb < 2406; eb = eb + 1)
          ecrc = crc16_ref(ecrc, wire_bytes[base+eb]);
        check({wire_bytes[base+2406], wire_bytes[base+2407]} === ecrc, label);
      end
    endtask

    integer base, k;
    initial begin
      $dumpfile("out/sweep_tb.vcd"); $dumpvars(0, sweep_tb);
      #100 reset = 0; #100;
      line_req = ~line_req; #500;          // deliver {line=2, sweep=1}
      check(line_ack == line_req, "CDC ack for {line=2, sweep=1}");

      // F1: paced sweep frame — lines 2..7 push, lines 0..1 do not
      base = bytes_lifetime;
      send_frame_paced;                    // frame_cnt = 1
      wait_total_bytes(base + 6*PUSH_BYTES, 6_000_000);
      check(bytes_lifetime == base + 6*PUSH_BYTES, "F1: exactly 6 pushes (start_line=2)");
      for (k = 0; k < 6; k = k + 1)
        check_push_hdr(base + k*PUSH_BYTES, 2+k, 8'd1, 4'h0, "F1: push header+CRC");
      check(!overrun, "F1: no overrun");

      // F2: overrun tripwire — short blanking, drain >> row time
      base = bytes_lifetime;
      send_frame;                          // frame_cnt = 2
      wait_total_bytes(base + PUSH_BYTES, 3_000_000);
      #200000;                             // settle: no further pushes may appear
      check(bytes_lifetime == base + PUSH_BYTES, "F2: exactly ONE push (rest dropped)");
      check_push_hdr(base, 12'd2, 8'd2, 4'h0, "F2: push is line 2, flags still 0");
      check(overrun, "F2: overrun latch set");

      // F3: latch propagates into header flag bit0 on later pushes
      base = bytes_lifetime;
      send_frame_paced;                    // frame_cnt = 3
      wait_total_bytes(base + 6*PUSH_BYTES, 6_000_000);
      check(bytes_lifetime == base + 6*PUSH_BYTES, "F3: 6 pushes while latched");
      for (k = 0; k < 6; k = k + 1)
        check_push_hdr(base + k*PUSH_BYTES, 2+k, 8'd3, 4'h1, "F3: header flag bit0 set");
      check(overrun, "F3: latch still set (no re-arm)");

      // F4: disarm (image mode off, like the host exit path) — no pushes
      enable = 0;
      base = bytes_lifetime;
      send_frame;                          // frame_cnt = 4
      #300000;
      check(bytes_lifetime == base, "F4: disarmed frame produces nothing");

      // F5: re-arm — arm edge clears the latch; pushes clean again
      enable = 1;
      base = bytes_lifetime;
      send_frame_paced;                    // frame_cnt = 5
      wait_total_bytes(base + 6*PUSH_BYTES, 6_000_000);
      check(bytes_lifetime == base + 6*PUSH_BYTES, "F5: 6 pushes after re-arm");
      for (k = 0; k < 6; k = k + 1)
        check_push_hdr(base + k*PUSH_BYTES, 2+k, 8'd5, 4'h0, "F5: flags clear after re-arm");
      check(!overrun, "F5: latch cleared on arm edge");

      if (errors == 0) $display("ALL TESTS PASSED");
      else $display("%0d ERRORS", errors);
      $finish;
    end

    initial begin
      #100_000_000;
      $display("FAIL: watchdog timeout");
      $finish;
    end
  endmodule
  ```

- [ ] **Step 2: Run and verify it fails.** `.\test_projects\drip_scan\run.bat sweep_tb` — expect a compile error like ``error: port `sweep_value_i' is not a port of dut`` (v1 line_capture has no sweep ports).

- [ ] **Step 3: Rewrite `HistoFPGAFw/line_capture.v`** (complete file). The single-line path is byte-for-byte the feature/5 logic (two additive guards: `~armed_sweep` in `capturing`, `~pusher_busy` on S_SER entry — both no-ops when sweep is never armed). New: sweep CDC bit, arm at fv boundary, ping/pong WE steering, handoff/drop at line end, sticky overrun latch, second RAM, `image_pusher` instance, output muxes:
  ```verilog
  // line_capture.v — image-mode readout producers (single-line + sweep).
  //
  // SINGLE-LINE mode (feature/5, unchanged): captures one selected video
  // line per frame into buffer 0 and replays it through the shared
  // Serializer using the exact framing of histogram packets (1025 words /
  // 4100 bytes, incl. the phantom first done pulse — see spec).
  // Serialization starts at frame_valid falling edge so packets keep the
  // histogram timing envelope (MCU DMA re-arm race).
  //
  // SWEEP mode (feature/8 drip-scan): when the sweep bit (delivered
  // atomically with the start line over the req/ack handshake) is armed at
  // a frame boundary, EVERY line >= target is captured, ping/pong across
  // two line RAMs, and handed to image_pusher, which drains a 2408-B RAW10
  // push while the next line lands in the other buffer. A line that
  // completes while the pusher is still draining is DROPPED and a sticky
  // overrun latch is set (STATUS bit2 / header flag bit0), cleared on the
  // next sweep arm edge. Open-loop timing with a tripwire: at sweep HTS
  // (row 0.80 ms > drain 0.69 ms) an overrun means the host mis-programmed
  // the sensor. Sweep never toggles line_sent, so fpga_regs' line counter
  // holds the host-written start line.
  module line_capture #(
      parameter [7:0] MAGIC = 8'hB6
  ) (
      input  wire        clk,               // clk_pixel_hs
      input  wire        reset,
      input  wire        enable,            // image mode (already synced to clk)
      input  wire [19:0] pixel_data,
      input  wire        frame_valid,
      input  wire        line_valid,
      // CDC with fpga_regs (osc domain)
      input  wire [11:0] line_value_i,
      input  wire        sweep_value_i,     // atomic with line_value_i
      input  wire        line_req_toggle_i,
      output reg         line_ack_toggle_o,
      output reg         line_sent_toggle_o,
      output wire [11:0] sent_line_o,       // which line the last toggle reported (quasi-static)
      output wire        img_active_o,
      output wire        overrun_o,         // sticky latch (quasi-static level)
      // serializer interface
      input  wire        serializer_done,
      output wire [31:0] word_o,
      output wire        serialize_active_o
  );

    // ---- CDC receive: target line + sweep bit ----
    // Level-mismatch reception (synced req != our ack), NOT edge detection:
    // self-heals from any stale state after reset skew with a stopped pixel
    // clock (an edge-detect history flop can latch a stale '1' and deadlock).
    reg [1:0] s_req /* synthesis syn_preserve=1 */;
    reg [11:0] target;
    reg sweep_pend;
    always @(posedge clk) begin
      if (reset) begin
        s_req <= 2'b00; target <= 12'd0; sweep_pend <= 1'b0;
        line_ack_toggle_o <= 1'b0;
      end else begin
        s_req <= {s_req[0], line_req_toggle_i};
        if (s_req[1] != line_ack_toggle_o) begin
          target <= line_value_i;           // stable while req pending
          sweep_pend <= sweep_value_i;
          line_ack_toggle_o <= s_req[1];
        end
      end
    end

    // ---- video position tracking ----
    reg fv_q, lv_q;
    always @(posedge clk) begin fv_q <= frame_valid; lv_q <= line_valid; end
    wire fv_rise = frame_valid & ~fv_q;
    wire fv_fall = ~frame_valid & fv_q;
    wire lv_fall = ~line_valid & lv_q;

    reg [11:0] line_cnt;
    reg [10:0] col_cnt;
    reg [7:0]  frame_cnt;
    always @(posedge clk) begin
      if (reset) begin line_cnt <= 12'd0; frame_cnt <= 8'd0; end
      else begin
        if (fv_rise) begin line_cnt <= 12'd0; frame_cnt <= frame_cnt + 8'd1; end
        else if (lv_fall) line_cnt <= line_cnt + 12'd1;
      end
      if (reset | ~line_valid) col_cnt <= 11'd0;
      else col_cnt <= col_cnt + 11'd1;
    end

    // ---- capture control ----
    localparam S_IDLE = 1'b0, S_SER = 1'b1;
    reg state;
    reg armed, armed_sweep, captured;
    reg [11:0] line_rep;                    // line number of the captured data
    reg [9:0] word_idx;                     // serializer word counter (see below)
    reg prev_done, flag;
    reg capturing_q;

    wire pusher_busy, pusher_active;

    // single-line capture: gated off entirely while sweep is armed
    wire capturing = armed & ~armed_sweep & (state == S_IDLE) & ~captured &
                     frame_valid & line_valid & (line_cnt == target);

    // sweep capture: every line >= start line
    wire sweep_hit = armed_sweep & frame_valid & line_valid & (line_cnt >= target);
    reg  sweep_hit_q;
    reg  wr_sel;                            // buffer being written
    reg  ovr_latch;
    reg  push_start;
    reg  [11:0] push_line;
    reg  [7:0]  push_frame;
    reg  push_buf;                          // buffer being drained
    wire sweep_arm_edge = fv_rise & enable & sweep_pend & ~armed_sweep;

    always @(posedge clk) begin
      if (reset) begin
        armed <= 1'b0; armed_sweep <= 1'b0; captured <= 1'b0;
        line_rep <= 12'd0; state <= S_IDLE;
        line_sent_toggle_o <= 1'b0; capturing_q <= 1'b0;
        sweep_hit_q <= 1'b0; wr_sel <= 1'b0; ovr_latch <= 1'b0;
        push_start <= 1'b0; push_line <= 12'd0; push_frame <= 8'd0;
        push_buf <= 1'b0;
      end else begin
        push_start <= 1'b0;                 // default: 1-clk pulse
        if (fv_rise) begin
          armed <= enable;                  // mode changes land on frame boundaries
          armed_sweep <= enable & sweep_pend;
        end
        if (sweep_arm_edge) ovr_latch <= 1'b0;   // spec: cleared on sweep arm

        // -- single-line path (feature/5, unchanged) --
        capturing_q <= capturing;
        if (capturing_q & ~capturing) begin
          // Latch only if capture ended with the line (lv/fv low). If lv&fv
          // are still high, the target changed mid-line: discard the partial
          // capture (no packet, no toggle) — next frame captures cleanly.
          if (!(line_valid & frame_valid)) begin
            captured <= 1'b1; line_rep <= target;
          end
        end
        case (state)
          // Level-based (not fv_fall pulse) — see feature/5 gap=0 rationale.
          // ~pusher_busy: never contend with a still-draining sweep push
          // (cross-mode corner at sweep exit; host sequencing avoids it,
          // the guard makes it safe regardless).
          S_IDLE: if (~frame_valid & captured & ~pusher_busy) state <= S_SER;
          S_SER:  if (serializer_done && word_idx == 10'h0 && flag == 1'b1) begin
                    state <= S_IDLE;
                    captured <= 1'b0;
                    line_sent_toggle_o <= ~line_sent_toggle_o;
                  end
        endcase

        // -- sweep path: hand each completed line to the pusher, or drop --
        sweep_hit_q <= sweep_hit;
        if (sweep_hit_q & ~sweep_hit) begin
          if (!(line_valid & frame_valid)) begin   // clean line end
            if (pusher_busy) begin
              ovr_latch <= 1'b1;            // drop: wr_sel unchanged, reuse buffer
            end else begin
              push_start <= 1'b1;
              push_line  <= line_cnt;       // pre-increment value (lv_fall
                                            // bumps line_cnt this same edge)
              push_frame <= frame_cnt;
              push_buf   <= wr_sel;
              wr_sel     <= ~wr_sel;
            end
          end
        end
      end
    end
    assign img_active_o = armed;
    assign overrun_o = ovr_latch;
    assign serialize_active_o = (state == S_SER) | pusher_active;
    assign sent_line_o = line_rep;          // quasi-static: stable around the sent toggle

    // ---- word counter: byte-exact replica of histo_module bin behavior ----
    always @(posedge clk) begin
      if (reset | (state != S_SER)) begin
        word_idx <= 10'h3FF; prev_done <= 1'b0; flag <= 1'b0;
      end else begin
        prev_done <= serializer_done;
        if (!prev_done && serializer_done)
          word_idx <= word_idx + 10'd1;
        if (word_idx == 10'd1) flag <= 1'b1;
      end
    end

    // ---- line buffers (ping/pong; buffer 0 doubles as the legacy buffer) ----
    wire [23:0] q0, q1;
    wire [9:0]  pusher_addr;
    wire [9:0]  rd_addr0 = pusher_active ? pusher_addr : word_idx;
    wire we0 = (capturing | (sweep_hit & ~wr_sel)) & ~col_cnt[10];
    wire we1 = (sweep_hit &  wr_sel) & ~col_cnt[10];
    ram_dp_s line_ram (
      .Reset(reset),
      .RdClock(clk), .RdClockEn(~reset), .RdAddress(rd_addr0), .Q(q0),
      .WrClock(clk), .WrClockEn(~reset), .WrAddress(col_cnt[9:0]),
      .Data({4'b0, pixel_data}),
      .WE(we0));
    ram_dp_s line_ram_b (
      .Reset(reset),
      .RdClock(clk), .RdClockEn(~reset), .RdAddress(pusher_addr), .Q(q1),
      .WrClock(clk), .WrClockEn(~reset), .WrAddress(col_cnt[9:0]),
      .Data({4'b0, pixel_data}),
      .WE(we1));

    // legacy read pipeline — mirrors histo_calc's data_out_persistent staging
    reg [9:0] word_idx_q;
    reg word_changed_q;
    reg [23:0] data_persistent;
    always @(posedge clk) begin
      word_idx_q <= word_idx;
      word_changed_q <= (word_idx != word_idx_q);
      if (word_changed_q) data_persistent <= q0;
    end

    // ---- metadata spacer (legacy envelope) ----
    reg [7:0] spacer;
    always @(*) begin
      case (word_idx)
        10'h3FF: spacer = frame_cnt;
        10'h000: spacer = line_rep[7:0];
        10'h001: spacer = {4'b0, line_rep[11:8]};
        10'h002: spacer = MAGIC;
        default: spacer = 8'h00;
      endcase
    end

    // ---- sweep drain: image_pusher ----
    wire [31:0] pusher_word;
    image_pusher #(.MAGIC(MAGIC)) pusher_i (
      .clk(clk), .reset(reset),
      .start_i(push_start), .line_i(push_line), .frame_i(push_frame),
      .ovr_flag_i(ovr_latch), .busy_o(pusher_busy),
      .ram_addr_o(pusher_addr), .ram_q_i(push_buf ? q1 : q0),
      .serializer_done(serializer_done),
      .word_o(pusher_word), .serialize_active_o(pusher_active));

    assign word_o = pusher_active ? pusher_word : {spacer, data_persistent};
  endmodule
  ```

- [ ] **Step 4: Run and verify pass.** `.\test_projects\drip_scan\run.bat sweep_tb` — expect `ALL TESTS PASSED`. This TB runs ~13 ms of simulated time (19 push drains); expect a few minutes of wall clock.

- [ ] **Step 5: Update the feature/5 unit TB.** Edit `test_projects/i2c_line/line_capture_tb.v`:
  (a) includes (lines 2–5) — the DUT now instantiates the new modules, so add before the line_capture include:
  ```verilog
  `include "../HistoFPGAFw/crc16.v"
  `include "../HistoFPGAFw/raw10_pack.v"
  `include "../HistoFPGAFw/image_pusher.v"
  ```
  (b) DUT instantiation (lines 80–87) — tie sweep off, leave overrun open:
  ```verilog
    line_capture dut (
      .clk(clk), .reset(reset), .enable(enable),
      .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
      .line_value_i(line_value), .sweep_value_i(1'b0),
      .line_req_toggle_i(line_req),
      .line_ack_toggle_o(line_ack), .line_sent_toggle_o(line_sent),
      .sent_line_o(sent_line), .img_active_o(img_active),
      .overrun_o(),
      .serializer_done(ser_done), .word_o(word),
      .serialize_active_o(ser_active));
  ```
  Run `.\test_projects\i2c_line\run.bat line_capture_tb` — expect `ALL TESTS PASSED` with zero check changes (this IS the single-line regression proof).

- [ ] **Step 6: Update the feature/5 integration TB wiring.** Edit `test_projects/i2c_line/integration_tb.v`:
  (a) includes (lines 12–19) — add the same three includes as above (before `line_capture.v`);
  (b) line_capture instantiation (lines 87–95) — connect the now-real sweep wire and leave overrun open (fpga_regs' `overrun_i` stays tied 0 from Task 4; full closure comes in Task 6's new TB):
  ```verilog
    line_capture line_capture_i (
        .clk(clk_pix), .reset(pix_reset), .enable(mode_pix),
        .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
        .line_value_i(line_value), .sweep_value_i(sweep_value),
        .line_req_toggle_i(line_req_toggle),
        .line_ack_toggle_o(line_ack_toggle),
        .line_sent_toggle_o(line_sent_toggle), .sent_line_o(sent_line),
        .img_active_o(img_active), .overrun_o(),
        .serializer_done(ser_done),
        .word_o(lc_word), .serialize_active_o(lc_active));
  ```
  Run `.\test_projects\i2c_line\run.bat integration_tb` — expect `ALL TESTS PASSED` (CTRL is only ever written 0x00/0x01 there, so sweep stays disarmed and every feature/5 packet — histogram and image — is bit-identical).

- [ ] **Step 7: Commit.**
  ```powershell
  git add HistoFPGAFw/line_capture.v test_projects/drip_scan/sweep_tb.v test_projects/i2c_line/line_capture_tb.v test_projects/i2c_line/integration_tb.v
  git commit -m "feat: line_capture sweep mode - ping/pong double buffer, overrun tripwire" -m "Second ram_dp_s (+3 EBR -> 15/20), capture every line >= start line, immediate image_pusher handoff, drop+latch on overrun (STATUS bit2 / header flag bit0, cleared on arm). Single-line path unchanged; feature/5 TBs pass untouched. Refs #8"
  ```

---

### Task 6: top-level wiring + full-chain sweep integration TB

**Files:**
- Create: `test_projects/drip_scan/sweep_integration_tb.v`
- Modify: `HistoFPGAFw/top.v` (wire decls lines 98–102, fpga_regs_i lines 110–119, line_capture_i lines 139–147)
- Test: `test_projects/drip_scan/sweep_integration_tb.v` + all four existing TBs

**Steps:**

- [ ] **Step 1: Write the integration testbench** `test_projects/drip_scan/sweep_integration_tb.v`. `top.v` cannot be simulated (Lattice OSCI/PLL primitives), so this TB is the executable definition of the new top wiring, exactly like `integration_tb.v` was for feature/5 — i2c_slave + fpga_regs on a separate ~24 MHz clock (harder CDC than the real single-clock top), producers + shared Serializer replicated verbatim. What it proves: (1) the histogram envelope is **bit-identical** through the v2 wiring (same checks/sums as feature/5, incl. the issue-#6 `SUM_BUG_PER_FRAME` offset convention); (2) legacy single-line packets unchanged; (3) sweep pushes are **byte-exact including CRC** end-to-end from I2C arm to SPI bytes, with `frame_cnt` constant across an image; (4) overrun is visible via I2C STATUS bit2 and header flag; (5) clean exit back to histogram streaming with deterministic sums:
  ```verilog
  `timescale 1ns / 1ps
  // sweep_integration_tb.v — full-chain drip-scan integration TB. Replicates
  // top.v's v2 wiring EXACTLY (see HistoFPGAFw/top.v: i2c_slave + fpga_regs;
  // 2FF mode sync; histogram_module(enable=~mode_pix) + line_capture(enable=
  // mode_pix) racing into the SHARED Serializer with reset `pix_reset |
  // ~(hm_active|lc_active)` and mux `lc_active ? lc_word : hm_word`; NEW:
  // sweep_value and lc_overrun between fpga_regs and line_capture) because
  // top.v cannot be simulated (Lattice OSCI/PLL primitives).
  // Frame ledger (histogram3 accumulates on fv/lv regardless of enable;
  // bins wipe only on a histogram SERIALIZE readout — see integration_tb.v):
  //   F1 histo boot (wipes) | F2 legacy line-5 | F3 sweep paced | F4 sweep
  //   overrun | F5 sweep paced (flagged) | F6 histo (accumulated F2..F6 =
  //   5 frames, wipes) | F7 histo steady (1 frame).
  `include "../HistoFPGAFw/i2c_slave.v"
  `include "../HistoFPGAFw/fpga_regs.v"
  `include "../HistoFPGAFw/crc16.v"
  `include "../HistoFPGAFw/raw10_pack.v"
  `include "../HistoFPGAFw/image_pusher.v"
  `include "../HistoFPGAFw/line_capture.v"
  `include "../HistoFPGAFw/histo_module.v"
  `include "../HistoFPGAFw/histo_calc.v"
  `include "../HistoFPGAFw/histo_serializer.v"
  `include "../HistoFPGAFw/spi_master.v"
  `include "i2c_line/ram_dp_s_beh.v"

  module sweep_integration_tb;
    reg clk_osc = 0;  always #21   clk_osc = ~clk_osc;   // ~24 MHz
    reg clk_pix = 0;  always #3.75 clk_pix = ~clk_pix;   // ~133 MHz
    reg reset = 1;

    // Pre-existing histogram3 defect (repo issue #6): +4 spurious counts per
    // frame (see integration_tb.v). Sum checks include the offset; when #6
    // is fixed these fail loudly — remove the offset then.
    localparam SUM_BUG_PER_FRAME = 4;
    localparam PIXELS_PER_FRAME = 256;     // 2*PAIRS*LINES
    localparam LINES = 8, PAIRS = 16;
    localparam PUSH_BYTES = 2408;

    /*------------------I2C control plane (clk_osc domain)------------------*/
    reg m_scl = 1, m_sda_drive_low = 0;
    wire sda_oe;
    wire sda_bus = (m_sda_drive_low | sda_oe) ? 1'b0 : 1'b1;
    wire [7:0] r_addr, r_wdata, r_rdata;
    wire r_wstrobe;
    wire mode_image, sweep_value;
    wire [11:0] line_value, sent_line;
    wire line_req_toggle, line_ack_toggle, line_sent_toggle;
    wire img_active, lc_overrun;

    i2c_slave #(.I2C_ADDR(7'h5A)) i2c_slave_i (
        .clk(clk_osc), .reset(reset),
        .scl_i(m_scl), .sda_i(sda_bus), .sda_oe(sda_oe),
        .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
        .rd_data(r_rdata));

    fpga_regs fpga_regs_i (
        .clk(clk_osc), .reset(reset),
        .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
        .rd_data(r_rdata),
        .pll_lock_i(1'b1), .fv_i(fv),
        .line_sent_toggle_i(line_sent_toggle), .sent_line_i(sent_line),
        .img_active_i(img_active),
        .overrun_i(lc_overrun),
        .line_ack_toggle_i(line_ack_toggle),
        .mode_image_o(mode_image), .line_value_o(line_value),
        .sweep_value_o(sweep_value),
        .line_req_toggle_o(line_req_toggle));

    /*------------------Readout producers (clk_pix domain)------------------*/
    reg [1:0] mode_sync /* synthesis syn_preserve=1 */;
    always @(posedge clk_pix) mode_sync <= {mode_sync[0], mode_image};
    wire mode_pix = mode_sync[1];
    wire pix_reset = reset;

    reg fv = 0, lv = 0;
    reg [19:0] pd = 0;
    wire ser_done;
    wire [31:0] hm_word, lc_word;
    wire hm_active, lc_active;

    histogram_module histogram_module_i (
        .clk(clk_pix), .reset(pix_reset), .enable(~mode_pix),
        .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
        .serializer_done_i(ser_done),
        .word_o(hm_word), .serialize_active_o(hm_active),
        .debug(), .debug2());

    line_capture line_capture_i (
        .clk(clk_pix), .reset(pix_reset), .enable(mode_pix),
        .pixel_data(pd), .frame_valid(fv), .line_valid(lv),
        .line_value_i(line_value), .sweep_value_i(sweep_value),
        .line_req_toggle_i(line_req_toggle),
        .line_ack_toggle_o(line_ack_toggle),
        .line_sent_toggle_o(line_sent_toggle), .sent_line_o(sent_line),
        .img_active_o(img_active), .overrun_o(lc_overrun),
        .serializer_done(ser_done),
        .word_o(lc_word), .serialize_active_o(lc_active));

    wire spi_clk, spi_mosi;
    Serializer serializer_i (
        .fast_clk_in(clk_pix),
        .reset(pix_reset | ~(hm_active | lc_active)),
        .data_in(lc_active ? lc_word : hm_word),
        .serial_out(spi_mosi), .slow_clk_out(spi_clk),
        .done(ser_done), .debug());

    /*------------------flat SPI byte-stream monitor------------------------*/
    // Packets vary in size now (4100-B envelopes vs 2408-B pushes), so the
    // monitor records EVERY byte at its absolute stream offset; tests index
    // from a snapshotted base.
    reg [7:0] cur_byte; integer nbits = 0;
    integer bytes_lifetime = 0;
    reg [7:0] wire_bytes [0:65535];
    always @(posedge spi_clk) begin
      cur_byte = {spi_mosi, cur_byte[7:1]};   // LSB first
      nbits = nbits + 1;
      if (nbits == 8) begin
        wire_bytes[bytes_lifetime] = cur_byte;
        bytes_lifetime = bytes_lifetime + 1;
        nbits = 0;
      end
    end
    function [31:0] env_word(input integer base, input integer idx);
      env_word = {wire_bytes[base+4*idx+3], wire_bytes[base+4*idx+2],
                  wire_bytes[base+4*idx+1], wire_bytes[base+4*idx]};
    endfunction

    /*------------------camera stimulus--------------------------------------*/
    integer L, C;
    task send_frame;
      begin
        fv <= 1; #400;
        for (L = 0; L < LINES; L = L + 1) begin
          @(posedge clk_pix); lv <= 1;
          for (C = 0; C < PAIRS; C = C + 1) begin
            pd <= ((((2*C + 1 + L) & 20'h3FF) << 10) | ((2*C + L) & 20'h3FF));
            @(posedge clk_pix);
          end
          lv <= 0; pd <= 0;
          repeat (40) @(posedge clk_pix);   // horizontal blanking
        end
        fv <= 0;
      end
    endtask
    integer tp;
    task send_frame_paced;                  // sweep timing: wait out drains
      begin
        fv <= 1; #400;
        for (L = 0; L < LINES; L = L + 1) begin
          @(posedge clk_pix); lv <= 1;
          for (C = 0; C < PAIRS; C = C + 1) begin
            pd <= ((((2*C + 1 + L) & 20'h3FF) << 10) | ((2*C + L) & 20'h3FF));
            @(posedge clk_pix);
          end
          lv <= 0; pd <= 0;
          repeat (40) @(posedge clk_pix);
          tp = $time;
          while (lc_active && ($time - tp) < 1_500_000) #5000;
          #10000;
        end
        fv <= 0;
      end
    endtask

    /*------------------I2C master + wr_reg/rd_reg---------------------------*/
    `include "i2c_line/i2c_master_tasks.vh"
    reg ack;
    task wr_reg(input [7:0] r, input [7:0] v);
      begin
        i2c_start; i2c_write_byte({7'h5A,1'b0}, ack);
        i2c_write_byte(r, ack); i2c_write_byte(v, ack); i2c_stop; #2000;
      end
    endtask
    task rd_reg(input [7:0] r, output [7:0] v);
      begin
        i2c_start; i2c_write_byte({7'h5A,1'b0}, ack); i2c_write_byte(r, ack);
        i2c_start; i2c_write_byte({7'h5A,1'b1}, ack);
        i2c_read_byte(1'b0, v); i2c_stop; #2000;
      end
    endtask

    /*------------------checks + reference models----------------------------*/
    integer errors = 0;
    task check(input cond, input [1023:0] msg);
      if (!cond) begin errors = errors + 1; $display("FAIL: %0s", msg); end
    endtask
    integer t0;
    task wait_total_bytes(input integer target, input integer max_ns);
      begin
        t0 = $time;
        while (bytes_lifetime < target && ($time - t0) < max_ns) #10000;
        #50000;
      end
    endtask
    integer sum_i; reg [31:0] sum_acc;
    function [31:0] env_sum(input integer base);
      begin
        sum_acc = 0;
        for (sum_i = 0; sum_i < 1024; sum_i = sum_i + 1)
          sum_acc = sum_acc + (env_word(base, sum_i) & 24'hFFFFFF);
        env_sum = sum_acc;
      end
    endfunction
    task check_env_sum(input integer base, input [31:0] expected,
                       input [1023:0] label);
      begin
        $display("INFO: %0s: observed sum=%0d expected=%0d",
                 label, env_sum(base), expected);
        check(env_sum(base) == expected, label);
      end
    endtask

    function [19:0] tb_pair(input [11:0] fline, input integer idx);
      tb_pair = (idx < 16)
        ? ((((2*idx + 1 + fline) & 10'h3FF) << 10) | ((2*idx + fline) & 10'h3FF))
        : 20'd0;
    endfunction
    function [15:0] crc16_ref(input [15:0] c, input [7:0] b);
      integer k; reg [15:0] t; reg fb;
      begin
        t = c;
        for (k = 7; k >= 0; k = k - 1) begin
          fb = t[15] ^ b[k];
          t = {t[14:0], 1'b0} ^ (fb ? 16'h1021 : 16'h0000);
        end
        crc16_ref = t;
      end
    endfunction
    reg [7:0] exp_push [0:2407];
    reg [39:0] gval; reg [15:0] ecrc;
    integer ep, eb, ci, mism;
    task check_push(input integer base, input [11:0] eline,
                    input [7:0] eframe, input [3:0] eflags,
                    input [1023:0] label);
      begin
        exp_push[0] = 8'hB6; exp_push[1] = 8'h01;
        exp_push[2] = eline[7:0];
        exp_push[3] = {eflags, eline[11:8]};
        exp_push[4] = eframe; exp_push[5] = 8'h00;
        for (ep = 0; ep < 480; ep = ep + 1) begin
          gval = {tb_pair(eline, 2*ep + 1), tb_pair(eline, 2*ep)};
          for (eb = 0; eb < 5; eb = eb + 1)
            exp_push[6 + 5*ep + eb] = gval >> (8*eb);
        end
        ecrc = 16'hFFFF;
        for (eb = 0; eb < 2406; eb = eb + 1)
          ecrc = crc16_ref(ecrc, exp_push[eb]);
        exp_push[2406] = ecrc[15:8];
        exp_push[2407] = ecrc[7:0];
        mism = 0;
        for (ci = 0; ci < 2408; ci = ci + 1)
          if (wire_bytes[base+ci] !== exp_push[ci]) begin
            if (mism == 0)
              $display("  first mismatch at byte %0d: got %02x want %02x",
                       ci, wire_bytes[base+ci], exp_push[ci]);
            mism = mism + 1;
          end
        check(mism == 0, label);
      end
    endtask

    integer base, k, w;
    reg [31:0] wv;
    reg [7:0] rb;
    initial begin
      $dumpfile("out/sweep_integration_tb.vcd");
      $dumpvars(0, sweep_integration_tb);
      reset = 1;
      #300 reset = 0;

      // ===== F1: BOOT HISTOGRAM — envelope bit-identical to feature/5 =====
      base = bytes_lifetime;
      send_frame;
      wait_total_bytes(base + 4100, 1_700_000);
      check(bytes_lifetime == base + 4100, "F1: exactly one 4100-B envelope");
      check(env_word(base, 2) >> 24 == 8'h00, "F1: word2 spacer 0x00 (no magic)");
      check(env_word(base, 1023) >> 24 == 8'h01, "F1: frame counter spacer == 1");
      check_env_sum(base, PIXELS_PER_FRAME + SUM_BUG_PER_FRAME, "F1: histogram sum");

      // ===== I2C sanity =====
      rd_reg(8'h00, rb); check(rb == 8'h5A, "I2C: ID 0x5A");
      rd_reg(8'h01, rb); check(rb == 8'h02, "I2C: VERSION 0x02");

      // ===== F2: LEGACY single-line image mode (regression) =====
      wr_reg(8'h04, 8'h05); wr_reg(8'h05, 8'h00);   // LINE = 5
      wr_reg(8'h03, 8'h01);                          // image mode, no sweep
      #50_000;
      base = bytes_lifetime;
      send_frame;
      wait_total_bytes(base + 4100, 1_700_000);
      check(bytes_lifetime == base + 4100, "F2: one legacy 4100-B image packet");
      check(env_word(base, 2) >> 24 == 8'hB6, "F2: magic 0xB6");
      check(env_word(base, 0) >> 24 == 8'h05, "F2: line tag 5");
      check(env_word(base, 1023) >> 24 == 8'h02, "F2: frame counter spacer == 2");
      for (w = 0; w < PAIRS; w = w + 1) begin
        wv = env_word(base, w);
        check((wv & 20'hFFFFF) == tb_pair(12'd5, w), "F2: line-5 pixel word");
      end

      // ===== F3: SWEEP, start line 2 — byte-exact pushes ====
      // (F2's legacy send auto-incremented LINE to 6; rewrite it first.)
      wr_reg(8'h04, 8'h02); wr_reg(8'h05, 8'h00);   // start line = 2
      wr_reg(8'h03, 8'h03);                          // image + SWEEP
      #50_000;
      base = bytes_lifetime;
      send_frame_paced;                              // frame_cnt = 3
      wait_total_bytes(base + 6*PUSH_BYTES, 12_000_000);
      check(bytes_lifetime == base + 6*PUSH_BYTES, "F3: exactly 6 pushes");
      for (k = 0; k < 6; k = k + 1)
        check_push(base + k*PUSH_BYTES, 2+k, 8'd3, 4'h0, "F3: byte-exact push (frame const)");
      rd_reg(8'h09, rb);
      check(rb == 8'h03, "F3: STATUS lock+active, overrun clear");

      // ===== F4: OVERRUN — production-rate frame, drain >> row time =====
      base = bytes_lifetime;
      send_frame;                                    // frame_cnt = 4
      wait_total_bytes(base + PUSH_BYTES, 3_000_000);
      #200000;
      check(bytes_lifetime == base + PUSH_BYTES, "F4: exactly ONE push (rest dropped)");
      check_push(base, 12'd2, 8'd4, 4'h0, "F4: push line 2, flags still 0");
      rd_reg(8'h09, rb);
      check(rb == 8'h07, "F4: STATUS bit2 overrun set (via I2C)");

      // ===== F5: latch -> header flag bit0 on subsequent pushes ====
      base = bytes_lifetime;
      send_frame_paced;                              // frame_cnt = 5
      wait_total_bytes(base + 6*PUSH_BYTES, 12_000_000);
      check(bytes_lifetime == base + 6*PUSH_BYTES, "F5: 6 pushes while latched");
      for (k = 0; k < 6; k = k + 1)
        check_push(base + k*PUSH_BYTES, 2+k, 8'd5, 4'h1, "F5: flagged byte-exact push");

      // ===== F6/F7: EXIT — histogram streaming intact ====
      // F6 is the documented discard-first packet: bins accumulated F2..F6
      // (5 frames; no histogram readout ran during image mode) then wipe.
      wr_reg(8'h03, 8'h00);
      #50_000;
      base = bytes_lifetime;
      send_frame;                                    // frame_cnt = 6
      wait_total_bytes(base + 4100, 1_700_000);
      check(bytes_lifetime == base + 4100, "F6: one 4100-B envelope");
      check(env_word(base, 2) >> 24 == 8'h00, "F6: no magic (histogram)");
      check_env_sum(base, 5*(PIXELS_PER_FRAME + SUM_BUG_PER_FRAME),
                    "F6: first-after-exit sum (5 accumulated frames)");
      base = bytes_lifetime;
      send_frame;                                    // frame_cnt = 7
      wait_total_bytes(base + 4100, 1_700_000);
      check(bytes_lifetime == base + 4100, "F7: one 4100-B envelope");
      check(env_word(base, 2) >> 24 == 8'h00, "F7: no magic");
      check_env_sum(base, PIXELS_PER_FRAME + SUM_BUG_PER_FRAME,
                    "F7: steady-state histogram sum");

      if (errors == 0) $display("ALL TESTS PASSED");
      else $display("%0d ERRORS", errors);
      $finish;
    end

    // ~16 ms of simulated time (13 push drains + 4 envelopes); generous cap
    initial begin
      #200_000_000;
      $display("FAIL: watchdog timeout -- sim did not finish");
      $finish;
    end
  endmodule
  ```

- [ ] **Step 2: Run it.** `.\test_projects\drip_scan\run.bat sweep_integration_tb` — expect `ALL TESTS PASSED` (wall clock: several minutes; the `INFO:` sum lines print observed vs expected either way). Debug any failure here before touching `top.v` — this TB is the wiring spec.

- [ ] **Step 3: Wire `top.v`.** Three edits in `HistoFPGAFw/top.v`, mirroring the TB exactly:
  (a) wire declarations (lines 98–102) — replace with:
  ```verilog
    wire [7:0] r_addr, r_wdata, r_rdata;
    wire r_wstrobe, sda_oe;
    wire mode_image, sweep_value, lc_overrun;
    wire [11:0] line_value, sent_line;
    wire line_req_toggle, line_ack_toggle, line_sent_toggle, img_active;
  ```
  (b) `fpga_regs_i` (lines 110–119) — replace with:
  ```verilog
    fpga_regs fpga_regs_i (
        .clk(clk_pixel_hs), .reset(osc_reset),
        .reg_addr(r_addr), .wr_data(r_wdata), .wr_strobe(r_wstrobe),
        .rd_data(r_rdata),
        .pll_lock_i(pll_lock), .fv_i(cmos_fv),
        .line_sent_toggle_i(line_sent_toggle), .sent_line_i(sent_line),
        .img_active_i(img_active),
        .overrun_i(lc_overrun),
        .line_ack_toggle_i(line_ack_toggle),
        .mode_image_o(mode_image), .line_value_o(line_value),
        .sweep_value_o(sweep_value),
        .line_req_toggle_o(line_req_toggle));
  ```
  (c) `line_capture_i` (lines 139–147) — replace with:
  ```verilog
    line_capture line_capture_i (
        .clk(clk_pixel_hs), .reset(pix_reset), .enable(mode_pix),
        .pixel_data(cmos_data), .frame_valid(cmos_fv), .line_valid(cmos_lv),
        .line_value_i(line_value), .sweep_value_i(sweep_value),
        .line_req_toggle_i(line_req_toggle),
        .line_ack_toggle_o(line_ack_toggle),
        .line_sent_toggle_o(line_sent_toggle), .sent_line_o(sent_line),
        .img_active_o(img_active), .overrun_o(lc_overrun),
        .serializer_done(ser_done),
        .word_o(lc_word), .serialize_active_o(lc_active));
  ```
  The Serializer mux (lines 149–156) needs **no change** — `lc_active` already covers the pusher via line_capture's `serialize_active_o`, and the word mux is internal to line_capture.

- [ ] **Step 4: Review-diff the wiring.** Compare `top.v`'s two edited instantiations line-by-line against `sweep_integration_tb.v`'s — the port lists must be congruent (this is the only verification top.v gets before Diamond).

- [ ] **Step 5: Commit.**
  ```powershell
  git add HistoFPGAFw/top.v test_projects/drip_scan/sweep_integration_tb.v
  git commit -m "feat: top-level sweep wiring + full-chain sweep integration TB" -m "sweep_value/lc_overrun between fpga_regs and line_capture; Serializer mux unchanged. TB proves histogram envelope bit-identical, legacy packets unchanged, byte-exact CRC'd pushes, I2C-visible overrun, clean exit. Refs #8"
  ```

---

### Task 7: full sim suite, Diamond handoff checklist, wrap-up

**Files:**
- Test: all six testbenches
- No RTL changes (fix-forward with a `fix:`/`test:` commit if any TB fails)

**Steps:**

- [ ] **Step 1: Run the complete suite** and record the output of each (all must end `ALL TESTS PASSED`):
  ```powershell
  .\test_projects\drip_scan\run.bat crc16_tb
  .\test_projects\drip_scan\run.bat raw10_pack_tb
  .\test_projects\drip_scan\run.bat image_pusher_tb
  .\test_projects\drip_scan\run.bat sweep_tb
  .\test_projects\drip_scan\run.bat sweep_integration_tb
  .\test_projects\i2c_line\run.bat fpga_regs_tb
  .\test_projects\i2c_line\run.bat i2c_slave_tb
  .\test_projects\i2c_line\run.bat line_capture_tb
  .\test_projects\i2c_line\run.bat integration_tb
  ```
  `git status` must show a clean tree afterwards (never add `test_projects/out/`).

- [ ] **Step 2: Push the branch.** `git push -u origin feature/8-drip-scan-single-frame`

- [ ] **Step 3: Comment results on issue #8:**
  ```powershell
  gh issue comment 8 -R OpenwaterHealth/openmotion-camera-fpga --body "FPGA RTL complete on feature/8-drip-scan-single-frame: crc16 (CCITT-FALSE, byte-identical to sensor-fw util_crc16 — proven with vectors computed from the utils.c table), raw10_pack gearbox, image_pusher (2408-B pushes, 602 words, phantom-done filtered), line_capture ping/pong sweep with overrun tripwire, fpga_regs v2 (VERSION 0x02, CTRL bit1 SWEEP, STATUS bit2), top.v wiring. All 9 Icarus TBs pass, incl. byte-exact sweep pushes with CRC and bit-identical histogram-envelope regression. Next: Diamond bitstream build (checklist in the plan), then sensor-fw/SDK companion issues."
  ```

- [ ] **Step 4: Diamond build checklist (USER performs in the Diamond IDE — the bitstream is not built by the agent).** Present this verbatim to Ethan:
  1. Open `HistoFPGAFw/HistoFPGAFw.ldf` in Lattice Diamond; in File List, add the three new sources to impl1: `HistoFPGAFw/crc16.v`, `HistoFPGAFw/raw10_pack.v`, `HistoFPGAFw/image_pusher.v`. Also check `HistoFPGAFw/synth.tcl` — if it enumerates sources explicitly, add the same three files there.
  2. No new IP generation needed: the second line buffer reuses the existing `ram_dp_s` SCUBA netlist (`HistoFPGAFw/ram_dp/ram_dp_s/ram_dp_s.v`).
  3. Synthesize → Map → PAR. In the map report verify EBR usage is **15/20** (9 histogram + 3 + 3 line RAMs). Verify timing closure on `clk_pixel_hs` (132.8 MHz) — the new critical candidates are the crc16 8-stage unroll and the raw10_pack 32-bit shifts; both are far shallower than the histogram adders, but confirm.
  4. Generate the bitstream and export the `.bin`.
  5. **Bitstream-size gotcha (sensor-fw CLAUDE.md):** `openmotion-sensor-fw/Core/Src/crosslink.c` hardcodes the bitstream size as `163489` bytes. CrossLink SRAM configuration images are fixed-size for a given device, so it should not change — but verify: `(Get-Item .\openmotion-camera-fpga.bin).Length` must equal `163489`. If it differs, file a sensor-fw issue and update the constant there **before anyone flashes**, or programming will misalign and corrupt adjacent flash.
  6. Publishing: sensor-fw pulls the **latest GitHub release** asset `openmotion-camera-fpga.bin` at CMake configure time. Do **not** publish this bitstream as a full release until hardware validation — use a pre-release tag (e.g. `X.Y.Z-rc.1`) per the qms-release process, and pin sensor-fw's `FPGA_BITSTREAM_URL` to that tag for bench testing.
  7. Hardware validation (spec §5 acceptance: MIPI-clock scope check, test-pattern bit-exact sweep, dark-decay measurement, link-speed matrix) belongs to the sensor-fw/SDK companion work — file those issues per spec §7 when starting them, linked back to #8.
  8. Board: the ticket moves to In review when the PR opens; it stays In review through any `rc`/`dev` pre-release validation, and reaches Done only on a full release or explicit validation sign-off.

**Verification summary (what proves what):**

| TB | Command | Proves |
|---|---|---|
| `crc16_tb` | `.\test_projects\drip_scan\run.bat crc16_tb` | RTL CRC == sensor-fw `util_crc16` (poly 0x1021 / init 0xFFFF / MSB-first / no XOR-out) via vectors from the actual C table |
| `raw10_pack_tb` | `...\run.bat raw10_pack_tb` | Pinned RAW10 bit layout for a hand-computed 8-px vector; simultaneous push+pop; clear |
| `image_pusher_tb` | `...\run.bat image_pusher_tb` | Byte-exact 2408-B push through real Serializer/SPI incl. pinned payload + CRC `0x3C22`; overrun header flag; re-push cleanliness |
| `sweep_tb` | `...\run.bat sweep_tb` | Start-line gating, push accounting, overrun tripwire drop+latch, flag propagation, latch clear on arm |
| `sweep_integration_tb` | `...\run.bat sweep_integration_tb` | Full chain from I2C to SPI bytes: byte-exact CRC'd pushes, constant frame_cnt, STATUS bit2 over I2C, histogram envelope bit-identical, clean exit |
| `fpga_regs_tb` / `i2c_slave_tb` / `line_capture_tb` / `integration_tb` | `.\test_projects\i2c_line\run.bat <name>` | Feature/5 regressions: v2 register map compatible; single-line mode and histogram envelope unchanged |