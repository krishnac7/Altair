import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge

OPCODE_AND = 0b000100
OPCODE_OR = 0b000101
OPCODE_XOR = 0b000110
OPCODE_ANDI = 0b000111
OPCODE_ORI = 0b001000
OPCODE_XORI = 0b001001

# TODO Test bad opcode
# TODO Test bad opcode + notalone

async def run_add_check(dut, opcode, notalone=0b0):
    a = random.randrange(2**64)
    b = random.randrange(2**64)
    rega = random.randrange(2**5)
    regb = random.randrange(2**5)
    regd = random.randrange(2**5)
    dut.i_clk <= 0b0
    dut.i_rst <= 0b0
    dut.i_opcode <= OPCODE_XOR
    dut.i_rega <= rega
    dut.i_regb <= regb
    dut.i_regd <= regd
    dut.i_unique_ack <= notalone
    dut.i_ina <= a
    dut.i_inb <= b
    await RisingEdge(dut.i_clk)
    if notalone:
        assert dut.o_write_en.value.binstr == "0", "Should not write register"
        assert dut.o_unique_ack.value.binstr == "0", "Should not become active, other PU is"
    else:
        assert dut.o_write_en.value.binstr == "1", "We should write register"
        assert dut.o_write_reg.value.binstr == '{:05b}'.format(regd), "We should write to register ..."
        assert dut.o_sela.value.binstr == '{:05b}'.format(rega), "Input A is reg ..."
        assert dut.o_selb.value.binstr == '{:05b}'.format(regb), "Input B is reg ..."

        if opcode == OPCODE_AND:
            assert dut.o_write_data.value.binstr == '{:064b}'.format(a & b), "AND result is not correct"
        elif opcode == OPCODE_OR:
            assert dut.o_write_data.value.binstr == '{:064b}'.format(a | b), "XOR result is not correct"
        elif opcode == OPCODE_XOR:
            assert dut.o_write_data.value.binstr == '{:064b}'.format(a ^ b), "XOR result is not correct"
        else:
            assert False, "This OPCODE is not implemented: %d" % opcode
        assert dut.o_unique_ack.value.binstr == "1", "Should assert it is working on it"

def init_pu_bitwise(dut):
    clock = Clock(dut.i_clk, 10, units="us") # 10us period clock
    cocotb.fork(clock.start())

@cocotb.test()
async def test_pu_bitwise_xor(dut):
    init_pu_bitwise(dut)
    for i in range(255):
        run_add_check(dut, OPCODE_XOR, random.randrange(2))

@cocotb.test()
async def test_pu_bitwise_or(dut):
    init_pu_bitwise(dut)
    for i in range(255):
        run_add_check(dut, OPCODE_OR, random.randrange(2))

@cocotb.test()
async def test_pu_bitwise_and(dut):
    init_pu_bitwise(dut)
    for i in range(255):
        run_add_check(dut, OPCODE_AND, random.randrange(2))

@cocotb.test()
async def test_pu_bitwise_zero(dut):
    init_pu_bitwise(dut)

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
    assert dut.o_unique_ack.value.binstr == "0", "Should not lock others PUs"

