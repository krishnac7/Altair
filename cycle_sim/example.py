# This is just a sketch, do not use

Interface_busA = Interface()
Interface_busA.add_signal("address", 0) # Try to avoid too complex types, integers and bytes are fine
Interface_busA.add_signal("data", 0)
Interface_busA.add_signal("something", 0)
Interface_busA.add_signal("acknowledged", 0) # do not be lazy you have autocomplete, use full words

Interface_busB = Interface()
Interface_busB.add_signal("address", 0)
Interface_busB.add_signal("data", 0)
Interface_busB.add_signal("acknowledged", 0)
Interface_busB.add_signal("somethingElse", 0)

Interface_IF_ID = Interface()
Interface_IF_ID.add_signal("instruction0", 0)
Interface_IF_ID.add_signal("is_instruction0_nop", 0)

class Core_top(Synchronous):
    def __init__(self):
        self.clock_div = 1 # Clock diviser
        new_input("busA", Interface_busA)
        new_input("busB", Interface_busB)
        new_output("busZ", Interface_otherbus)
        new_output("someRandomPin", 0) # always initialize outputs and states
        new_state("SomeInternalRegister", 0) # Internal state
        new_child("IF", InstructionFetch()) # NEVER use abbreviation even if obvious to you without explaining it at least once
        new_child("ID", InstructionDecode()) # Children also inherit from Synchronous
        # You should not need any other attributes, keep it simple

    def interconnect_children(self):
        # Connecting children together using wires
        # Thanks to the use of Interfaces interconnecting children is easy
        connect(get_child("IF"), get_child("ID")) # connect( OUTPUTS of IF -> INPUTS of ID)
        # At runtimes Interface_IF_ID from IF'ouputs will be connected to Interface_IF_ID from ID'inputs
        connect(get_child("IF").get_output("Bus..."), get_child("ID").get_input("Bus...")) # Alternative: Explicit

    def tick(self):
        """
        This function is called once every self.clock_div clock cycle
        Your ONLY inputs are:
            get_input("busA").get("address")
            get_input("busA").get("data")
            get_input("busA").get("something")
            get_input("busA").get("acknowledged")
            get_input("busB").get("address")
            get_input("busB").get("data")
            get_input("busB").get("acknowledged")
            get_input("busB").get("somethingElse")
            get_output("someRandomPin")
            get_output("busZ").get("...")
            get_state("SomeInternalRegister")
            get_child("IF").get_input("...")
            get_child("IF").get_output("...")
            ...

        You can use normal Python to update values of your outputs for each clock cycle
        Outputs should only be set once, at the very end of the function
        Your ONLY outputs are:
            set_state("SomeInternalRegister", 42)
            set_output("someRandomPin", 42)
            set_output("busZ").set("some bus signal...", 255)
            set_output("busZ", X) # Alternative, with X a Interface_otherbus
            # To access childs inputs/outputs:
            get_child("IF").set_input("...", ...)
            get_child("IF").set_output("...", ...)

        Remember all algorithm performed in this function should occur during a single clock
        cycle. You may want to keep the algorithm simple otherwise your clock may
        need to be very slow for the signal to have enough time to cross all gates.
        """
        # Read inputs
        temporary_variable = get_input("busA").get("data")

        # Do something
        temporary_variable =  temporary_variable + 1
        temporary_variable =  ...


        # Set outputs
        # You should set values only once per clock cycle
        # I recommand to do it at the end of the tick() function
        set_output("busB").set("data", temporary_variable)

        # Toggle a pin every clock cycle
        set_output("someRandomPin", int(not get_output["someRandomPin"]))

        # You can also access child's inputs/outputs using: get_child("IF").set_...
        self.interconnect_children()
