from SimEngine import *

class Counter(Synchronous):
    def init(self):
        self.outputs.new("o_count", 0)
    def tick(self):
        self.outputs.o_count = self.outputs.o_count + 1

dut = Counter()
for i in range(32):
    print(dut.outputs.o_count)
    dut.simulate_one_cycle()
