# Drip-Scan Sensor-FW Image Receive Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a data-paced image receive mode to the sensor firmware (opcode `OW_CAMERA_IMAGE_MODE` = 0x30) that forwards 2408-byte packed-RAW10 image lines from the camera FPGAs to the host over the HISTO USB endpoint with stream type 0x03, per the approved design spec `C:/Users/ethan/Projects/openmotion-camera-fpga/docs/superpowers/specs/2026-07-19-drip-scan-single-frame-design.md` §4.4.

**Architecture:** Image mode is a mutually-exclusive alternative to histogram streaming: entering it saves+zeroes `event_bits_enabled`, aborts in-flight histogram DMA on masked cameras, and arms repeating 2408-B one-shot DMA receptions into the cameras' *existing* receive buffers at a 12-byte offset, so the USB envelope (SOF/type/size/timestamp/SOH/cam_id/…/EOH/CRC/EOF, mirroring `send_histogram_data()` byte-for-byte in convention) is built in place around each line — zero copy, no new buffers, and the cam-1 SPI6/BDMA/SRAM4 constraint is inherited for free. Pacing is the data, not FSIN: the RxCplt callback forwards the line and a software-pended low-priority IRQ (borrowed LPTIM5 vector) re-arms the DMA immediately after the HAL driver's completion bookkeeping — deferral is *required* on the four USART links because the H7 HAL invokes `HAL_USART_RxCpltCallback` **before** setting the peripheral state back to READY. A main-loop service provides the ~2 ms per-camera line timeout (abort + re-arm + gap counter), and the command response carries the per-camera gap counters.

**Tech Stack:** C (STM32H743, STM32 HAL, arm-none-eabi-gcc + CMake/Ninja), pytest (host unit + HIL via the `omotion` SDK), `gh` CLI for tracking.

---

## Pinned wire facts (verified against the real sources — do not re-derive)

**CRC-16 (`util_crc16`, `Core/Src/utils.c:59-68`):** table-driven **CRC-16/CCITT-FALSE** — polynomial **0x1021**, init **0xFFFF**, MSB-first (`crc = (crc<<8) ^ crc16_tab[(crc>>8)^byte]`), **no** input/output reflection, **no** final XOR. The 256-entry `crc16_tab` (utils.c:16-49) is exactly the poly-0x1021 MSB-first table (first row `0x0000 0x1021 0x2042 0x3063 0x4084 0x50a5 0x60c6 0x70e7`). Verified test vectors computed from this exact algorithm/table:
- `b"123456789"` → **0x29B1** (the standard CCITT-FALSE check value)
- 2406-byte image-line body `[0xB6, 0x01, 0x2A, 0x00, 0x07, 0x00]` + 2400 zero bytes (line 42, flags 0, frame_cnt 7, all-black pixels) → **0x030C**

