export COCOTB_REDUCED_LOG_FMT=1
export SIM = icarus
export TOPLEVEL_LANG = verilog
export VERILOG_SOURCES = $(shell pwd)/ro_cache_contrl.v
export SVERILOG_SOURCES = $(shell pwd)/../../src/ro_cache_contrl.sv
export TOPLEVEL = ro_cache_contrl
export MODULE = test_ro_cache_contrl

include $(shell cocotb-config --makefiles)/Makefile.sim

# Convert systemVerilog to verilog
${VERILOG_SOURCES}: ${SVERILOG_SOURCES}
	$(shell pwd)/../../tools/convert_sv ${SVERILOG_SOURCES} ${VERILOG_SOURCES}


clean_all: clean
	rm -rf __pycache__ results.xml *.v # Clean generated files

#all:
#	$(shell pwd)/../../tools/convert_sv ${SVERILOG_SOURCES} ${VERILOG_SOURCES}
#	make -f $(shell cocotb-config --makefiles)/Makefile.sim
#clean:
#	make -f $(shell cocotb-config --makefiles)/Makefile.sim clean
#	rm -rf __pycache__ results.xml
