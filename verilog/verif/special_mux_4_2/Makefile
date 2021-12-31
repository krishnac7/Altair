export COCOTB_REDUCED_LOG_FMT=1
SIM = icarus
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/../../src/special_mux_4_2.v
TOPLEVEL = Special_mux_4_2
MODULE = test_special_mux_4_2

include $(shell cocotb-config --makefiles)/Makefile.sim

clean_all: clean
	rm -rf __pycache__ results.xml
