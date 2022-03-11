export COCOTB_REDUCED_LOG_FMT=1
SIM = icarus
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/../../src/tag_lru.v
TOPLEVEL = tag_lru
MODULE = test_tag_lru

include $(shell cocotb-config --makefiles)/Makefile.sim

clean_all: clean
	rm -rf __pycache__ results.xml
