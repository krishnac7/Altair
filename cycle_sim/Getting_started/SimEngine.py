# This file contains all required dependency for Cycle Accurate Simulation in Python
# If you run this file as your main it will run the unit tests

###############################################################################

class LatchSetTemplate:
    """
    Used to create LatchSetRW and/or LatchSetRO
    They can be automatically wired together with the Synchronous::connect_bus() call
    """
    def __init__(self):
        self.signals = {}
        self.documentation = {}
    def add_signal(self, signal_name, default_values=0, documentation=""):
        if signal_name in self.signals:
            raise EnvironmentError("Signal's name already in use, you should not try to add a signal twice")
            return None
        self.signals[signal_name] = default_values
        self.documentation[signal_name] = documentation
    def _modify_LatchSetRW(self, latchset):
        a = object.__getattribute__(latchset, "signals")
        b = object.__getattribute__(latchset, "new_signals")
        c = object.__getattribute__(latchset, "documentation")
        for sig in self.signals:
            a[sig] = self.signals[sig]
            b[sig] = self.signals[sig]
            c[sig] = self.documentation[sig]
    def _modify_LatchSetRO(self, latchset):
        a = object.__getattribute__(latchset, "links")
        for sig in self.signals:
            a[sig]=None # Default returned value on an open input = None

# TODO test

# FIXME make sure parents assess what their clocks are and raise error if incompatible
# FIXME test for clock domain crossing
class LatchSetRW:
    # TODO connect taking an LatchSetRO as input so we can do busB.connect_to(busC)
    """
    Used to group signals together
    TODO example
    """
    def __init__(self, template=None):
        # We cannot use attribute = ... because we overwrote object.__setattr__
        object.__setattr__(self, "no_add_signal", False) # We can add signal
        object.__setattr__(self, "signals", {}) # Value of the signal as returned by getattribute
        object.__setattr__(self, "new_signals", {}) # Value written by setattr, used to update signals when _tick is called
        object.__setattr__(self, "documentation",  {})
        object.__setattr__(self, "signal_set_this_cycle",  [])

        # Add signals according to template (optional)
        if template != None:
            template._modify_LatchSetRW(self)


    def add_signal(self, signal_name, initial_value=None, documentation=""):
        """
        Parameters:
            signal_name: name of the signal, it is used to access the signal later in the code and you can find it in dumps
            initial_value: Value of the signal if no other value is assigned to it
            documentation: Explain what is this signal used for


        Add a signal to the internal list of signals.
        It should be called right after the instanciation of an LatchSetRW object and never after
        Raises EnvironmentError if you try to call this function after any
        other function as been called

        Raises EnvironmentError if you try to add twice the same signal

        TODO check we do not add a child called add_signal or _tick
        """
        if object.__getattribute__(self, "no_add_signal"):
            raise EnvironmentError("You can no longer add signals to an LatchSetRW once simulation started")
            return None
        if signal_name in object.__getattribute__(self, "signals"):
            raise EnvironmentError("Signal as already been added to this LatchSetRW, you should not try to add a signal twice")
            return None
        object.__getattribute__(self, "signals")[signal_name] = initial_value
        object.__getattribute__(self, "new_signals")[signal_name] = initial_value
        object.__getattribute__(self, "documentation")[signal_name] = documentation
    def __getattribute__(self, signal_name):
        """
        This function is called automatically when an attribute (signal) is
        accessed.

        Returns the value of signal named signal_name
        Raises AttributeError if no signal for this name can be found
        """
        # Allow some methods to be called
        if signal_name == "add_signal":
            return object.__getattribute__(self, signal_name)
        object.__setattr__(self, "no_add_signal", True) # We can no longer add signals
        if signal_name == "_tick":
            return object.__getattribute__(self, signal_name)

        #print("getattr {}".format(signal_name)) # TODO remove debugging
        if not signal_name in object.__getattribute__(self, "signals"):
            raise AttributeError("Signal's name is wrong or signal is not declared, see LatchSetRW.add_signal()")
        return object.__getattribute__(self, "signals")[signal_name]

    def __setattr__(self, signal_name, signal_value):
        """
        This function is called automatically when an attribute (signal) is
        accessed.

        Set the value of signal signal_name to signal_value (will be effective next clock cycle)
        Raises KeyError if no signal for this name can be found

        This should only be called one time per clock.
        Raises EnvironmentError if set multiple times
        TODO check it is called only once per clock
        """
        #print("setattr {} <= {}".format(signal_name, signal_value)) # TODO remove debugging
        object.__setattr__(self, "no_add_signal", True) # We can no longer add signals
        if not signal_name in object.__getattribute__(self, "new_signals"):
            raise AttributeError("Signal's name is wrong or signal is not declared, see LatchSetRW.add_signal()")
        if signal_name in object.__getattribute__(self, "signal_set_this_cycle"):
            raise EnvironmentError("Signal as already be set this cycle")
        object.__getattribute__(self, "new_signals")[signal_name] = signal_value
        object.__getattribute__(self, "signal_set_this_cycle").append(signal_name)

    def _tick(self):
        """
        Internally used to update the return values of get() and reset set()
        """
        #print("Clearing signal_set_this_cycle") # TODO remove debug messages
        object.__getattribute__(self, "signal_set_this_cycle").clear() # __setattr__ can now be called again on every signals
        # Move values from new_signals (setted by __setattr__) to signals
        for name in object.__getattribute__(self, "signals"):
            object.__getattribute__(self, "signals")[name] = object.__getattribute__(self, "new_signals")[name]


