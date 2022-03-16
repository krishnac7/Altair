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
yosys techmap -map "$::env(SKY130B)/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
yosys opt
# TODO: options for synth?
yosys synth -top $::env(TOPLEVEL)
yosys flatten
pause;
# Map internal register types to the ones form the cell library
yosys dfflibmap -liberty "$::env(SKY130B)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
# Use ABC to map remaining logic to cells from the cell library
yosys abc -liberty "$::env(SKY130B)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
yosys opt                                                                      
yosys clean                                                                    
yosys stat                                                                     
yosys write_verilog $::env(SYNTH_OUTPUT)
pause;
