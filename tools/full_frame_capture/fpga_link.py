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