import unittest
class TestLatchSetRW(unittest.TestCase):
    """
    Unit testing of LatchSetRW objects

    TODO test adding a child called no_add_signal, signals, new_signals, documentation, signal_set_this_cycle
    """
    def test_normal_usage(self):
        tmp = LatchSetRW()
        tmp.add_signal("siga")
        tmp.add_signal("sigb", 2348)
        tmp.add_signal("sigc", 8734, "Some documentation")
        self.assertEqual(tmp.siga, None, "Should set signal to None when no default value is provided")
        self.assertEqual(tmp.sigb, 2348, "Should return the signal's value")
        self.assertEqual(tmp.sigc, 8734, "Should return the signal's value even if documentation is provided")
        tmp.siga = 42
        tmp.sigb = 62
        tmp.sigc = 8973
        self.assertEqual(tmp.siga, None, "Signal value should not change before the end of the clock cycle")
        self.assertEqual(tmp.sigb, 2348, "Signal value should not change before the end of the clock cycle")
        self.assertEqual(tmp.sigc, 8734, "Signal value should not change before the end of the clock cycle")
        tmp._tick()
        self.assertEqual(tmp.siga, 42, "Should be updated")
        self.assertEqual(tmp.sigb, 62, "Should be updated")
        self.assertEqual(tmp.sigc, 8973, "Should be updated")

    # Check add_signal error handling
    def test_adding_signal_twice(self):
        tmp = LatchSetRW()
        tmp.add_signal("siga")
        with self.assertRaises(EnvironmentError):
            tmp.add_signal("siga")
        tmp._tick()
        with self.assertRaises(EnvironmentError):
            tmp.add_signal("siga")
    def test_adding_signal_after_use(self):
        tmp = LatchSetRW()
        tmp.add_signal("siga")
        tmp.siga = 42
        with self.assertRaises(EnvironmentError):
            tmp.add_signal("sigb")
        tmp._tick()
        with self.assertRaises(EnvironmentError):
            tmp.add_signal("sigb")

    # Check getter error handling
    def test_getting_non_existant_signal(self):
        tmp = LatchSetRW()
        with self.assertRaises(AttributeError):
            foo = tmp.siga


    # Check setter error handling
    def test_setting_non_existant_signal(self):
        tmp = LatchSetRW()
        with self.assertRaises(AttributeError):
            tmp.siga = 42
    def test_setting_signal_twice(self):
        tmp = LatchSetRW()
        tmp.add_signal("siga")
        tmp.siga = 42
        with self.assertRaises(EnvironmentError):
            tmp.siga = 834
        tmp._tick()
        tmp.siga = 83421

###############################################################################

class LatchSetRO:
    # TODO connect taking an LatchSetRW as input so we can do busB.connect_to(busC)
    def __init__(self, template=None):
        object.__setattr__(self, "no_add_signal", False) # We can add signal
        object.__setattr__(self, "links", {})
        object.__setattr__(self, "connectedTo", None)

        # Using a template
        if template != None:
            template._modify_LatchSetRO(self)
    def add_signal(self, signal_name):
        """
        Raises EnvironmentError if the Object as already be used and no more
        signal should be added

        Raises EnvironmentError if the signal's name is not unique (already in
        use)

        If the "link" is never connected to any source it will return None
        (Open Input)
        """
        if object.__getattribute__(self, "no_add_signal"):
            raise EnvironmentError("You can no longer add signal once you started using it")
            return None
        if signal_name in object.__getattribute__(self, "links"):
            raise EnvironmentError("Signal's name already in use, use unique signal names")
            return None
        object.__getattribute__(self, "links")[signal_name] = None # Open input
    def connect_to(self, latchset):
        """
        Raises EnvironmentError if latchset is not of type LatchSetRW

        Raises EnvironmentError if the output latchSet doesn't match our
        expected outputs

        Raises EnvironmentError if you try to use this function after any
        attribute
        """
        if object.__getattribute__(self, "no_add_signal"):
            raise EnvironmentError("You can no longer add signal once you started using it")
            return None
        if not type(latchset) == LatchSetRO:
            raise EnvironmentError("Why do you want to connect two inputs together? You should not do that")
        if not type(latchset) == LatchSetRW:
            raise EnvironmentError("The output you try to connect this input with is not of type LatchSetRW")
        for lname in object.__getattribute__(latchset, "signals"):
            if not lname in object.__getattribute__(self, "links"):
                print("Error: Output contains too many signals, please use LatchSetTemplate to initilize latchsets")
                raise EnvironmentError("Output (bus) do not match the input you try to connect it to")
        for lname in object.__getattribute__(self, "links"):
            if not lname in object.__getattribute__(latchset, "signals"):
                print("Error: Output does not contain all the signal the input is expecting, please use LatchSetTemplate to initilize latchsets")
                raise EnvironmentError("Output (bus) do not match the input you try to connect it to")
        object.__setattr__(self, "connectedTo", latchset) # We connect to the output
    def __getattribute__(self, signal_name):
        # Allow some methods to be called
        if signal_name == "add_signal":
            return object.__getattribute__(self, signal_name)
        object.__setattr__(self, "no_add_child", True) # We can no longuer add signal
        if signal_name == "connect_to":
            return object.__getattribute__(self, signal_name)
        if object.__getattribute__(self, "connectedTo") != None:
            # Fetch the value from the connected output
            return object.__getattribute__(self,
                    "connectedTo").__getattribute__(signal_name)


    # TODO setter that returns an error because inputs are readonly
    # TODO, getter which fetch value from linked Output, returns an error if no linked output

