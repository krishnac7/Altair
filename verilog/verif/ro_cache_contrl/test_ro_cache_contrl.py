import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge

@cocotb.test()
async def test_write(dut):
    clock = Clock(dut.i_clk, 10, units="us") # 10us period clock
    cocotb.fork(clock.start())
    # FIXME This is just a template, please implement testbench
    dut.old_tags.value = 0b00000000
    dut.hit.value = 0b00
    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    assert dut.new_tags.value.binstr == "11000000", "Way 1 is the latest used way"

    #assert dut.o_en.value.binstr == '{:01b}'.format(expected_en), "Bad enable signal"
