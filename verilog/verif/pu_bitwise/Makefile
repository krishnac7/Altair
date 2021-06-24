export COCOTB_REDUCED_LOG_FMT=1
SIM = icarus
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/../../src/pu_bitwise.v
TOPLEVEL = pu_bitwise
MODULE = test_pu_bitwise

include $(shell cocotb-config --makefiles)/Makefile.sim

clean_all: clean
	rm -rf __pycache__ results.xml