class LatchSetCollection:
    def add_bus():
        pass # TODO add a bus
    # TODO getter to access a bus directly with it's name
    # TODO setter returning an error (should use add_bus)

class Synchronous:
    """
    TODO Description
    TODO example
    """
    # TODO connect_bus to do connect_bus(outputbus, inputbus)
    def __init__(self):
        """
        End user should only use new_input, new_output and add_child in this function
        he should not need any other attribrute
        """
        self.inputs_bus = LatchSetCollection()
        self.outputs_bus = LatchSetCollection()

        # Attributes which are not Buses
        self.inputs = LatchSetRO()
        self.outputs = LatchSetRW()
        self.states = LatchSetRW()

        self.children = {}
        self.children_doc = {}

        self._no_add_child = False # We can add children
        self.init()

    def init(self):
        """
        Should be implemented by child.
        Each child should declare signals and children here
        """
        print("Error, you should implement init() to declared your inputs, outputs, children");
        pass

    def add_child(self, child_name, child_object, documentation=""):
        """
        Should only be called in __init__()

        Raises EnvironmentError if you try to add a child after using the
        function

        Raises EnvironmentError if you try to add a child twice or if you try
        to add two children with the same name

        TODO Check we do not add a child called inputs, outputs, states, tick
        or _tick
        """
        if self._no_add_child:
            raise EnvironmentError("You can no longer add child to a Synchronous block once simulation started")
            return None
        if child_name in self.children:
            raise EnvironmentError("Child's name is already in use, you should not use the same name twice")
            return None
        self.children[child_name] = child_object
        self.children_doc[child_name] = documentation

    def tick(self):
        """
        Should be implemented by child
        Automatically called every self.clock_div clock cycle.
        Need to be implemented by all children.
        All children must use this function to update they internal states and outputs.

        Remember:
        You should only use
        """
        print("Error: Synchronous.py Synchronous is a base class, you should inherit from it and not call Synchronous.tick directly");
    def _recursive_update_signals(self):
        """
        Internally used to update all signals recursively
        """
        self.inputs._tick()
        self.outputs._tick()
        self.states._tick()
        for child_name in self.children:
            self.children[child_name]._recursive_update_signals()

    def _tick(self):
        """
        Internal function
        Recursively calls tick() from the object and _tick() from it's children
        """
        #print("_tick: New clock") # TODO remove debug messages
        self._no_add_child = True
        self.tick()
        for child_name in self.children:
            self.children[child_name]._tick()

    def simulate_one_cycle(self):
        self._tick() # Recursive, update all new_inputs, new_outputs, new_states
        self._recursive_update_signals() # Recursive, update all inputs, outputs, states at the end of the clock cycle

import unittest
class TestSynchronous(unittest.TestCase):
    """
    Unit testing of Synchronous objects
    """
    def test_normal_usage(self):
        class Or(Synchronous):
            def init(self):
                self.inputs.add_signal("ia", 0, "documentation test")
                self.inputs.add_signal("ib", 0)
                self.outputs.add_signal("o")
                self.states.add_signal("register", 0)

                # TODO test add_child
            def tick(self):
                self.outputs.o = self.inputs.ia or self.inputs.ib
                self.states.register = self.inputs.ia and self.inputs.ib
        dut = Or() # Device Under Test
        dut.simulate_one_cycle()
        self.assertEqual(dut.outputs.o, 0, "Default inputs 0 or 0 = 0")
        self.assertEqual(dut.states.register, 0, "Default inputs 0 and 0 = 0")
        dut.simulate_one_cycle()
        #dut.inputs.ia = 1
        #self.assertEqual(dut.outputs.o, 0, "inputs should remain the same")
        #self.assertEqual(dut.states.register, 0, "Default inputs 0 and 0 = 0")
        #dut.simulate_one_cycle()
        #self.assertEqual(dut.outputs.o, 1, "1 or 0 = 1")
        #self.assertEqual(dut.states.register, 0, "1 and 0 = 0")

# TODO Interconnect children
# FIXME make sure no extra cycle is added
# FIXME Are Inputs support to be latches ? Maybe now FIXME FIXME FIXME
# FIXME Should we use readonly input ?

if __name__ == '__main__':
    unittest.main()
