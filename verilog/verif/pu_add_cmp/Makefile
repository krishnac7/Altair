export COCOTB_REDUCED_LOG_FMT=1
SIM = verilator
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/../../src/pu_add_cmp.v
TOPLEVEL = pu_add_cmp
MODULE = test_pu_add_cmp

include $(shell cocotb-config --makefiles)/Makefile.sim

clean_all: clean
	rm -rf __pycache__ results.xml