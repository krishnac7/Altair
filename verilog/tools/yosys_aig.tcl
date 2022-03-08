# Usage:
# VLOG_FILE_NAME=.../dut.v yosys yosys_aig.tcl

yosys read_verilog $::env(VLOG_FILE_NAME)
yosys proc
yosys memory
yosys show
yosys synth
yosys show
yosys abc -g AND,NAND,OR,NOR,ANDNOT,ORNOT # AIG
yosys clean
yosys show
