"""Register access to the camera FPGA's I2C slave (0x5A) through the sensor
firmware's OW_CMD_I2C_REG_READ passthrough (SDK MotionSensor.i2c_read_register).

Writes use the '16-bit register address' trick: the firmware emits
START,addr+W,[hi],[lo],RESTART,addr+R,read — the slave interprets [hi] as the
register pointer and [lo] as a data write (see design spec in
docs/superpowers/specs/2026-07-05-i2c-slave-line-readout-design.md)."""

FPGA_ADDR = 0x5A
REG_ID, REG_VERSION, REG_SCRATCH, REG_CTRL = 0x00, 0x01, 0x02, 0x03
REG_LINE_L, REG_LINE_H, REG_LINE_CUR_L, REG_LINE_CUR_H = 0x04, 0x05, 0x06, 0x07
REG_FRAME_CNT, REG_STATUS = 0x08, 0x09
ID_VAL, MAGIC = 0x5A, 0xB6


def force_program_fpga(sensor, cam_mask: int, timeout: int = 120) -> bool:
    """Force an FPGA SRAM load from the sensor's flash-resident bitstream.

    OW_FPGA_PROG_SRAM with reserved==2 (force) bypasses the firmware's
    isProgrammed/NVCM gates — required because the fleet cameras are
    NVCM-programmed and would otherwise silently keep the burned image.
    Needs force-capable firmware (1.8.1-rc.3 + #68 hunk, or feature/68).
    Takes ~10 s per camera in the mask."""
    from omotion.config import OW_FPGA, OW_FPGA_PROG_SRAM
    from omotion.MotionSensor import _ERROR_TYPES
    r = sensor._send(packetType=OW_FPGA, command=OW_FPGA_PROG_SRAM,
                     addr=cam_mask, reserved=2, timeout=timeout)
    return r is not None and r.packetType not in _ERROR_TYPES


def upload_bitstream(sensor, bitstream_path, block: int = 500) -> bool:
    """Upload a bitstream file into the sensor's RAM buffer (CRC-checked).
    The buffer persists across upload_program_fpga calls, so upload once and
    program any number of cameras from it.

    Rolls its own blocks instead of SDK send_bitstream_fpga: the sensor's
    comms RX buffer is 512 B, so payloads above 500 B are rejected with
    OW_ERROR (the SDK's 1 KB blocks never arrive). Also, the packet 'addr'
    byte only matters as addr==0 → firmware resets the upload buffer, so we
    send 0 for the first block and 1 for the rest (a naive running index
    would wrap at 256 and silently restart the upload)."""
    from pathlib import Path
    from omotion.config import OW_FPGA, OW_FPGA_BITSTREAM
    from omotion.MotionSensor import _ERROR_TYPES
    from omotion.utils import calculate_file_crc

    data = Path(bitstream_path).read_bytes()
    crc = calculate_file_crc(str(bitstream_path))
    for off in range(0, len(data), block):
        r = sensor._send(packetType=OW_FPGA, command=OW_FPGA_BITSTREAM,
                         addr=(0 if off == 0 else 1), reserved=0,
                         data=bytearray(data[off:off + block]), timeout=10)
        if r is None or r.packetType in _ERROR_TYPES:
            return False
    r = sensor._send(packetType=OW_FPGA, command=OW_FPGA_BITSTREAM,
                     addr=1, reserved=1,
                     data=bytearray(crc.to_bytes(2, "big")), timeout=10)
    return r is not None and r.packetType not in _ERROR_TYPES