The FPGA computes the per-line CRC (bytes 2406-2407 of the 2408-B line) with this same algorithm; the MCU **forwards the line blind** and never validates it. The MCU *does* compute the USB **envelope** CRC with `util_crc16`, mirroring `send_histogram_data()` (camera_manager.c:1763): `util_crc16(packet, offset-1)` where `offset` is the byte count through the final EOH — i.e. the CRC covers **SOF through the last payload byte, excluding the EOH byte itself**. That quirk is load-bearing (the SDK's existing envelope verifier assumes it); reproduce it exactly.

**USB envelope for one image line (2424 B total), built in place in the camera's receive buffer:**

| Offset | Bytes | Content |
|---|---|---|
| 0 | 1 | `HISTO_SOF` 0xAA |
| 1 | 1 | `TYPE_IMAGE` 0x03 (SDK `OW_IMAGE_PACKET`, omotion/config.py:123) |
| 2-5 | 4 | total_size = 2424, little-endian u32 |
| 6-9 | 4 | timestamp = `get_timestamp_ms()` at line completion, LE u32 |
| 10 | 1 | `HISTO_SOH` 0xFF |
| 11 | 1 | cam_id (0-7) |
| 12-2419 | 2408 | the raw line as pushed by the FPGA (DMA'd directly here) |
| 2420 | 1 | `HISTO_EOH` 0xEE |
| 2421-2422 | 2 | `util_crc16(pkt, 2420)` — bytes 0..2419, LE (lo, hi) |
| 2423 | 1 | `HISTO_EOF` 0xDD |

**Size/queue math (spec §4.4 item 5):** 2424 ≤ `USB_HISTO_MAX_SIZE` 32837 (usbd_histo.h:23) ✓. 2424 ≤ each camera's receive slot `HISTOGRAM_DATA_SIZE` 4100 (frame_buffer slot / `spi6_buffer`) ✓, so in-place build fits. `USBD_HISTO_SendData` **copies** the packet before returning (direct path: memcpy into `histo_tx_buffer`, usbd_histo.c:481; queued path: memcpy into `histo_queue_buffers[slot]`, usbd_histo.c:249), so the receive buffer is reusable the moment the call returns — immediate re-arm is safe. Outstanding capacity = 1 in-flight + `HISTO_QUEUE_SIZE` 4 queued (usbd_histo.c:22) = **5 packets**. Sustained all-8 at the shipped link rate: 8 × 1.25 kHz × 2424 B ≈ 24.2 MB/s — inside HS bulk practical 30-40 MB/s. But the 8 cameras are FSIN-phase-locked, so up to 8 line completions can land within one 0.8 ms row period against 5 slots: transient `HISTO enqueue fail: queue full` drops are possible at all-8; each drop increments that camera's gap counter and the host retries via the FPGA sweep-start-line register. **The camera mask is the derating lever** (spec §4.4/§6) — ≤ 5 concurrent cameras can never oversubscribe the queue.

**Per-line ISR cost (honest estimate, bench-verified in Task 9):** envelope build (12 header + 4 trailer byte writes) + `util_crc16` over 2420 B (~4-8 cycles/B table-driven → ~20-40 µs @480 MHz; worse at Debug `-Og`) + SendData's 2424-B memcpy + (direct path only) the pre-existing `USBD_HISTO_SetTxBuffer` memset quirk — `memset(pTxHistoBuff, 0, USB_HISTO_MAX_SIZE/4)` zeroes 8209 **bytes** (the `/4` suggests the author meant words; the arg is bytes; usbd_histo.c:480 — **leave it untouched**, we do not modify the histogram path). Total ≈ 30-60 µs/line → at 8 × 1.25 kHz = 10 k lines/s that is 30-60% of one 480 MHz core, acceptable for a dedicated capture mode (histogram streaming is suspended) and derated by the camera mask if the bench disagrees.

**Link topology (init_camera_sensors, camera_manager.c:272-483):** cams 0/2/3/4 = USART2/USART3/USART6/USART1 (sync-slave, DMA); cams 1/5/6/7 = SPI6/SPI3/SPI2/SPI4 (slave, DMA). **Cam 1 is the special case:** SPI6's DMA is BDMA, which reaches only SRAM4, so its receive buffer is the dedicated `spi6_buffer` (`.sram4` section, camera_manager.c:121, wired at :474). Because image mode DMAs into `pRecieveHistoBuffer + 12`, cam 1 automatically lands in SRAM4 — no special code, but the timeout service must read BDMA's CNDTR, which `__HAL_DMA_GET_COUNTER` handles for both DMA streams and BDMA channels (stm32h7xx_hal_dma.h:1165-1167). D-cache is never enabled in this firmware (no `SCB_EnableDCache` anywhere; MPU_Config sets one non-cacheable background region, main.c:2182), so no cache maintenance is needed.

**Why the re-arm is deferred to a software IRQ, not done inside RxCplt:** the H7 HAL's USART DMA completion path (`USART_DMAReceiveCplt`, stm32h7xx_hal_usart.c ~2608) calls `HAL_USART_RxCpltCallback` **before** `husart->State = HAL_USART_STATE_READY` — an in-callback `HAL_USART_Receive_DMA` returns HAL_BUSY, and the driver would then stomp the state back to READY under a live DMA. SPI sets READY before its callback (stm32h7xx_hal_spi.c ~3003) and wouldn't need the deferral, but both link types share one path: RxCplt pends the unused **LPTIM5** interrupt vector (`LPTIM5_IRQn` = 141, present in startup_stm32h743vihx.s:289 with a weak default handler; the LPTIM5 peripheral is never clocked — the vector is borrowed as a software interrupt). At priority 7 — numerically below every camera link/DMA IRQ (`common.h:44-56`: DMA/SPI2 0, FSIN 2, SPI6/USARTs 4, SPI3/SPI4 6) — it tail-chains the instant the completing ISR returns, i.e. microseconds after the HAL sets READY. Against the ~0.11 ms gap between a line's drain (0.69 ms) and the next row (0.80 ms), that is effectively the spec's "immediately re-arm".

**Line timeout mechanism (spec item 4):** the codebase's existing pattern for periodic work is a main-loop service using `HAL_GetTick()` (`poll_mcu_temperature`, main.c:268-280; and `get_timestamp_ms`'s own warning at utils.c:106-112 says deadlines belong on `HAL_GetTick`, per #73). `camera_image_service()` follows it: each pass reads the camera's DMA remaining-count; a count that is *partial* (not 2408 = idle/no line in flight, not 0 = completed awaiting re-arm) and unchanged for ≥ 3 ticks (1 ms granularity ⇒ >2 ms real silence, the spec's ~2 ms) is a mid-line stall (USART byte-slip, spec §6) → abort + re-arm + `gap_count++`. Idle cameras between sweeps do not tick the counter — only stalled partial lines do.

---

### Task 1: File the tracking issue, board it, branch

**Files:** none (process only). Working repo: `C:/Users/ethan/Projects/openmotion-sensor-fw`.

- [ ] **Step 1: Create the GitHub issue**

```bash
gh issue create -R OpenwaterHealth/openmotion-sensor-fw \
  --title "Drip-scan image receive mode: OW_CAMERA_IMAGE_MODE (0x30) + data-paced 2408 B line forwarding" \
  --label feature \
  --body "Sensor-fw side of the drip-scan single-frame feature (companion to OpenwaterHealth/openmotion-camera-fpga#8; design spec lives in that repo at docs/superpowers/specs/2026-07-19-drip-scan-single-frame-design.md, section 4.4).

Scope:
- New OW_CAMERA subcommand OW_CAMERA_IMAGE_MODE = 0x30 (reserved byte = enable 0/1, data[0] = camera bitmask). Response carries per-camera gap counters.
- Image mode suspends histogram streaming (mutually exclusive), aborts in-flight histogram DMA, and arms repeating 2408-B one-shot DMA per masked camera into the existing receive buffers (cam 1 = spi6_buffer in SRAM4 for BDMA, unchanged).
- Data-paced receive: RxCplt builds the USB envelope in place and forwards on the HISTO endpoint with stream type 0x03 (OW_IMAGE_PACKET), then re-arms via a software-pended low-priority IRQ (H7 HAL USART sets READY only after the RxCplt callback).
- Per-camera ~2 ms line timeout serviced from the main loop: abort + re-arm + gap counter.
- Exit restores histogram arming; the next histogram frame is consumed and discarded firmware-side (FPGA first-frame-garbage caveat from the feature/5 line-readout work).
- Host pytest for wire-format constants + CRC table; HIL suite tests/test_image_mode_hil.py.

Laser per-pulse parameters are untouched; sensor retiming and FSIN-rate orchestration are host/SDK-side (separate companion issue in openmotion-sdk)."
```

Note the issue number `<N>` from the output — every later step uses it.

- [ ] **Step 2: Add it to Project 11 and set status In progress**

```bash
gh project item-add 11 --owner OpenwaterHealth --url https://github.com/OpenwaterHealth/openmotion-sensor-fw/issues/<N> --format json
```

Take the returned item `id`, then:

```bash
gh project item-edit --id <ITEM_ID> --project-id PVT_kwDOAif52c4BVgTu --field-id PVTSSF_lADOAif52c4BVgTuzhQ7qcU --single-select-option-id 47fc9ee4
```

- [ ] **Step 3: Comment the planned approach on the issue**

```bash
gh issue comment <N> -R OpenwaterHealth/openmotion-sensor-fw --body "Starting work on branch feature/<N>-drip-scan-image-mode (off next). Approach: image mode lives in camera_manager.c reusing the existing per-camera receive buffers (USB envelope built in place at a 12-byte offset, zero copy, SRAM4/BDMA constraint inherited); RxCplt forwards on the HISTO endpoint as stream type 0x03 and re-arms via a software-pended LPTIM5 IRQ at priority 7 (required because the H7 HAL USART driver sets State=READY only AFTER the RxCplt callback, so an in-callback re-arm is rejected); ~2 ms line timeout from a HAL_GetTick main-loop service tracking DMA NDTR/CNDTR progress; OW_CAMERA_IMAGE_MODE=0x30 handler returns per-camera gap counters. Implementation plan committed on the branch."
```

- [ ] **Step 4: Branch off next**

```bash
cd C:/Users/ethan/Projects/openmotion-sensor-fw
git fetch origin
git checkout -b feature/<N>-drip-scan-image-mode origin/next
```

- [ ] **Step 5: Verify the toolchain works before touching code**

```powershell
cmake --preset Debug
cmake --build build/Debug
```

Expected: build completes, `build/Debug/motion-sensor-fw.elf` produced. (Configure downloads the FPGA bitstream from GitHub — if offline, pre-place `fpga/openmotion-camera-fpga.bin` first, per repo CLAUDE.md.)

---

### Task 2: Failing host test that pins the wire format

**Files:**
- Test: `tests/test_image_packet_format.py` (create)

This test parses the real firmware sources (no compilation, runs anywhere). It proves two things: (a) the pinned image-mode constants exist in the headers with exactly the cross-plan values the FPGA and SDK sides depend on, and the 2424-B envelope fits both the USB transfer cap and the in-place receive slot; (b) the `crc16_tab` in utils.c is *exactly* the CRC-16/CCITT-FALSE table and the documented test vectors hold — the executable contract for the FPGA's line CRC and the SDK's verifier.

- [ ] **Step 1: Write the test file**

```python
"""Off-bench checks pinning the drip-scan image-mode wire format.

These parse the REAL firmware sources (no compilation) and fail if constants
the SDK/FPGA sides depend on ever drift:

* test_image_line_and_packet_constants -- IMAGE_LINE_SIZE / TYPE_IMAGE exist
  in Core/Inc/common.h with the pinned values; the envelope offset macros
  exist in camera_manager.h; the 2424-B envelope fits one HISTO USB transfer
  (USB_HISTO_MAX_SIZE) and the in-place receive slot (HISTOGRAM_DATA_SIZE).
* test_crc16_table_is_ccitt_false -- the 256-entry crc16_tab in
  Core/Src/utils.c is exactly the CRC-16/CCITT-FALSE table (poly 0x1021,
  MSB-first) and util_crc16's algorithm (init 0xFFFF, no reflection, no final
  XOR) reproduces the documented vectors. The FPGA's per-line CRC and the
  SDK's envelope verifier must both match these byte-for-byte.

Run anywhere: pytest tests/test_image_packet_format.py -v
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
COMMON_H = ROOT / "Core" / "Inc" / "common.h"
CAMERA_MANAGER_H = ROOT / "Core" / "Inc" / "camera_manager.h"
USBD_HISTO_H = ROOT / "USB" / "Class" / "HISTO" / "Inc" / "usbd_histo.h"
UTILS_C = ROOT / "Core" / "Src" / "utils.c"


def _define(text, name):
    m = re.search(rf"#define\s+{name}\s+\(?\s*(0x[0-9A-Fa-f]+|\d+)", text)
    assert m, f"#define {name} not found"
    return int(m.group(1), 0)


def test_image_line_and_packet_constants():
    common = COMMON_H.read_text()
    cam_h = CAMERA_MANAGER_H.read_text()
    histo_h = USBD_HISTO_H.read_text()

    image_line_size = _define(common, "IMAGE_LINE_SIZE")
    type_image = _define(common, "TYPE_IMAGE")
    # 6-B line header + 2400-B packed RAW10 (4 px -> 5 B) + 2-B line CRC.
    assert image_line_size == 2408
    # Must equal the SDK's OW_IMAGE_PACKET (omotion/config.py).
    assert type_image == 0x03

    # Envelope math: SOF+type+size4 (6) + timestamp4 + SOH + cam_id = 12,
    # then the line, then EOH (1) + CRC16 (2) + EOF (1).
    line_offset = 6 + 4 + 2
    total = line_offset + image_line_size + 1 + 3
    assert total == 2424
    assert "IMAGE_PKT_LINE_OFFSET" in cam_h
    assert "IMAGE_PKT_TOTAL_SIZE" in cam_h

    usb_max = _define(histo_h, "USB_HISTO_MAX_SIZE")
    assert total <= usb_max, "image packet must fit one HISTO transfer"

    slot = _define(cam_h, "HISTOGRAM_DATA_SIZE")
    assert total <= slot, (
        "the envelope is built in place inside each camera's existing "
        "receive-buffer slot, so it must fit HISTOGRAM_DATA_SIZE")


def _parse_fw_crc_table():
    text = UTILS_C.read_text()
    m = re.search(r"crc16_tab\[256\]\s*=\s*\{(.*?)\};", text, re.S)
    assert m, "crc16_tab not found in utils.c"
    entries = [int(x, 16) for x in re.findall(r"0x[0-9A-Fa-f]{4}", m.group(1))]
    assert len(entries) == 256
    return entries


def _make_ccitt_table():
    table = []
    for i in range(256):
        crc = i << 8
        for _ in range(8):
            crc = ((crc << 1) ^ 0x1021) & 0xFFFF if crc & 0x8000 else (crc << 1) & 0xFFFF
        table.append(crc)
    return table


def _crc16(table, buf):
    crc = 0xFFFF
    for b in buf:
        crc = ((crc << 8) ^ table[((crc >> 8) ^ b) & 0xFF]) & 0xFFFF
    return crc


def test_crc16_table_is_ccitt_false():
    fw_table = _parse_fw_crc_table()
    assert fw_table == _make_ccitt_table(), (
        "utils.c crc16_tab is not the CRC-16/CCITT-FALSE (poly 0x1021) table")
    # Standard CRC-16/CCITT-FALSE check value.
    assert _crc16(fw_table, b"123456789") == 0x29B1
    # Image-line vector: header B6 01 2A 00 07 00 (line 42, flags 0,
    # frame_cnt 7) + 2400 zero pixel bytes = 2406 input bytes.
    line = bytes([0xB6, 0x01, 0x2A, 0x00, 0x07, 0x00]) + bytes(2400)
    assert _crc16(fw_table, line) == 0x030C
```

- [ ] **Step 2: Run it and verify the constants test fails (CRC test already passes — it documents existing code)**

Run: `pytest tests/test_image_packet_format.py -v`
Expected: `test_image_line_and_packet_constants` **FAILS** with `AssertionError: #define IMAGE_LINE_SIZE not found`; `test_crc16_table_is_ccitt_false` **PASSES**.

---

### Task 3: Wire constants

**Files:**
- Modify: `Core/Inc/common.h` (packet-length block ends at line 20; IRQ priorities block at lines 44-56; `MotionCameraCommands` enum at lines 146-168)
- Modify: `Core/Inc/camera_manager.h` (HISTO framing defines at lines 63-75)
- Test: `tests/test_image_packet_format.py` (from Task 2)

- [ ] **Step 1: Add the line-size / stream-type constants to common.h**

After line 20 (`#define USART_PACKET_LENGTH 4100`), insert:

```c
/* --- Drip-scan image mode (camera-fpga#8) ---------------------------------
 * One packed RAW10 image line as pushed by the FPGA in sweep mode:
 *   [0]=magic 0xB6, [1]=format version 0x01, [2]=line[7:0],
 *   [3]={flags[3:0],line[11:8]} (flag bit0 = overrun since sweep start),
 *   [4]=frame_cnt[7:0], [5]=reserved 0x00,
 *   [6..2405]=2400 B packed RAW10 (4 px -> 5 B, 40-bit LE groups, low byte
 *   first), [2406..2407]=CRC-16/CCITT-FALSE over bytes 0..2405 (same
 *   algorithm as util_crc16: poly 0x1021, init 0xFFFF, MSB-first).
 * The MCU forwards these 2408 bytes BLIND -- the host verifies the line CRC;
 * only the DMA length here depends on the layout. */
#define IMAGE_LINE_SIZE 2408
/* Stream type byte for image-line packets on the HISTO USB endpoint
 * (envelope byte[1]; TYPE_HISTO / TYPE_HISTO_CMP live in camera_manager.h).
 * Must equal the SDK's OW_IMAGE_PACKET (omotion/config.py). */
#define TYPE_IMAGE 0x03
```

- [ ] **Step 2: Add the re-arm IRQ priority to the priority block**

After line 56 (`#define USB_IRQ_PRIORITY 0`), insert:

```c
/* Drip-scan deferred DMA re-arm (software-pended LPTIM5 vector). MUST stay
 * numerically ABOVE every camera link/DMA priority so the pend taken inside
 * a RxCplt callback fires only after that ISR -- and the HAL driver's
 * completion bookkeeping, which on USART sets State=READY only AFTER the
 * callback -- has finished. */
#define IMAGE_REARM_IRQ_PRIORITY 7
```

- [ ] **Step 3: Add the opcode to the camera-command enum**

In `MotionCameraCommands` (common.h lines 146-168), after `OW_CAMERA_GET_TELEMETRY = 0x54,` insert:

```c
	OW_CAMERA_IMAGE_MODE = 0x30,  /* drip-scan (camera-fpga#8): reserved = enable 0/1,
	                               * data[0] = camera bitmask. Response = image_mode_resp_t.
	                               * (0x30 also appears as OW_IMU_INIT, but that lives in the
	                               * OW_IMU packet-type namespace -- dispatch is per type.) */
```

- [ ] **Step 4: Add the envelope offset macros to camera_manager.h**

After line 75 (`#define HISTO_CMP_UNCMP_CRC_SIZE 2`), insert:

```c
/* --- Drip-scan image mode (camera-fpga#8) ---------------------------------
 * USB envelope for one image line, built IN PLACE around the DMA'd line in
 * the camera's existing receive buffer:
 *   [0]=HISTO_SOF [1]=TYPE_IMAGE [2..5]=total_size LE [6..9]=timestamp LE
 *   [10]=HISTO_SOH [11]=cam_id [12..2419]=IMAGE_LINE_SIZE line bytes
 *   [2420]=HISTO_EOH [2421..2422]=CRC-16 LE [2423]=HISTO_EOF
 * Envelope CRC = util_crc16 over bytes [0..2419] -- mirrors
 * send_histogram_data(), which computes util_crc16(packet_buffer, offset-1),
 * i.e. SOF through the last payload byte EXCLUDING the final EOH. Quirk kept
 * deliberately so the SDK's existing envelope-CRC convention applies. */
#define IMAGE_PKT_LINE_OFFSET (HISTO_HEADER_SIZE + 4 + 2)                                  /* 12 */
#define IMAGE_PKT_TOTAL_SIZE  (IMAGE_PKT_LINE_OFFSET + IMAGE_LINE_SIZE + 1 + HISTO_TRAILER_SIZE) /* 2424 */
```

- [ ] **Step 5: Run the test and verify it passes**

Run: `pytest tests/test_image_packet_format.py -v`
Expected: both tests **PASS**.

- [ ] **Step 6: Verify the firmware still builds**

Run: `cmake --build build/Debug`
Expected: clean build, no warnings about the new macros.

- [ ] **Step 7: Commit**

```bash
git add Core/Inc/common.h Core/Inc/camera_manager.h tests/test_image_packet_format.py
git commit -m "feat: pin drip-scan image-mode wire constants + format tests (#<N>)"
```

---

### Task 4: Image-mode state machine (enter / exit / status / histogram-discard hook)

**Files:**
- Modify: `Core/Inc/camera_manager.h` (prototypes block, after line 137 `void power_off_all_cameras(void);`)
- Modify: `Core/Src/camera_manager.c` (new block after `abort_data_reception()`, which ends at line 2238; one insertion inside `send_data()` at lines 1566-1569)

- [ ] **Step 1: Add the response struct and prototypes to camera_manager.h**

After line 137 (`void power_off_all_cameras(void);`), insert:

```c
/* --- Drip-scan image mode (camera-fpga#8) --------------------------------- */
/* Wire response for OW_CAMERA_IMAGE_MODE. Fixed packed layout returned
 * verbatim (same convention as cam_diag_stats_t above) -- do not reorder
 * fields without an SDK-side parser change. */
typedef struct __attribute__((packed)) {
	uint8_t  active;                  /* 1 = image mode currently active */
	uint8_t  mask;                    /* camera bitmask in image mode (0 when inactive) */
	uint8_t  reserved[2];
	uint32_t gap_count[CAMERA_COUNT]; /* per-camera lost-line events since the last enter:
	                                   * line timeouts + USB send drops + link-error
	                                   * recoveries. The host retries missing lines via the
	                                   * FPGA sweep-start-line register. */
} image_mode_resp_t;                  /* 36 B */

_Bool camera_image_mode_enter(uint8_t mask);
_Bool camera_image_mode_exit(void);
bool  camera_image_mode_active(uint8_t cam_id); /* cam is in the active image mask */
bool  camera_image_mode_rx(uint8_t cam_id);     /* HAL RxCplt hook; true = consumed by image path */
void  camera_image_link_error(uint8_t cam_id);  /* HAL error-callback recovery while in image mode */
void  camera_image_rearm_service(void);         /* LPTIM5 software-IRQ body: deferred DMA re-arm */
void  camera_image_service(void);               /* main-loop line-timeout tick (~2 ms) */
void  camera_image_get_status(image_mode_resp_t *out);
```

(`camera_image_mode_rx`, `camera_image_link_error`, and `camera_image_rearm_service` are implemented in Task 5; declaring them now keeps the header change in one place. Nothing references them until Task 5, so the build stays clean.)

- [ ] **Step 2: Add the image-mode state + enter/exit/status to camera_manager.c**

Insert the following block immediately after the closing brace of `abort_data_reception()` (line 2238), before `enable_camera_stream()`:

```c
/* -------- BEGIN DRIP-SCAN IMAGE MODE (camera-fpga#8) -------- */
/* Data-paced full-frame line receive (design spec 4.4). While active:
 *  - Histogram streaming is SUSPENDED: event_bits_enabled is saved + zeroed,
 *    so the FSIN ISR's send path goes quiet (send_histogram_data() returns
 *    immediately when event_bits_enabled == 0). check_streaming() will close
 *    the host-visible scan out after its 150 ms timeout -- its "Scan
 *    finished" print shortly after image-mode entry is expected.
 *  - Each masked camera runs a repeating 2408-B one-shot DMA into its
 *    EXISTING receive buffer at offset IMAGE_PKT_LINE_OFFSET, so the USB
 *    envelope is built in place around the line (zero copy). The buffers
 *    already satisfy every DMA constraint -- cam 1 = spi6_buffer in SRAM4
 *    for BDMA; D-cache is never enabled in this firmware -- because they are
 *    the very buffers the histogram path DMAs into today.
 *  - Pacing is the DATA, not FSIN: the FPGA pushes a line whenever its sweep
 *    buffer fills. camera_image_mode_rx() (RxCplt context) forwards the line
 *    and pends the LPTIM5 software IRQ (IMAGE_REARM_IRQ_PRIORITY, below all
 *    camera link/DMA IRQs) which re-arms the DMA the instant the completing
 *    ISR returns. The deferral is REQUIRED for the four USART cameras: the
 *    H7 HAL calls HAL_USART_RxCpltCallback BEFORE setting State=READY
 *    (USART_DMAReceiveCplt, stm32h7xx_hal_usart.c), so an in-callback
 *    HAL_USART_Receive_DMA is rejected with HAL_BUSY and the driver would
 *    then stomp the state under a live DMA. SPI sets READY before its
 *    callback and would tolerate an inline re-arm, but both link types share
 *    the one deferred path.
 *  - camera_image_service() (main loop, HAL_GetTick) aborts + re-arms a
 *    camera whose PARTIAL line made no byte progress for >2 ms (USART
 *    byte-slip resync, spec risk table) and counts a gap.
 */
static volatile bool     image_mode_on = false;
static volatile uint8_t  image_mode_mask = 0x00;
static uint8_t           image_saved_event_enabled = 0x00;
static volatile uint8_t  image_rearm_pending = 0x00;
static volatile uint32_t image_gap_count[CAMERA_COUNT] = {0};
/* Line-timeout progress tracking (camera_image_service, main loop only). */
static uint32_t image_last_ndtr[CAMERA_COUNT];
static uint32_t image_last_progress_tick[CAMERA_COUNT];
/* Set on image-mode exit; send_data() consumes + discards the next histogram
 * frame: the FPGA's first post-sweep histogram integrates counts across the
 * whole image session (the existing feature/5 first-frame-garbage caveat),
 * so it must never reach the host as data. Hosts may keep their own discard
 * as belt-and-braces. */
static volatile bool     histo_discard_next = false;

#define IMAGE_LINE_TIMEOUT_MS 3u /* spec target ~2 ms; HAL_GetTick has 1 ms
                                  * granularity, so >=3 ticks guarantees more
                                  * than 2 ms of real mid-line silence */

bool camera_image_mode_active(uint8_t cam_id)
{
	return image_mode_on && ((image_mode_mask & (1u << cam_id)) != 0u);
}

/* Arm (or re-arm) one camera's 2408-B line DMA at the in-place envelope
 * offset. Returns true when a reception is armed after this call --
 * including the already-armed case, which happens when an error-callback
 * recovery re-armed the camera before the deferred LPTIM5 re-arm ran. */
static _Bool camera_image_arm(uint8_t cam_id)
{
	CameraDevice *cam = &cam_array[cam_id];
	uint8_t *dst = cam->pRecieveHistoBuffer + IMAGE_PKT_LINE_OFFSET;
	HAL_StatusTypeDef status;

	if (!image_mode_on) {
		return false;
	}
	if (!cam->useDma) {
		/* All 8 cameras are DMA (init_camera_sensors). IT-mode per-byte
		 * interrupts at ~3.5 MB/s would be ~1.4M IRQ/s -- unsupported. */
		return false;
	}
	if (cam->useUsart) {
		if (cam->pUart->State == HAL_USART_STATE_BUSY_RX ||
		    cam->pUart->State == HAL_USART_STATE_BUSY_TX_RX) {
			return true; /* already armed */
		}
		status = HAL_USART_Receive_DMA(cam->pUart, dst, IMAGE_LINE_SIZE);
	} else {
		if (cam->pSpi->State == HAL_SPI_STATE_BUSY_RX ||
		    cam->pSpi->State == HAL_SPI_STATE_BUSY_TX_RX) {
			return true; /* already armed */
		}
		status = HAL_SPI_Receive_DMA(cam->pSpi, dst, IMAGE_LINE_SIZE);
	}
	return status == HAL_OK;
}

_Bool camera_image_mode_enter(uint8_t mask)
{
	if (image_mode_on) {
		printf("Image mode already active\r\n");
		return false;
	}
	if (mask == 0u) {
		return false;
	}
	if ((logging_get_debug_flags() & DEBUG_FLAG_FAKE_DATA) != 0u) {
		printf("Image mode refused: DEBUG_FLAG_FAKE_DATA active\r\n");
		return false;
	}
	for (uint8_t i = 0; i < CAMERA_COUNT; i++) {
		if ((mask & (1u << i)) != 0u && !camera_request_is_valid(i)) {
			printf("Image mode refused: camera %d invalid\r\n", i + 1);
			return false;
		}
	}

	/* Suspend histogram streaming (see block comment). Non-masked cameras
	 * that were streaming keep their armed 4100-B DMA; it completes at most
	 * once more (nothing re-arms it while enables are zeroed) and is
	 * re-armed on exit. */
	__disable_irq();
	image_saved_event_enabled = event_bits_enabled;
	event_bits_enabled = 0x00;
	event_bits = 0x00;
	__enable_irq();

	/* Drop queued histogram frames so the host's image reader starts clean
	 * (same hygiene as the OW_CAMERA_STREAM enable path). */
	USBD_HISTO_FlushQueue("image-enter");

	/* Software re-arm IRQ: LPTIM5's vector is borrowed as a pure software
	 * interrupt (the LPTIM5 peripheral is never clocked); the handler in
	 * stm32h7xx_it.c calls camera_image_rearm_service(). */
	HAL_NVIC_SetPriority(LPTIM5_IRQn, IMAGE_REARM_IRQ_PRIORITY, 0);
	HAL_NVIC_EnableIRQ(LPTIM5_IRQn);

	uint32_t now = HAL_GetTick();
	for (uint8_t i = 0; i < CAMERA_COUNT; i++) {
		image_gap_count[i] = 0;
		image_last_ndtr[i] = IMAGE_LINE_SIZE;
		image_last_progress_tick[i] = now;
	}
	image_rearm_pending = 0x00;
	image_mode_mask = mask;
	image_mode_on = true; /* BEFORE arming, so RxCplt/error callbacks route image-side */

	_Bool ok = true;
	for (uint8_t i = 0; i < CAMERA_COUNT; i++) {
		if ((mask & (1u << i)) == 0u) {
			continue;
		}
		abort_data_reception(i); /* kill any in-flight 4100-B histogram DMA */
		memset((uint8_t *)cam_array[i].pRecieveHistoBuffer, 0, IMAGE_PKT_TOTAL_SIZE);
		if (!camera_image_arm(i)) {
			printf("Image mode: failed to arm camera %d\r\n", i + 1);
			ok = false;
		}
	}
	if (!ok) {
		camera_image_mode_exit();
		return false;
	}
	printf("Image mode ON mask=0x%02X\r\n", mask);
	return true;
}

_Bool camera_image_mode_exit(void)
{
	if (!image_mode_on) {
		return true; /* idempotent, like disable_camera_stream on a stopped camera --
		              * also lets the host re-read final gap counters via a second
		              * disable command */
	}
	uint8_t mask = image_mode_mask;
	uint8_t restore = image_saved_event_enabled;

	image_mode_on = false; /* stop RxCplt routing + deferred re-arms first */
	image_mode_mask = 0x00;
	image_rearm_pending = 0x00;

	for (uint8_t i = 0; i < CAMERA_COUNT; i++) {
		uint8_t bit = (uint8_t)(1u << i);
		if (((mask | restore) & bit) == 0u) {
			continue;
		}
		/* Masked cams: abort the image DMA. Previously-streaming cams: abort
		 * the stale histogram DMA left from suspension. */
		abort_data_reception(i);
		/* #172 hygiene, same as enable_camera_stream(): never leave stale
		 * bytes where the next scan's first frame could ship them. */
		if (cam_array[i].pRecieveHistoBuffer != NULL) {
			memset((uint8_t *)cam_array[i].pRecieveHistoBuffer, 0,
			       cam_array[i].useUsart ? USART_PACKET_LENGTH : SPI_PACKET_LENGTH);
		}
		if ((restore & bit) != 0u) {
			start_data_reception(i); /* restore the 4100-B histogram arming */
		}
	}

	__disable_irq();
	event_bits = 0x00;
	event_bits_enabled = restore;
	__enable_irq();
	image_saved_event_enabled = 0x00;
	if (restore != 0u) {
		histo_discard_next = true; /* consumed by send_data() */
	}
	/* Drop any image lines still queued so they can't bleed into the
	 * histogram stream (same convention as the scan-stop flush). The host
	 * exits image mode only after it has collected or given up on lines. */
	USBD_HISTO_FlushQueue("image-exit");
	printf("Image mode OFF\r\n");
	return true;
}

void camera_image_get_status(image_mode_resp_t *out)
{
	out->active = image_mode_on ? 1u : 0u;
	out->mask = image_mode_mask;
	out->reserved[0] = 0;
	out->reserved[1] = 0;
	for (uint8_t i = 0; i < CAMERA_COUNT; i++) {
		out->gap_count[i] = image_gap_count[i];
	}
}
/* -------- END DRIP-SCAN IMAGE MODE -------- */
```

- [ ] **Step 3: Add the post-exit discard hook in send_data()**

In `send_data()` (camera_manager.c), the current code at lines 1566-1569 reads:

```c
	// Check for camera failures before clearing event_bits
	check_camera_failures();
	
	bool success = false;
```

Change it to:

```c
	// Check for camera failures before clearing event_bits
	check_camera_failures();

	/* Drip-scan: the first histogram frame after image-mode exit integrates
	 * the whole image session (feature/5 first-frame-garbage caveat) --
	 * consume the event bits + re-arm WITHOUT sending, exactly like the #75
	 * stall repro's suppress path. One frame only. */
	if (histo_discard_next) {
		histo_discard_next = false;
		return histo_stall_suppress_frame();
	}

	bool success = false;
```

(`histo_stall_suppress_frame()` is the existing static at camera_manager.c:1505 — it consumes `event_bits & event_bits_enabled`, re-arms each ready camera via `start_data_reception`, and returns true. Exactly the semantics a discarded frame needs.)

- [ ] **Step 4: Build**

Run: `cmake --build build/Debug`
Expected: clean build. (Prototypes for the Task-5 functions are declared but not yet defined — that is fine, nothing references them yet.)

- [ ] **Step 5: Commit**

```bash
git add Core/Inc/camera_manager.h Core/Src/camera_manager.c
git commit -m "feat: drip-scan image-mode state machine - enter/exit/status + post-exit histogram discard (#<N>)"
```

---

### Task 5: Data-paced receive path — envelope build, USB forward, deferred re-arm, error routing

**Files:**
- Modify: `Core/Src/camera_manager.c` (append to the image-mode block from Task 4, before the `END DRIP-SCAN` marker)
- Modify: `Core/Src/main.c` (RxCplt callbacks at lines 2002-2041; error-callback recovery blocks at lines 1875-1880 (USART) and 1983-1988 (SPI))
- Modify: `Core/Src/stm32h7xx_it.c` (includes block near line 21; new handler at end of file)

- [ ] **Step 1: Add the RxCplt forward + link-error recovery + re-arm service to camera_manager.c**

Insert inside the image-mode block from Task 4, immediately after `camera_image_get_status()` and before the `/* -------- END DRIP-SCAN IMAGE MODE -------- */` marker:

```c
/* Called from HAL_SPI_RxCpltCallback / HAL_USART_RxCpltCallback (main.c).
 * Returns true when the completion belonged to the image path (the caller
 * must then NOT set the histogram event bit). Builds the 2424-B USB envelope
 * IN PLACE around the just-DMA'd line and queues it on the HISTO endpoint,
 * then pends the LPTIM5 software IRQ to re-arm this camera's DMA.
 *
 * Buffer reuse is safe immediately: USBD_HISTO_SendData COPIES the packet
 * before returning (memcpy into histo_tx_buffer on the direct path /
 * histo_queue_buffers[slot] on the queued path -- usbd_histo.c).
 *
 * ISR budget: header/trailer writes + util_crc16 over 2420 B (~20-40 us at
 * 480 MHz) + SendData's 2424-B copy. No printf (hot path).
 *
 * NOTE: DEBUG_FLAG_HISTO_THROTTLE / DEBUG_FLAG_HISTO_SPARSE act inside
 * USBD_HISTO_SendData and would silently swallow image lines -- do not run
 * image mode with those flags set (documented in CLAUDE.md). */
bool camera_image_mode_rx(uint8_t cam_id)
{
	if (!camera_image_mode_active(cam_id)) {
		return false;
	}
	CameraDevice *cam = &cam_array[cam_id];
	uint8_t *pkt = cam->pRecieveHistoBuffer;
	uint32_t ts = get_timestamp_ms(); /* same TIM5 timebase as histogram frames */
	int offset = 0;

	pkt[offset++] = HISTO_SOF;
	pkt[offset++] = TYPE_IMAGE;
	pkt[offset++] = (uint8_t)(IMAGE_PKT_TOTAL_SIZE & 0xFF);
	pkt[offset++] = (uint8_t)((IMAGE_PKT_TOTAL_SIZE >> 8) & 0xFF);
	pkt[offset++] = (uint8_t)((IMAGE_PKT_TOTAL_SIZE >> 16) & 0xFF);
	pkt[offset++] = (uint8_t)((IMAGE_PKT_TOTAL_SIZE >> 24) & 0xFF);
	pkt[offset++] = (uint8_t)(ts & 0xFF);
	pkt[offset++] = (uint8_t)((ts >> 8) & 0xFF);
	pkt[offset++] = (uint8_t)((ts >> 16) & 0xFF);
	pkt[offset++] = (uint8_t)((ts >> 24) & 0xFF);
	pkt[offset++] = HISTO_SOH;
	pkt[offset++] = cam_id;
	/* pkt[12..2419] = the 2408-B line, already DMA'd in place. */
	offset += IMAGE_LINE_SIZE;
	pkt[offset++] = HISTO_EOH;
	/* Same CRC span quirk as send_histogram_data(): SOF through the last
	 * payload byte, EXCLUDING the EOH just written (offset-1 bytes). */
	uint16_t crc = util_crc16(pkt, offset - 1);
	pkt[offset++] = (uint8_t)(crc & 0xFF);
	pkt[offset++] = (uint8_t)((crc >> 8) & 0xFF);
	pkt[offset++] = HISTO_EOF;

	if (USBD_HISTO_SendData(&hUsbDeviceHS, pkt, IMAGE_PKT_TOTAL_SIZE, 0) != USBD_OK) {
		image_gap_count[cam_id]++; /* dropped line -- host sees the gap, retries the sweep */
	}

	image_rearm_pending |= (uint8_t)(1u << cam_id);
	NVIC_SetPendingIRQ(LPTIM5_IRQn); /* re-arm fires after this ISR returns */
	return true;
}

/* HAL error-callback recovery while in image mode (main.c routes here
 * instead of the histogram abort+start pair): recover to a fresh 2408-B line
 * reception and count the lost line. Runs in ISR context -- the same context
 * the histogram path already runs abort+restart from. */
void camera_image_link_error(uint8_t cam_id)
{
	image_gap_count[cam_id]++;
	abort_data_reception(cam_id);
	(void)camera_image_arm(cam_id);
}

/* Body of the LPTIM5 software IRQ (stm32h7xx_it.c). Drains the pending mask
 * in a loop so a camera pended DURING this service is not lost. */
void camera_image_rearm_service(void)
{
	for (;;) {
		uint8_t pending;
		__disable_irq();
		pending = image_rearm_pending;
		image_rearm_pending = 0;
		__enable_irq();
		if (pending == 0u || !image_mode_on) {
			return;
		}
		for (uint8_t i = 0; i < CAMERA_COUNT; i++) {
			if ((pending & (1u << i)) != 0u) {
				if (!camera_image_arm(i)) {
					image_gap_count[i]++; /* arm failed; timeout service retries */
				}
			}
		}
	}
}
```

- [ ] **Step 2: Route the RxCplt callbacks in main.c**

Replace the two callbacks at main.c lines 2001-2041 (currently a per-instance `set_event_bit_atomic(BIT_n)` chain) with the following. The instance→camera mapping is identical to today's (`BIT_n == 1 << n`), so histogram-mode behavior is byte-identical; the only new behavior is the image-mode branch:

```c
// Interrupt handler for SPI reception
void HAL_SPI_RxCpltCallback(SPI_HandleTypeDef *hspi)
{
  int8_t cam_id = -1;
  if (hspi->Instance == SPI2)      { cam_id = 6; }
  else if (hspi->Instance == SPI3) { cam_id = 5; }
  else if (hspi->Instance == SPI4) { cam_id = 7; }
  else if (hspi->Instance == SPI6) { cam_id = 1; }
  if (cam_id < 0) { return; }
  /* Drip-scan image mode: this completion is a 2408-B image line, not a
   * histogram frame -- forwarded + re-armed by the image path. */
  if (camera_image_mode_rx((uint8_t)cam_id)) { return; }
  set_event_bit_atomic(1u << cam_id);
}

void HAL_USART_RxCpltCallback(USART_HandleTypeDef *husart)
{
  int8_t cam_id = -1;
  if (husart->Instance == USART1)      { cam_id = 4; }
  else if (husart->Instance == USART2) { cam_id = 0; }
  else if (husart->Instance == USART3) { cam_id = 2; }
  else if (husart->Instance == USART6) { cam_id = 3; }
  if (cam_id < 0) { return; }
  if (camera_image_mode_rx((uint8_t)cam_id)) { return; }
  set_event_bit_atomic(1u << cam_id);
}
```

- [ ] **Step 3: Route the error callbacks in main.c**

In `HAL_USART_ErrorCallback` (main.c), the recovery block at lines 1875-1880 currently reads:

```c
  if (cam_id >= 0)
  {
    abort_data_reception((uint8_t)cam_id);
    start_data_reception((uint8_t)cam_id);
    return;
  }
```

Change it to:

```c
  if (cam_id >= 0)
  {
    if (camera_image_mode_active((uint8_t)cam_id)) {
      /* Image mode: recover to a fresh 2408-B line and count the loss --
       * re-arming the 4100-B histogram reception here would wedge the
       * line stream. */
      camera_image_link_error((uint8_t)cam_id);
    } else {
      abort_data_reception((uint8_t)cam_id);
      start_data_reception((uint8_t)cam_id);
    }
    return;
  }
```

Make the **identical** change to the same-shaped block in `HAL_SPI_ErrorCallback` at lines 1983-1988.

- [ ] **Step 4: Add the LPTIM5 handler to stm32h7xx_it.c**

In the `/* USER CODE BEGIN Includes */` block (stm32h7xx_it.c near line 24), add:

```c
#include "camera_manager.h"
```

At the end of the file, inside the final `/* USER CODE BEGIN 1 */ ... /* USER CODE END 1 */` region (add the markers if absent), add:

```c
/* Drip-scan image mode (camera-fpga#8): software-pended re-arm IRQ. The
 * LPTIM5 peripheral is never used or clocked -- its vector is borrowed as a
 * low-priority (IMAGE_REARM_IRQ_PRIORITY) software interrupt, pended from
 * the camera RxCplt callbacks so the DMA re-arm runs immediately AFTER the
 * HAL driver finishes its completion bookkeeping (required on USART, whose
 * driver sets State=READY only after the RxCplt callback). Nothing to clear:
 * a software pend auto-clears on entry. */
void LPTIM5_IRQHandler(void)
{
  camera_image_rearm_service();
}
```

(The startup file `Core/Startup/startup_stm32h743vihx.s:289,734` declares `LPTIM5_IRQHandler` weak → this definition overrides `Default_Handler`.)

- [ ] **Step 5: Build**

Run: `cmake --build build/Debug`
Expected: clean build, `motion-sensor-fw.elf` linked.

- [ ] **Step 6: Commit**

```bash
git add Core/Src/camera_manager.c Core/Src/main.c Core/Src/stm32h7xx_it.c
git commit -m "feat: data-paced image-line receive - in-place USB envelope, type 0x03 forward, deferred DMA re-arm via LPTIM5 soft IRQ (#<N>)"
```

---

### Task 6: Per-camera line timeout service

**Files:**
- Modify: `Core/Src/camera_manager.c` (append inside the image-mode block, after `camera_image_rearm_service()`)
- Modify: `Core/Src/main.c` (main loop, line 474)

- [ ] **Step 1: Implement camera_image_service() in camera_manager.c**

Insert after `camera_image_rearm_service()`, still before the `END DRIP-SCAN` marker:

```c
/* Main-loop line-timeout tick (wired next to camera_i2c_service() in
 * main.c). Deadline clock is HAL_GetTick(), NOT get_timestamp_ms() -- the
 * TIM5 timestamp wraps at ~11.93 h and is documented (utils.c, #73) as
 * unsafe for deadlines.
 *
 * Progress probe: the DMA remaining-transfer count, via
 * __HAL_DMA_GET_COUNTER -- which reads NDTR for DMA streams and CNDTR for
 * BDMA channels (stm32h7xx_hal_dma.h), so cam 1's SPI6/BDMA path needs no
 * special case. Semantics:
 *   remaining == IMAGE_LINE_SIZE  -> no line in flight (idle between sweeps
 *                                    / FPGA not pushing) -- NOT a fault.
 *   remaining == 0                -> transfer complete, callback/re-arm
 *                                    pending -- NOT a fault.
 *   0 < remaining < IMAGE_LINE_SIZE, unchanged >2 ms -> a stalled PARTIAL
 *     line (mid-line byte slip on a USART link, spec risk table): abort,
 *     re-arm, count a gap. The host retries via the sweep start line. */
void camera_image_service(void)
{
	if (!image_mode_on) {
		return;
	}
	uint32_t now = HAL_GetTick();
	for (uint8_t i = 0; i < CAMERA_COUNT; i++) {
		if ((image_mode_mask & (1u << i)) == 0u) {
			continue;
		}
		CameraDevice *cam = &cam_array[i];
		DMA_HandleTypeDef *hdma = cam->useUsart ? cam->pUart->hdmarx : cam->pSpi->hdmarx;
		if (hdma == NULL) {
			continue;
		}
		uint32_t remaining = __HAL_DMA_GET_COUNTER(hdma);
		if (remaining != image_last_ndtr[i]) {
			image_last_ndtr[i] = remaining;
			image_last_progress_tick[i] = now;
			continue;
		}
		if (remaining == IMAGE_LINE_SIZE || remaining == 0u) {
			image_last_progress_tick[i] = now;
			continue;
		}
		if ((now - image_last_progress_tick[i]) >= IMAGE_LINE_TIMEOUT_MS) {
			image_gap_count[i]++;
			abort_data_reception(i);
			(void)camera_image_arm(i); /* on failure the next pass retries */
			image_last_ndtr[i] = IMAGE_LINE_SIZE;
			image_last_progress_tick[i] = now;
		}
	}
}
```

- [ ] **Step 2: Wire it into the main loop**

In main.c, line 474 currently reads:

```c
    camera_i2c_service();    /* Camera-bus work deferred from the frame ISRs (temp poll, mux disables) */
```

Change to:

```c
    camera_i2c_service();    /* Camera-bus work deferred from the frame ISRs (temp poll, mux disables) */
    camera_image_service();  /* Drip-scan: per-camera image line timeout (no-op unless image mode is on) */
```

- [ ] **Step 3: Build**

Run: `cmake --build build/Debug`
Expected: clean build.

- [ ] **Step 4: Commit**

```bash
git add Core/Src/camera_manager.c Core/Src/main.c
git commit -m "feat: image-mode line timeout - main-loop DMA progress watchdog, abort/re-arm + gap counter (#<N>)"
```

---

### Task 7: OW_CAMERA_IMAGE_MODE command handler

**Files:**
- Modify: `Core/Src/if_commands.c` (file-scope statics near line 38; `process_camera_commands()` — insert the case between the `OW_CAMERA_SET_TESTPATTERN` block ending at line 839 and `case OW_CAMERA_OFF:` at line 840)

- [ ] **Step 1: Add the response static**

After line 38 (`static uint8_t camera_status[8] = {0};`), add:

```c
static image_mode_resp_t image_mode_resp; /* OW_CAMERA_IMAGE_MODE reply buffer */
```

(`image_mode_resp_t` comes in via `main.h` → `camera_manager.h`, already included.)

- [ ] **Step 2: Add the case to process_camera_commands()**

Between the `break;` that ends `case OW_CAMERA_SET_TESTPATTERN:` (line 839) and `case OW_CAMERA_OFF:` (line 840), insert:

```c
	case OW_CAMERA_IMAGE_MODE:
		/* Drip-scan (camera-fpga#8): reserved = enable 0/1, data[0] = camera
		 * bitmask (enable only). Host sequencing: enable cameras/streaming
		 * first if a live sweep is wanted, enable image mode, THEN put the
		 * FPGA into sweep mode via I2C (0x5A CTRL); reverse order on the way
		 * out. Response is image_mode_resp_t either way -- the disable reply
		 * carries the final per-camera gap tally, and a repeated disable is
		 * an idempotent success that re-reads it. */
		VERBOSE_CMD("[CMD] OW_CAMERA_IMAGE_MODE reserved=%u len=%u\r\n",
		            cmd.reserved, (unsigned)cmd.data_len);
		uartResp->command = OW_CAMERA_IMAGE_MODE;
		uartResp->packet_type = OW_RESP;
		if (cmd.reserved == 1) {
			if (cmd.data_len != 1 || cmd.data[0] == 0) {
				VERBOSE_CMD("Invalid image mode payload\r\n");
				uartResp->packet_type = OW_ERROR;
				break;
			}
			if (!camera_image_mode_enter(cmd.data[0])) {
				uartResp->packet_type = OW_ERROR;
			}
		} else {
			if (!camera_image_mode_exit()) {
				uartResp->packet_type = OW_ERROR;
			}
		}
		camera_image_get_status(&image_mode_resp);
		uartResp->data_len = sizeof(image_mode_resp);
		uartResp->data = (uint8_t *)&image_mode_resp;
		break;
```

- [ ] **Step 3: Build**

Run: `cmake --build build/Debug`
Expected: clean build.

- [ ] **Step 4: Re-run the host tests as a regression check**

Run: `pytest tests/ -v`
Expected: `test_image_packet_format.py` (2 passed), `test_deploy_helpers.py` / `test_serial_record.py` pass, all `*_hil.py` **skip** (off-bench).

- [ ] **Step 5: Commit**

```bash
git add Core/Src/if_commands.c
git commit -m "feat: OW_CAMERA_IMAGE_MODE (0x30) handler with per-camera gap counters in the response (#<N>)"
```

---

### Task 8: HIL test suite

**Files:**
- Test: `tests/test_image_mode_hil.py` (create)

Two tests. **Test 1** needs only this firmware (any FPGA bitstream): it proves mid-stream suspend, TYPE_IMAGE forwarding, the line timeout, exit, and histogram resume. The trick making it FPGA-independent: with the FPGA still in histogram mode pushing 4100-B envelopes at 40 Hz, the 2408-B image DMA chops each envelope into one full "line" plus a 1692-B partial that stalls at the inter-frame gap — so the host sees real TYPE_IMAGE packets **and** the timeout mechanism fires ~40×/s, both observable. **Test 2** is the line-rate smoke with the FPGA genuinely in sweep mode; it skips unless the camera FPGA answers at I2C 0x5A with VERSION ≥ 0x02 (the feature/8 register map).

- [ ] **Step 1: Write the test file**

```python
"""HIL: drip-scan image receive mode (OW_CAMERA_IMAGE_MODE = 0x30).

test_image_mode_enter_exit_and_histogram_resume -- runs against ANY FPGA
bitstream. Starts a normal 2-camera histogram scan, enters image mode
mid-stream (firmware must suspend histogram streaming and re-arm 2408-B
receives), verifies TYPE_IMAGE (0x03) envelopes arrive on the HISTO endpoint
(the FPGA, still in histogram mode, pushes 4100-B envelopes that the 2408-B
DMA chops into one full 'line' + a stalled partial -- which also exercises
the ~2 ms line timeout: gap counters must grow), exits image mode, and
verifies histogram frames resume WITHOUT the host re-enabling anything.

test_image_line_stream_smoke -- line-rate smoke with the FPGA in sweep mode.
Requires the feature/8 camera-FPGA bitstream (register map v2 at I2C 0x5A,
VERSION >= 0x02); skips otherwise. No sensor retiming (that is SDK-side
orchestration): with production HTS the FPGA overruns and pushes lines at
drain rate, which is exactly what a transport smoke needs. Validates the
2424-B envelope framing, the envelope CRC (util_crc16 convention: bytes
0..2419, i.e. excluding EOH), and the inner line magic/version.

Camera mask 0x03 = cam 0 (USART2 link) + cam 1 (SPI6 link via BDMA/SRAM4)
-- one camera from each link family, including the special-cased one.

Deploy first (firmware-only flash is enough for test 1):

    python scripts/deploy.py --device left --fw-only --no-confirm `
      --power-cycle-cmd "python C:\\Users\\ethan\\Projects\\openmotion-bloodflow-app\\tests\\shelly.py cycle"

Run on the bench:

    $env:OPENMOTION_HIL = "1"
    $env:OW_SENSOR_SIDE = "left"
    $env:OPENMOTION_POWER_CYCLE_CMD = "python C:\\Users\\ethan\\Projects\\openmotion-bloodflow-app\\tests\\shelly.py cycle"
    pytest tests/test_image_mode_hil.py -v -s

Power-cycle the sensor between streaming HIL runs (repo CLAUDE.md: wedge
risk when chaining streaming tests).
"""
import os
import queue
import struct
import subprocess
import threading
import time

import pytest

requires_bench = pytest.mark.skipif(
    os.environ.get("OPENMOTION_HIL") != "1",
    reason="hardware-in-the-loop test; set OPENMOTION_HIL=1 on the bench",
)

CONNECT_TIMEOUT_S = 15.0
CAM_MASK = 0x03          # cam 0 = USART2, cam 1 = SPI6/BDMA/SRAM4
CAMS = [0, 1]

OW_CAMERA_IMAGE_MODE = 0x30   # firmware Core/Inc/common.h (SDK constant lands with the companion SDK feature)
IMAGE_PKT = 2424              # envelope size, camera_manager.h IMAGE_PKT_TOTAL_SIZE
RESP_LEN = 36                 # image_mode_resp_t

# One 2-camera histogram frame: 10-B header + 2*(SOH+cam+4096+temp4+EOH) + CRC2+EOF
HISTO_FRAME_BYTES = 10 + 2 * (1 + 1 + 4096 + 4 + 1) + 3
PHASE_SECONDS = 3.0
MIN_HISTO_BYTES = 25 * HISTO_FRAME_BYTES   # ~120 frames nominal; 25 tolerates USB hiccups

# FPGA register map (feature/5, extended by feature/8 -- see camera-fpga
# tools/full_frame_capture/fpga_link.py)
FPGA_ADDR = 0x5A
REG_VERSION, REG_CTRL, REG_LINE_L, REG_LINE_H = 0x01, 0x03, 0x04, 0x05


def _make_crc_table():
    table = []
    for i in range(256):
        crc = i << 8
        for _ in range(8):
            crc = ((crc << 1) ^ 0x1021) & 0xFFFF if crc & 0x8000 else (crc << 1) & 0xFFFF
        table.append(crc)
    return table


_CRC_TABLE = _make_crc_table()


def _crc16(buf):
    crc = 0xFFFF
    for b in buf:
        crc = ((crc << 8) ^ _CRC_TABLE[((crc >> 8) ^ b) & 0xFF]) & 0xFFFF
    return crc


def _extract_image_packets(buf: bytes):
    """Scan a raw byte stream for well-formed 2424-B TYPE_IMAGE envelopes."""
    pkts, i = [], 0
    while True:
        j = buf.find(b"\xaa\x03", i)
        if j < 0 or j + IMAGE_PKT > len(buf):
            break
        pkt = buf[j:j + IMAGE_PKT]
        size = int.from_bytes(pkt[2:6], "little")
        if size == IMAGE_PKT and pkt[10] == 0xFF and pkt[2420] == 0xEE and pkt[2423] == 0xDD:
            pkts.append(pkt)
            i = j + IMAGE_PKT
        else:
            i = j + 1
    return pkts


def _envelope_crc_ok(pkt: bytes) -> bool:
    # Firmware convention (mirrors send_histogram_data): CRC over bytes
    # 0..2419 -- SOF through last payload byte, EXCLUDING the EOH.
    return _crc16(pkt[:2420]) == (pkt[2421] | (pkt[2422] << 8))


# Keep MotionInterface instances alive for the process lifetime (Win32
# hotplug wndproc thunk issue -- see test_histo_wedge_recovery_hil.py).
_INTERFACE_KEEPALIVE = []


@pytest.fixture
def sensor():
    from omotion import MotionInterface

    cycle_cmd = os.environ.get("OPENMOTION_POWER_CYCLE_CMD")
    if cycle_cmd:
        subprocess.run(cycle_cmd, shell=True, check=True, timeout=60)
        time.sleep(8.0)  # re-enumeration settle

    side = os.environ.get("OW_SENSOR_SIDE", "left")
    interface = MotionInterface()
    _INTERFACE_KEEPALIVE.append(interface)
    interface.start(wait=False)
    handle = interface.left if side == "left" else interface.right
    deadline = time.monotonic() + CONNECT_TIMEOUT_S
    while time.monotonic() < deadline and not handle.is_connected():
        time.sleep(0.2)
    if not handle.is_connected():
        interface.stop()
        pytest.fail(f"{side} sensor not reachable in {CONNECT_TIMEOUT_S:.0f}s")
    yield handle
    try:
        _image_mode(handle, enable=False)          # never leave image mode on
        handle.disable_aggregator_fsin()
        handle.disable_camera(CAM_MASK)
        handle.uart.histo.stop_streaming()
        handle.uart.histo.drain_final(IMAGE_PKT)
        handle.disable_camera_power(CAM_MASK)
    except Exception:
        pass
    interface.stop()


def _bring_up(sensor):
    """Power -> FPGA -> configure, the production bring-up sequence."""
    assert sensor.enable_camera_power(CAM_MASK) is True
    time.sleep(0.5)
    assert sensor.program_fpga(camera_position=CAM_MASK, manual_process=False) is True
    time.sleep(0.1)
    assert sensor.camera_configure_registers(CAM_MASK) is True


def _image_mode(sensor, enable, mask=0):
    """Send OW_CAMERA_IMAGE_MODE; return (active, mask, gap_counts)."""
    from omotion.config import OW_CAMERA
    from omotion.MotionSensor import _ERROR_TYPES

    r = sensor._send(
        packetType=OW_CAMERA, command=OW_CAMERA_IMAGE_MODE,
        reserved=1 if enable else 0,
        data=bytes([mask]) if enable else None)
    assert r is not None and r.packetType not in _ERROR_TYPES, (
        f"OW_CAMERA_IMAGE_MODE {'enable' if enable else 'disable'} failed")
    assert r.data_len == RESP_LEN, f"unexpected response length {r.data_len}"
    payload = bytes(r.data[:RESP_LEN])
    active, rmask = payload[0], payload[1]
    gaps = struct.unpack("<8I", payload[4:36])
    return active, rmask, gaps


class _ByteCollector:
    """Accumulate raw HISTO-endpoint bytes off the stream queue."""

    def __init__(self, histo, expected_size):
        self._histo = histo
        self._expected = expected_size
        self._queue = queue.Queue(maxsize=1024)
        self._stop = threading.Event()
        self.buf = bytearray()
        self._thread = threading.Thread(target=self._drain, daemon=True)

    def _drain(self):
        while not self._stop.is_set():
            try:
                chunk = self._queue.get(timeout=0.2)
            except queue.Empty:
                continue
            if chunk:
                self.buf.extend(bytes(chunk))

    def start(self):
        self._thread.start()
        self._histo.start_streaming(self._queue, expected_size=self._expected)

    def stop(self) -> bytes:
        self._histo.stop_streaming()
        self._stop.set()
        self._thread.join(timeout=2.0)
        return bytes(self.buf)


def _fpga_read(sensor, cam, reg):
    val = sensor.i2c_read_register(FPGA_ADDR, reg, read_len=1,
                                   reg_addr_size=1, mux_channel=cam)
    if val is False or not val:
        return None
    return val[0]


def _fpga_write(sensor, cam, reg, value):
    # feature/5 write trick: 16-bit 'register address' = [reg, value].
    val = sensor.i2c_read_register(FPGA_ADDR, ((reg & 0xFF) << 8) | (value & 0xFF),
                                   read_len=1, reg_addr_size=2, mux_channel=cam)
    assert val is not False and val, f"cam{cam}: FPGA reg 0x{reg:02X} write failed"


@requires_bench
def test_image_mode_enter_exit_and_histogram_resume(sensor):
    assert sensor.ping() is True
    _bring_up(sensor)
    histo = sensor.uart.histo
    histo.flush_stale_data(HISTO_FRAME_BYTES)

    # Phase 1: normal histogram streaming must work first.
    col = _ByteCollector(histo, HISTO_FRAME_BYTES)
    col.start()
    assert sensor.enable_camera(CAM_MASK) is True
    assert sensor.enable_aggregator_fsin() is True
    time.sleep(PHASE_SECONDS)
    phase1 = col.stop()
    assert len(phase1) >= MIN_HISTO_BYTES, (
        f"histogram stream never started: {len(phase1)} B in {PHASE_SECONDS}s")

    # Phase 2: enter image mode MID-STREAM. Firmware suspends histograms.
    active, rmask, gaps0 = _image_mode(sensor, enable=True, mask=CAM_MASK)
    assert active == 1 and rmask == CAM_MASK
    assert all(g == 0 for g in gaps0), "gap counters must reset on enter"

    col = _ByteCollector(histo, IMAGE_PKT)
    col.start()
    time.sleep(PHASE_SECONDS)
    phase2 = col.stop()
    img_pkts = _extract_image_packets(phase2)
    # FPGA is still in histogram mode: each 40 Hz 4100-B envelope yields one
    # full 2408-B 'line' packet (then a stalled partial -> timeout resync).
    assert len(img_pkts) >= 10, (
        f"no TYPE_IMAGE packets while image mode active (got {len(img_pkts)})")
    assert all(p[11] in CAMS for p in img_pkts), "cam_id field out of mask"
    assert any(_envelope_crc_ok(p) for p in img_pkts), (
        "no image envelope passed the util_crc16 check -- framing broken")

    # The stalled-partial pattern must have exercised the line timeout.
    _, _, gaps1 = _image_mode(sensor, enable=False)
    assert any(gaps1[c] > 0 for c in CAMS), (
        f"line timeout never fired (gaps={gaps1}) -- watchdog not working")

    # Phase 3: histograms must RESUME with no host re-enable (firmware
    # restored event_bits_enabled + re-armed 4100-B receptions on exit).
    histo.flush_stale_data(HISTO_FRAME_BYTES)
    col = _ByteCollector(histo, HISTO_FRAME_BYTES)
    col.start()
    time.sleep(PHASE_SECONDS)
    phase3 = col.stop()
    assert len(phase3) >= MIN_HISTO_BYTES, (
        f"histogram stream did not resume after image-mode exit: {len(phase3)} B")
    assert sensor.ping() is True, "command interface unhealthy after image mode"


@requires_bench
def test_image_line_stream_smoke(sensor):
    assert sensor.ping() is True
    _bring_up(sensor)

    ver = _fpga_read(sensor, CAMS[0], REG_VERSION)
    if ver is None or ver < 0x02:
        pytest.skip(
            f"camera FPGA register map v2 required (VERSION={ver!r}); load the "
            "feature/8 bitstream (camera-fpga tools/full_frame_capture/"
            "update_bitstream.py) and re-run")

    histo = sensor.uart.histo
    histo.flush_stale_data(IMAGE_PKT)
    assert sensor.enable_camera(CAM_MASK) is True
    assert sensor.enable_aggregator_fsin() is True

    active, _, _ = _image_mode(sensor, enable=True, mask=CAM_MASK)
    assert active == 1

    col = _ByteCollector(histo, IMAGE_PKT)
    col.start()
    for cam in CAMS:
        _fpga_write(sensor, cam, REG_LINE_L, 0)
        _fpga_write(sensor, cam, REG_LINE_H, 0)   # H commits the pair
        _fpga_write(sensor, cam, REG_CTRL, 0x03)  # bit0 image + bit1 SWEEP
    time.sleep(PHASE_SECONDS)
    for cam in CAMS:
        _fpga_write(sensor, cam, REG_CTRL, 0x00)
    raw = col.stop()

    pkts = _extract_image_packets(raw)
    # No sensor retiming here (production HTS): the FPGA overruns and pushes
    # at drain rate (~1.4 kHz/camera) -- thousands of lines in 3 s. Demand a
    # conservative floor so USB hiccups don't flake the test.
    assert len(pkts) >= 100, f"sweep produced only {len(pkts)} line packets"
    crc_ok = [p for p in pkts if _envelope_crc_ok(p)]
    assert len(crc_ok) >= len(pkts) // 2, (
        f"only {len(crc_ok)}/{len(pkts)} envelopes CRC-clean")
    # Inner line header: magic 0xB6, format version 0x01 at the line offset.
    magic_ok = [p for p in crc_ok if p[12] == 0xB6 and p[13] == 0x01]
    assert magic_ok, "no envelope carried a valid FPGA line header (B6 01)"
    _image_mode(sensor, enable=False)
    assert sensor.ping() is True
```

- [ ] **Step 2: Verify collection off-bench (imports + skip wiring)**

Run: `pytest tests/test_image_mode_hil.py -v`
Expected: `2 skipped` with reason `hardware-in-the-loop test; set OPENMOTION_HIL=1 on the bench`. No import/syntax errors.

- [ ] **Step 3: Commit**

```bash
git add tests/test_image_mode_hil.py
git commit -m "test: HIL suite for drip-scan image mode - enter/exit, timeout, histogram resume, sweep line-rate smoke (#<N>)"
```

---

### Task 9: Deploy, run on the bench, regression, docs

**Files:**
- Modify: `CLAUDE.md` (HIL test table, lines ~186-195; gotchas list)

- [ ] **Step 1: Build Release + Debug clean**

```powershell
cmake --build build/Debug
cmake --preset Release
cmake --build build/Release
```

Expected: both configurations build clean (Release catches `-Os`-only warnings).

- [ ] **Step 2: Deploy to the bench sensor (firmware-only flash — the FPGA bitstream is unchanged by this repo)**

```powershell
python scripts/deploy.py --device left --fw-only --no-confirm `
  --power-cycle-cmd "python C:\Users\ethan\Projects\openmotion-bloodflow-app\tests\shelly.py cycle"
```

Expected: DFU flash of `motion-sensor-fw-raw.bin` (~374 KB, ~5 s), power cycle, sensor re-enumerates. (dfu-util exit 74 after a successful download is a known ROM quirk; the script trusts re-enumeration.)

- [ ] **Step 3: Run the new HIL suite**

```powershell
$env:OPENMOTION_HIL = "1"
$env:OW_SENSOR_SIDE = "left"
$env:OPENMOTION_POWER_CYCLE_CMD = "python C:\Users\ethan\Projects\openmotion-bloodflow-app\tests\shelly.py cycle"
pytest tests/test_image_mode_hil.py -v -s
```

Expected: `test_image_mode_enter_exit_and_histogram_resume` **PASSES** with any FPGA bitstream. `test_image_line_stream_smoke` passes if the feature/8 bitstream is loaded (load it with `python tools/full_frame_capture/update_bitstream.py` from the camera-fpga repo checkout on branch `feature/8-drip-scan-single-frame`), otherwise **SKIPS** with the version message — a skip is acceptable for this repo's PR; note which outcome you got on the issue.

- [ ] **Step 4: Run the existing histogram HIL regression (spec acceptance: histogram suite passes after an image-mode session)**

```powershell
pytest tests/test_histo_wedge_recovery_hil.py tests/test_camera_gain_hil.py -v -s
```

Expected: PASS. Power-cycle between streaming runs if a wedge appears (repo CLAUDE.md).

- [ ] **Step 5: Comment verification results on the issue**

```bash
gh issue comment <N> -R OpenwaterHealth/openmotion-sensor-fw --body "Bench verification on left sensor: test_image_mode_enter_exit_and_histogram_resume PASS (TYPE_IMAGE envelopes verified CRC-clean, line-timeout gap counters fired as designed, histogram stream resumed without host re-enable); test_image_line_stream_smoke <PASS with feature/8 bitstream | SKIPPED pending feature/8 bitstream>; existing histogram HIL regression PASS. Per-line ISR cost and all-8 queue behavior measured: <replace this with the ISR-cost and queue-depth numbers actually measured in Step 4 before posting>."
```

- [ ] **Step 6: Update CLAUDE.md**

In the HIL test table (CLAUDE.md lines ~186-195), add a row:

```markdown
| `test_image_mode_hil.py` | Drip-scan image mode: enter/exit, line timeout, histogram resume, FPGA-sweep line-rate smoke (smoke skips without the feature/8 camera-FPGA bitstream). |
```

In the Gotchas list, add:

```markdown
- **Image mode vs debug flags.** `OW_CAMERA_IMAGE_MODE` (drip-scan) refuses to start under `DEBUG_FLAG_FAKE_DATA`, and `DEBUG_FLAG_HISTO_THROTTLE`/`DEBUG_FLAG_HISTO_SPARSE` silently swallow image-line packets inside `USBD_HISTO_SendData` — clear them before a capture. The first histogram frame after image-mode exit is consumed firmware-side (FPGA first-frame-garbage caveat).
```

- [ ] **Step 7: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: CLAUDE.md - image-mode HIL test row + debug-flag gotcha (#<N>)"
```

---

### Task 10: PR and board close-out

**Files:** none (process only).

- [ ] **Step 1: Push and open the PR against next**

```bash
git push -u origin feature/<N>-drip-scan-image-mode
gh pr create -R OpenwaterHealth/openmotion-sensor-fw --base next \
  --title "feat: drip-scan image receive mode (OW_CAMERA_IMAGE_MODE, stream type 0x03)" \
  --body "Sensor-fw side of the drip-scan single-frame feature (design spec: openmotion-camera-fpga docs/superpowers/specs/2026-07-19-drip-scan-single-frame-design.md, section 4.4; FPGA side: OpenwaterHealth/openmotion-camera-fpga#8).

- OW_CAMERA_IMAGE_MODE = 0x30 (reserved=enable, data[0]=camera bitmask); response carries per-camera gap counters (image_mode_resp_t, 36 B).
- Image mode suspends histogram streaming (event_bits_enabled saved/zeroed), aborts in-flight histogram DMA, arms repeating 2408-B one-shot DMA per masked camera into the existing receive buffers at a 12-byte offset -- the 2424-B USB envelope (SOF/0x03/size/timestamp/SOH/cam_id/line/EOH/CRC16/EOF, send_histogram_data CRC-span convention) is built in place, zero copy; cam 1's SPI6/BDMA/SRAM4 constraint is inherited from spi6_buffer.
- Data-paced: RxCplt forwards and re-arms via a software-pended LPTIM5 IRQ at priority 7 (the H7 HAL USART driver sets State=READY only AFTER the RxCplt callback, so an inline re-arm is impossible on the 4 USART links).
- ~2 ms per-camera line timeout from the main loop (DMA NDTR/CNDTR progress watchdog) -> abort + re-arm + gap counter; link-error callbacks route to the same recovery in image mode.
- Exit restores histogram arming and consumes/discards the next histogram frame (FPGA first-frame-garbage caveat).
- Histogram wire path untouched and byte-identical.
- Tests: tests/test_image_packet_format.py (wire constants + CRC-16/CCITT-FALSE table vectors, off-bench) and tests/test_image_mode_hil.py (enter/exit + timeout + resume; FPGA-sweep line-rate smoke).

Protocol doc note: CommandHandling.md (console-fw repo) and the SDK constants get the 0x30 opcode via the SDK companion issue.

Refs #<N>"
```

- [ ] **Step 2: Move the board card to In review**

```bash
gh project item-edit --id <ITEM_ID> --project-id PVT_kwDOAif52c4BVgTu --field-id PVTSSF_lADOAif52c4BVgTuzhQ7qcU --single-select-option-id 5ef0dc97
```

- [ ] **Step 3: Comment the PR link on the issue**

```bash
gh issue comment <N> -R OpenwaterHealth/openmotion-sensor-fw --body "PR up: <PR-URL>. Ticket stays In review through pre-release validation per board process; companion SDK issue (StreamInterface type 0x03 routing, reassembler, capture orchestrator) to be filed in openmotion-sdk when that plan starts."
```

Do **not** close the issue — it stays In review until the change ships in a full release or Ethan confirms validation (board process; merge alone never finishes a ticket).

---

## Out of scope (do not build here)

- Sensor retiming writes (HTS 0x380C/D=38400, VTS 0x380E/F=1312, tc_r_initial 0x3826/27=1308, exposure 0x3501/02=1 row, FSIN 0.8 Hz) — host-side group-hold orchestration in the SDK companion, via the existing `OW_CAMERA_SWITCH` + `OW_I2C_PASSTHRU` path. Firmware carries no timing profile.
- SDK changes (`StreamInterface` type-0x03 routing, image reassembler, capture orchestrator) — separate plan in openmotion-sdk.
- FPGA v2 register map / double-buffered sweep — openmotion-camera-fpga #8.
- Link-speed experiments (spec §4.6) — follow-on once this transport is validated.
- Laser parameters — untouched by design; only the FSIN repetition rate changes, host-side.