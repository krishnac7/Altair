from SimEngine import *

stdBus = LatchSetTemplate()
stdBus.new("data")
stdBus.new("valid")
stdBus.new("reset")


class ModuleA(Synchronous):
    def init(self):
        self.outputs_bus.new("bus0", stdBus)
    def tick(self):
        self.outputs_bus.bus0.data = self.outputs_bus.bus0.data + 2

class ModuleB(Synchronous):
    def init(self):
        self.inputs_bus.new("bus0", stdBus)
        self.outputs.new("test", 0)
    def tick(self):
        a = self.inputs_bus.bus0.data
        self.outputs.test = a


class TopLevel(Synchronous):
    def init(self):
        self.children.new("A", ModuleA())
        self.children.new("B", ModuleB())

        # It is very easy to connect buses together
        self.children.B.inputs_bus.bus0.connect(self.children.A.outputs_bus.bus0)
    def tick(self):
        pass
dut = TopLevel()

for i in range(32):
    print("A.bus0.data: {}".format(dut.children.A.outputs_bus.bus0.data))
    print("B.tests: {}".format(dut.children.B.outputs.test))
    dut.simulate_one_cycle()

dut.simulate(10)
