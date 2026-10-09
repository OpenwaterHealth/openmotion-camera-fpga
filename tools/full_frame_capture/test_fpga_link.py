import pytest
from fpga_link import FpgaRegs, REG_ID, REG_CTRL, REG_LINE_L, REG_LINE_H

class FakeSensor:
    def __init__(self):
        self.calls = []
        self.next = b"\x5a"
    def i2c_read_register(self, dev_addr, reg_addr, read_len=1,
                          reg_addr_size=1, mux_channel=None):
        self.calls.append(dict(dev=dev_addr, reg=reg_addr, n=read_len,
                               size=reg_addr_size, mux=mux_channel))
        return self.next

def test_read_id():
    s = FakeSensor()
    r = FpgaRegs(s, cam=3)
    assert r.read(REG_ID) == 0x5A
    c = s.calls[0]
    assert c == dict(dev=0x5A, reg=0x00, n=1, size=1, mux=3)

def test_write_encodes_reg_and_value_in_16bit_address():
    s = FakeSensor()
    r = FpgaRegs(s, cam=0)
    r.write(REG_CTRL, 0x01)
    c = s.calls[0]
    assert c["size"] == 2 and c["reg"] == (REG_CTRL << 8) | 0x01

def test_set_line_writes_l_then_h():
    s = FakeSensor()
    r = FpgaRegs(s, cam=7)
    r.set_line(0x234)
    assert s.calls[0]["reg"] == (REG_LINE_L << 8) | 0x34
    assert s.calls[1]["reg"] == (REG_LINE_H << 8) | 0x02

def test_read_error_raises():
    s = FakeSensor()
    s.next = False
    with pytest.raises(IOError):
        FpgaRegs(s, cam=0).read(REG_ID)
