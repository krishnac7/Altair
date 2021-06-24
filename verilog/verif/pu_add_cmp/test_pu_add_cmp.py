import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge

OPCODE_SUB = 0b000001
OPCODE_ADD = 0b000010
OPCODE_ICMP = 0b000011

FLAG_INDEX_EQ = 10
FLAG_INDEX_NEQ = 1
FLAG_INDEX_GTU = 2
FLAG_INDEX_GTS = 3
FLAG_INDEX_GEU = 4
FLAG_INDEX_GES = 5
FLAG_INDEX_LTU = 6
FLAG_INDEX_LTS = 7
FLAG_INDEX_LEU = 8
FLAG_INDEX_LES = 9

def init_inputs(dut):
    """
    Initialize inputs
    """
    dut.i_clk <= 0b0
    dut.i_rst <= 0b0
    dut.i_opcode <= 0b000000
    dut.i_rega <= 0b00000
    dut.i_regb <= 0b00000
    dut.i_regd <= 0b00000
    dut.i_unique_ack <= 0b0
    dut.i_ina <= 0x0000000000000000
    dut.i_inb <= 0x0000000000000000
    dut.i_cmp_op <= 0b0000
# Output
#o_sela
#o_selb
#o_write_reg
#o_write_data
#o_write_en
#o_flag_cmp
#o_write_flag
#o_unique_ack

@cocotb.test()
async def test_pu_add_cmp(dut):
    clock = Clock(dut.i_clk, 10, units="us") # 10us period clock
    cocotb.fork(clock.start())

    init_inputs(dut)

    assert dut.o_write_en.value.binstr == "0", "No input: We should not write any register"
    assert dut.o_write_flag.value.binstr == "0", "No input: We should not write any register"
    #assert dut.dout.value.binstr == bin(0xaba4268b)[2:], "Should be able to read 1 cycle after writing"
    await RisingEdge(dut.i_clk)
    assert dut.o_write_en.value.binstr == "0", "No input: We should not write any register"
    assert dut.o_write_flag.value.binstr == "0", "No input: We should not write any register"
    await RisingEdge(dut.i_clk)