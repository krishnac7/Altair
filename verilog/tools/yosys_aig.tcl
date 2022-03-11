# Usage:
# VLOG_FILE_NAME=.../dut.v yosys yosys_aig.tcl

proc pause {{message "Hit Enter to continue ==> "}} {
    puts -nonewline $message
    flush stdout
    gets stdin
}

yosys read_verilog $::env(VLOG_FILE_NAME)
pause;
if { $::env(TOPLEVEL) eq ""} {
    yosys proc
    yosys memory
    yosys show
    pause;
    yosys synth
    yosys flatten
    yosys show
    pause;
    yosys abc -g AND,NAND,OR,NOR,ANDNOT,ORNOT # AIG
    yosys clean
    yosys show
    pause;
} else {
    yosys proc
    yosys memory
    yosys show $::env(TOPLEVEL)
    pause;
    yosys synth -top $::env(TOPLEVEL)
    yosys flatten
    yosys show $::env(TOPLEVEL)
    pause;
    # Synthetize again but the flat design all together
    yosys synth -top $::env(TOPLEVEL)
    yosys abc -g AND,NAND,OR,NOR,ANDNOT,ORNOT # AIG
    yosys clean
    yosys show $::env(TOPLEVEL)
    pause;
}
