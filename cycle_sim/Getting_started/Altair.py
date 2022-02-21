from SimEngine import *

# Buses
MMU_L1InstrMemory = LatchSetTemplate()
MMU_L1InstrMemory.new("data")
MMU_L1InstrMemory.new("addr")
MMU_L1InstrMemory.new("write") # The MMU wants to write 'data' to memory at address 'addr'
MMU_L1InstrMemory.new("read") # The MMU wants to read to memory from address 'addr'
# Note: if both write and read are set together, this means the MMU is not
# ready and the memory should wait for it / do nothing

L1InstrMemory_MMU = LatchSetTemplate()
L1InstrMemory_MMU.new("writeback") # when 1 the cache will remove entry for 'wb_missaddr'
# and wants the MMU to store 'data' somewhere else
L1InstrMemory_MMU.new("wb_missaddr") # the address when 'writeback' or requested after a cache miss
L1InstrMemory_MMU.new("data") # the data the MMU asked for when reading
# or 'writeback' data that need to be saved
L1InstrMemory_MMU.new("miss") # cache miss: when '1' the L1 cache memory notify the MMU
# it needs the data at address 'wb_missaddr'

BRU_L1InstrMemory = LatchSetTemplate()
BRU_L1InstrMemory.new('addr')
BRU_L1InstrMemory.new('fetch')
# when '1' the L1 cache should either fetch 1-2 instructions from 'addr' or
# return 'emulreg'
BRU_L1InstrMemory.new('emul') # when '1' the L1 cache returns 'emulreg' instead
# of the instruction(s) read from memory

# Modules

INSTRUCTION_NOP = 0 # TODO check the ISA

class L1InstrMemory(Synchronous): # The is the instruction fetch (IF) stage
    """
    This is the L1 Instruction cache memory providing instructions to the core
    It is connec to the Memory Management Unit (MMU) and to the core through
    the Branch Unit (BRU).
    The MMU has the priority, when not accessed by the 'stall' is set to 0 and
    the core can proceed.

    This is a 4 way set-associative cache.
    https://en.wikipedia.org/wiki/Cache_placement_policies
    https://www.sciencedirect.com/topics/computer-science/set-associative-cache
    """
    def init(self):

        # MMU access
        self.inputs_bus.new("MMU", MMU_L1InstrMemory)
        self.outputs_bus.new("MMU", L1InstrMemory_MMU)

        # Core (BRU) access
        self.inputs_bus.new("BRU", BRU_L1InstrMemory)

        # Miscellaneous
        self.inputs.new("emulreg")

        # Feeding the pipeline
        self.outputs.new("stall", 0, "Inform the pipeline no new instruction \
        was provided and it should stall")
        self.outputs.new("instr0", 0, "Instruction 0")
        self.outputs.new("instr1", 0, "Instruction 1")

    def tick(self):
        MMU_monopoly = self.inputs_bus.MMU.read or self.inputs_bus.MMU.write
        waitformmu = self.inputs_bus.MMU.read or self.inputs_bus.MMU.write


        if MMU_monopoly = 1:
            # Stall the core since we cannot provide instructions
            self.outputs.stall = 1
            # The returned instructions do not matter we simply keep them as-is
            self.outputs.instr0 = self.outputs.instr0 # do not care
            self.outputs.instr1 = self.outputs.instr0 # do not care

            if self.inputs_bus.MMU.read = 1:
                self.outputs_bus.MMU.writeback = 0
                self.outputs_bus.MMU.wb_missaddr = 0 # No writeback
                # TODO access the 4 way set-associative cache and return the
                # data (return cache miss if enable)
                # TODO set self.outputs_bus.MMU.data
                # TODO set self.outputs_bus.MMU.miss
                pass
            if self.inputs_bus.MMU.write = 1:
                self.outputs_bus.MMU.miss = 0
                # TODO add or update an entry in the set-associative
                # cache, output to 'writeback'/'wb_missaddr'/data if the cache is full and more room
                # is needed
                # TODO set self.outputs_bus.MMU.writeback
                # TODO set self.outputs_bus.MMU.wb_missaddr
                # TODO set self.outputs_bus.MMU.data
                pass
        else:
            # No MMU access we take order from the BRU and deliver to our
            # outputs
            if self.inputs_bus.BRU.fetch = 0:
                # Making sure we set all outputs
                self.outputs.stall = 1
                self.outputs.instr0 = self.outputs.instr0
                self.outputs.instr1 = self.outputs.instr0

                self.outputs_bus.MMU.writeback = 0
                self.outputs_bus.MMU.wb_missaddr = self.outputs_bus.MMU.wb_missaddr # do not care
                self.outputs_bus.MMU.data = self.outputs_bus.MMU.data # do not care
                self.outputs_bus.MMU.miss = 0
            else:
                # TODO
                if self.inputs_bus.BRU.emul:
                    self.outputs.stall = 0
                    self.outputs.instr0 = self.inputs.emulreg # TODO check if it should be instr0 or instr1
                    self.outputs.instr1 = INSTRUCTION_NOP

                    self.outputs_bus.MMU.writeback = 0
                    self.outputs_bus.MMU.wb_missaddr = self.outputs_bus.MMU.wb_missaddr # do not care
                    self.outputs_bus.MMU.data = self.outputs_bus.MMU.data # do not care
                    self.outputs_bus.MMU.miss = 0
                else:
                    self.outputs_bus.MMU.writeback = 0
                    self.outputs_bus.MMU.data = self.outputs_bus.MMU.data # do not care
                    # TODO fetch self.inputs_bus.BRU.addr from the 4 way
                    # set-associative cache
                    # return instr0 / instr1 and stall=0 if this is a success
                    # else:
                    # stall=1 and set outputs_bus.MMU.miss/wb_missaddr to ask
                    # request the MMU for the data
                    # Next cycle the MMU will write or TODO set 'waitforMMU'
                    pass