def upload_program_fpga(sensor, cam: int, erase_wait_s: float = 5.5) -> bool:
    """Program ONE camera's FPGA from the previously uploaded RAM bitstream —
    the pure-SDK flow (no flash-resident image needed). Requires firmware with
    the sensor-fw#82 fix set (xi2c_write_long staging, buffer+4 source,
    reserved==3 forced upload, real ISC_DISABLE on exit).

    Sequence mirrors fpga_configure(): activation key while CRESETB is low
    (forced slave config, so an NVCM part enters config mode instead of
    auto-booting), IDCODE check, SRAM enable, erase (+host-side settle: the
    discrete-command firmware path doesn't insert fpga_configure's 5 s wait),
    then the forced RAM-sourced program and ISC_DISABLE."""
    import time
    mask = 1 << cam
    from omotion.config import OW_FPGA, OW_FPGA_PROG_SRAM
    from omotion.MotionSensor import _ERROR_TYPES

    def cfg_status():
        """Raw CrossLink status via the factory I2C passthrough (the active
        camera's device address is the config port, 0x40). Returns 4 bytes
        or None. DONE criterion per fpga_configure: byte[2] == 0x0F."""
        try:
            rb = sensor.i2c_write_read(0x40, bytes([0x3C, 0, 0, 0]), 4)
            return bytes(rb) if rb else None
        except Exception:
            return None

    sensor.switch_camera(cam)
    sensor.creset(False)
    time.sleep(0.1)
    if not sensor.activate_camera_fpga(mask):
        print(f"cam{cam}: activation key failed")
        return False
    sensor.creset(True)
    time.sleep(0.15)
    if sensor.creset(None) != 1:                  # verify CRESETB actually high
        print(f"cam{cam}: CRESETB did not go high")
        return False
    if not sensor.check_camera_fpga(mask):        # IDCODE
        print(f"cam{cam}: IDCODE mismatch")
        return False
    if not sensor.enter_sram_prog_fpga(mask):     # ISC_ENABLE (0xC6)
        print(f"cam{cam}: ISC_ENABLE failed")
        return False
    if not sensor.erase_sram_fpga(mask):          # ISC_ERASE (0x0E)
        print(f"cam{cam}: erase failed")
        return False
    time.sleep(erase_wait_s)
    st = cfg_status()
    r = sensor._send(packetType=OW_FPGA, command=OW_FPGA_PROG_SRAM,
                     addr=mask, reserved=3, timeout=120)  # forced, RAM source
    if r is None or r.packetType in _ERROR_TYPES:
        print(f"cam{cam}: bitstream program command failed")
        return False
    st = cfg_status()
    print(f"cam{cam}: post-program status: "
          f"{st.hex() if st else 'unreadable'}")
    sensor.exit_sram_prog_fpga(mask)              # ISC_DISABLE (0x26)
    time.sleep(0.05)
    done = bool(st) and st[2] == 0x0F
    if not done:
        print(f"cam{cam}: DONE not set (expected byte2==0x0F)")
    return done


class FpgaRegs:
    def __init__(self, sensor, cam: int):
        self.sensor = sensor
        self.cam = cam

    def read(self, reg: int, n: int = 1):
        r = self.sensor.i2c_read_register(
            FPGA_ADDR, reg, read_len=n, reg_addr_size=1, mux_channel=self.cam)
        if r is False or r is None:
            raise IOError(f"cam{self.cam}: I2C read reg 0x{reg:02X} failed")
        return r[0] if n == 1 else bytes(r)

    def write(self, reg: int, value: int) -> None:
        r = self.sensor.i2c_read_register(
            FPGA_ADDR, ((reg & 0xFF) << 8) | (value & 0xFF),
            read_len=1, reg_addr_size=2, mux_channel=self.cam)
        if r is False or r is None:
            raise IOError(f"cam{self.cam}: I2C write reg 0x{reg:02X} failed")

    def check_id(self) -> bool:
        try:
            return self.read(REG_ID) == ID_VAL
        except IOError:
            return False

    def scratch_test(self) -> bool:
        self.write(REG_SCRATCH, 0x3C)
        ok = self.read(REG_SCRATCH) == 0x3C
        self.write(REG_SCRATCH, 0xA5)
        return ok

    def set_line(self, line: int) -> None:
        self.write(REG_LINE_L, line & 0xFF)
        self.write(REG_LINE_H, (line >> 8) & 0x0F)

    def get_line(self) -> int:
        lo = self.read(REG_LINE_CUR_L)
        hi = self.read(REG_LINE_CUR_H)
        return ((hi & 0x0F) << 8) | lo

    def set_image_mode(self, start_line: int = 0) -> None:
        self.set_line(start_line)
        self.write(REG_CTRL, 0x01)

    def set_histogram_mode(self) -> None:
        """Switch back to histogram mode.

        Host rule (see spec): the FIRST histogram packet after leaving image
        mode contains counts accumulated across the whole image session and
        must be discarded by any consumer."""
        self.write(REG_CTRL, 0x00)

    def frame_count(self) -> int:
        return self.read(REG_FRAME_CNT)
