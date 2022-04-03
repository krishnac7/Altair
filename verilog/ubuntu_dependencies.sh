
# verilog simulators
sudo apt install iverilog verilator

# Static timing analysis
sudo apt install opensta

# Synthesis
sudo apt install yosys

# Convert systemVerilog to Verilog
# required to compile sv2v
sudo apt install haskell-platform
git clone https://github.com/zachjs/sv2v.git
cd sv2v/
sudo cp bin/sv2v /usr/bin/


