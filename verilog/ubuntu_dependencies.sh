#Installing Python
sudo apt isntall python3 python3-pip -y

# verilog simulators
sudo apt install iverilog verilator -y

# Static timing analysis
sudo apt install opensta -y

# Synthesis
sudo apt install yosys -y

# Convert systemVerilog to Verilog
# required to compile sv2v
sudo apt install haskell-platform -y
git clone https://github.com/zachjs/sv2v.git
cd sv2v/
sudo cp bin/sv2v /usr/bin/

# Writing testcases in python
pip install cocotb python-dev-tools
