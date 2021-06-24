import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge

@cocotb.test()
async def test_pu_bitwise(dut):
    clock = Clock(dut.i_clk, 10, units="us") # 10us period clock
    cocotb.fork(clock.start())
    dut.i_clk <= 0b0
    dut.i_rst <= 0b0
    dut.i_opcode <= 0b000000
    dut.i_rega <= 0b00000
    dut.i_regb <= 0b00000
    dut.i_regd <= 0b00000
    dut.i_unique_ack <= 0b0
    dut.i_ina <= 0x0000000000000000
    dut.i_inb <= 0x0000000000000000
    await RisingEdge(dut.i_clk)
    assert dut.o_write_en.value.binstr == "0", "No input: We should not write any register"
    