import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge

@cocotb.test()
async def test_w0_reset(dut):
    clock = Clock(dut.i_clk, 10, units="us") # 10us period clock
    cocotb.fork(clock.start())
    dut.old_tags.value = 0b00000000
    dut.hit.value = 0b00
    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    assert dut.new_tags.value.binstr == "11000000", "Way 1 is the latest used way"

    #assert dut.o_en.value.binstr == '{:01b}'.format(expected_en), "Bad enable signal"
@cocotb.test()
async def test_w3_others_decremented(dut):
    clock = Clock(dut.i_clk, 10, units="us") # 10us period clock
    cocotb.fork(clock.start())
    dut.old_tags.value = 0b01111000
    dut.hit.value = 0b11
    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    assert dut.new_tags.value.binstr == "00100111", "Way 3 is the latest used way, all others are decremented"
