import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge

@cocotb.test()
async def test_special_mux_4_2(dut):
    clock = Clock(dut.i_clk, 10, units="us") # 10us period clock
    cocotb.fork(clock.start())
    dut.i_clk.value = 0b0

    orig_array = [0x8100002c, 0x9100003d, 0xa100004e, 0xb100005f]
    for i in range(16):
        sel_0 = i&(2**0) != 0;
        sel_1 = i&(2**1) != 0;
        sel_2 = i&(2**2) != 0;
        sel_3 = i&(2**3) != 0;

        await RisingEdge(dut.i_clk)
        dut.i_rst.value = 0b0
        dut.i_selection.value = i
        dut.i_inputs.value = orig_array
        await RisingEdge(dut.i_clk)
        print("i= "+str(i))
        print("Input: ", end="")
        for tm in orig_array:
            print(bin(tm)+" ", end="")
        print()
        print("Selection: "+str(sel_0)+" "+str(sel_1)+" "+str(sel_2)+" "+str(sel_3))
        print("error = " + dut.o_error_selection.value.binstr)
        print("output = " + str(dut.o_outputs.value))

        print("i_selection: "+str(dut.i_selection.value))
        if sel_0+sel_1+sel_2+sel_3<=2:
            assert dut.o_error_selection.value.binstr == "0", "Bad error detection"
            expected_en = 0
            expected = []
            if sel_0:
                expected.insert(0,orig_array[3])
                sel_0 = 0
                expected_en = 1
            elif sel_1:
                expected.insert(0,orig_array[2])
                sel_1 = 0
                expected_en = 1
            elif sel_2:
                expected.insert(0,orig_array[1])
                sel_2 = 0
                expected_en = 1
            elif sel_3:
                expected.insert(0,orig_array[0])
                sel_3 = 0
                expected_en = 1
            else:
                expected.insert(0,orig_array[0])

            if sel_0:
                expected.insert(0,orig_array[3])
                sel_0 = 0
                expected_en = 3
            elif sel_1:
                expected.insert(0,orig_array[2])
                sel_1 = 0
                expected_en = 3
            elif sel_2:
                expected.insert(0,orig_array[1])
                sel_2 = 0
                expected_en = 3
            elif sel_3:
                expected.insert(0,orig_array[0])
                sel_3 = 0
                expected_en = 3
            else:
                expected.insert(0,orig_array[0])

            assert dut.o_en.value.binstr == '{:02b}'.format(expected_en), "Wrong enable signal"
            print("Expected: ", end="")
            for tm in expected:
                print(bin(tm)+" ", end="")
            print()
            assert dut.o_outputs.value == expected, "Bad output signal"
        else:
            print("i>3")
            assert dut.o_error_selection.value.binstr == "1", "Bad error detection"
