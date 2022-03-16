# Usage:
# SYNTH_OUTPUT=... TOP_LEVEL=... VLOG_FILE_NAME=.../dut.v yosys yosys_ng45.tcl

proc pause {{message "Hit Enter to continue ==> "}} {
    puts -nonewline $message
    flush stdout
    gets stdin
}

yosys read_verilog $::env(VLOG_FILE_NAME)
yosys hierarchy -check
pause;
yosys proc; yosys opt; yosys memory; yosys opt; yosys fsm; yosys opt
# Convert design to logical gate-level netlists
yosys techmap -map "$::env(NANGATE45)/cells_*"
yosys opt
# TODO: options for synth?
yosys synth -top $::env(TOPLEVEL)
yosys flatten
pause;
# Map internal register types to the ones form the cell library
yosys dfflibmap -liberty "$::env(NANGATE45)/lib/NangateOpenCellLibrary_typical.lib"
# Use ABC to map remaining logic to cells from the cell library
yosys abc -liberty "$::env(NANGATE45)/lib/NangateOpenCellLibrary_typical.lib" -D 1
#yosys abc -liberty "$::env(NANGATE45)/lib/NangateOpenCellLibrary_typical.lib"
yosys opt                                                                      
yosys clean                                                                    
yosys stat                                                                     
yosys write_verilog $::env(SYNTH_OUTPUT)
pause;
