# This file contains all required dependency for Cycle Accurate Simulation in Python
# If you run this file as your main it will run the unit tests

###############################################################################

class LatchSetTemplate:
    """
    Used to create LatchSet and/or WireSet
    They can be automatically wired together with the WireSet::connect(LatchSet) call
    """
    def __init__(self):
        self.signals = {}
        self.documentation = {}
    def new(self, signal_name, default_values=0, documentation=""):
        if signal_name in self.signals:
            raise EnvironmentError("Signal's name already in use, you should not try to add a signal twice")
            return None
        self.signals[signal_name] = default_values
        self.documentation[signal_name] = documentation
    def _append_to_LatchSet(self, latchset):
        a = object.__getattribute__(latchset, "signals")
        b = object.__getattribute__(latchset, "new_signals")
        c = object.__getattribute__(latchset, "documentation")
        for sig in self.signals:
            a[sig] = self.signals[sig]
            b[sig] = self.signals[sig]
            c[sig] = self.documentation[sig]
    def _append_to_WireSet(self, latchset):
        a = object.__getattribute__(latchset, "parents")
        b = object.__getattribute__(latchset, "signals")
        for sig in self.signals:
            a[sig]=None # Default returned value on an open input = None
            b[sig]=None

import unittest
class TestLatchSetTemplate(unittest.TestCase):
    def test_normal_usage(self):
        # TODO
        pass
###############################################################################

# FIXME make sure parents assess what their clocks are and raise error if incompatible
# FIXME test for clock domain crossing
class LatchSet:
    # TODO connect taking an WireSet as input so we can do busB.connect(busC)
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
            template._append_to_LatchSet(self)


    def new(self, signal_name, initial_value=None, documentation=""):
        """
        Parameters:
            signal_name: name of the signal, it is used to access the signal later in the code and you can find it in dumps
            initial_value: Value of the signal if no other value is assigned to it
            documentation: Explain what is this signal used for


        Add a signal to the internal list of signals.
        It should be called right after the instanciation of an LatchSet object and never after
        Raises EnvironmentError if you try to call this function after any
        other function as been called

        Raises EnvironmentError if you try to add twice the same signal

        TODO check we do not add a child called new or _tick
        """
        if object.__getattribute__(self, "no_add_signal"):
            raise EnvironmentError("You can no longer add signals to an LatchSet once simulation started")
            return None
        if signal_name in object.__getattribute__(self, "signals"):
            raise EnvironmentError("Signal as already been added to this LatchSet, you should not try to add a signal twice")
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
        if signal_name == "new":
            return object.__getattribute__(self, signal_name)
        object.__setattr__(self, "no_add_signal", True) # We can no longer add signals
        if signal_name == "_tick":
            return object.__getattribute__(self, signal_name)
        if signal_name == "__getattribute__":
            return object.__getattribute__(self, signal_name)

        #print("getattr {}".format(signal_name)) # TODO remove debugging
        if not signal_name in object.__getattribute__(self, "signals"):
            print("Error: Signal {} cannot be found".format(signal_name))
            print("Available signals are:")
            for val in object.__getattribute__(self, "signals"):
                print(" - {}".format(val))
            raise AttributeError("Signal's name is wrong or signal is not declared, see LatchSet.new()")
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
        #print("List of signals already set:")
        #for val in object.__getattribute__(self, "signal_set_this_cycle"):
        #    print(" - {}".format(val))
        #print("setattr {} <= {}".format(signal_name, signal_value)) # TODO remove debugging
        object.__setattr__(self, "no_add_signal", True) # We can no longer add signals
        if not signal_name in object.__getattribute__(self, "new_signals"):
            raise AttributeError("Signal's name is wrong or signal is not declared, see LatchSet.new()")
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
class TestLatchSet(unittest.TestCase):
    """
    Unit testing of LatchSet objects

    TODO test adding a child called no_add_signal, signals, new_signals, documentation, signal_set_this_cycle
    """
    def test_normal_usage(self):
        tmp = LatchSet()
        tmp.new("siga")
        tmp.new("sigb", 2348)
        tmp.new("sigc", 8734, "Some documentation")
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

    # Check new error handling
    def test_adding_signal_twice(self):
        tmp = LatchSet()
        tmp.new("siga")
        with self.assertRaises(EnvironmentError):
            tmp.new("siga")
        tmp._tick()
        with self.assertRaises(EnvironmentError):
            tmp.new("siga")
    def test_adding_signal_after_use(self):
        tmp = LatchSet()
        tmp.new("siga")
        tmp.siga = 42
        with self.assertRaises(EnvironmentError):
            tmp.new("sigb")
        tmp._tick()
        with self.assertRaises(EnvironmentError):
            tmp.new("sigb")

    # Check getter error handling
    def test_getting_non_existant_signal(self):
        tmp = LatchSet()
        with self.assertRaises(AttributeError):
            foo = tmp.siga


    # Check setter error handling
    def test_setting_non_existant_signal(self):
        tmp = LatchSet()
        with self.assertRaises(AttributeError):
            tmp.siga = 42
    def test_setting_signal_twice(self):
        tmp = LatchSet()
        tmp.new("siga")
        tmp.siga = 42
        with self.assertRaises(EnvironmentError):
            tmp.siga = 834
        tmp._tick()
        tmp.siga = 83421
        tmp._tick()
        tmp.siga = 879
        tmp._tick()
        tmp.siga = 23

###############################################################################

class WireSet:
    # TODO connect taking an LatchSet as input so we can do busB.connect(busC)
    def __init__(self, template=None):
        object.__setattr__(self, "no_add_signal", False) # We can add signal
        object.__setattr__(self, "parents", {}) # Key: name of the signal, data: object whom attribute we have to fetch
        object.__setattr__(self, "signals", {}) # Key: name of the signal, data: name of the attribute we need to fetch from the parent

        # Using a template
        if template != None:
            template._append_to_WireSet(self)
    def new(self, signal_name):
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
        if signal_name in object.__getattribute__(self, "parents"):
            raise EnvironmentError("Signal's name already in use, use unique signal names")
            return None
        # List of objects and the name of their child
        # None for open inputs
        object.__getattribute__(self, "parents")[signal_name] = None # Open input
        object.__getattribute__(self, "signals")[signal_name] = ""
    def connect(self, linkname_or_rwset, parent=None, pointer=None):
        """
        TODO
        """
        # Test if linkname_or_rwset is a rwset
        if parent is None:
            if type(linkname_or_rwset) != LatchSet:
                raise EnvironmentError("If you call connect with a single argument is has to be a LatchSet (aka output)")
            # Connect as all signals from linkname_or_rwset to our this object
            # This object should already contain the signal's entry and the
            # names should match
            # Raises error if all outputs cannot be connected
            for toadd in object.__getattribute__(linkname_or_rwset, "signals"):
                if not toadd in object.__getattribute__(self, "parents"):
                    print("Error: Trying to connect inputs_bus to an outputs_bus")
                    print("output signal: {} cannot be found in inputs".format(toadd))
                    raise EnvironmentError("Inputs and Outputs sets do not match, use LatchSetTemplate to initialize them")
                if object.__getattribute__(self, "parents") is None:
                    print("Error while wiring bus, input {} already connected to {}/{}".format(toadd, object.__getattribute__(self, "parents")[toadd], object.__getattribute__(self, "signals")[toadd])) # TODO remove
                    raise EnvironmentError("Input has already been set, you should not set the same input twice, maybe you already connected it explicitely and you are now trying to map it to a bus")
                if not toadd in object.__getattribute__(linkname_or_rwset, "signals"):
                    raise EnvironmentError("Output's signal {} does not exists".format(toadd))
                object.__getattribute__(self, "parents")[toadd] = linkname_or_rwset
                object.__getattribute__(self, "signals")[toadd] = toadd
            return


        # linkname_or_rwset is a linkname
        # Connect self.linkname_or_rwset to parent.pointer
        if pointer is None:
            raise EnvironmentError("pointer needs to be set, it is the name of the signal from the outputs (aka parent) you want your input to be connected to")
        if not linkname_or_rwset in object.__getattribute__(self, "parents"):
            raise EnvironmentError("signal does not exists in the input, see WireSet.new")
        # TODO check the signal exists in the output side (such error may be
        # difficult to debug)
        if not object.__getattribute__(self, "parents")[linkname_or_rwset] is None:
            raise EnvironmentError("This input is already wired, you cannot wire it twice")
        object.__getattribute__(self, "parents")[linkname_or_rwset] = parent
        object.__getattribute__(self, "signals")[linkname_or_rwset] = pointer

    def __getattribute__(self, signal_name):
        """
        Raises EnvironmentError if the signal does not exists
        Raises EnvironmentError if the signal exists but is not connected to
        any source (open input)
        """
        # Allow some methods to be called
        if signal_name == "new":
            return object.__getattribute__(self, signal_name)
        object.__setattr__(self, "no_add_child", True) # We can no longuer add signal
        if signal_name == "connect":
            return object.__getattribute__(self, signal_name)
        if signal_name == "__getattribute__":
            return object.__getattribute__(self, signal_name)

        if not signal_name in object.__getattribute__(self, "parents"):
            raise EnvironmentError("This signal doesn't exist, see WireSet::new")
        if object.__getattribute__(self, "parents")[signal_name] is None:
            raise EnvironmentError("This is an open input, the signal is not connected, you should not read from it")
        # Fetch value from the parents.signals
        return object.__getattribute__(self, "parents")[signal_name].__getattribute__(object.__getattribute__(self, "signals")[signal_name])

    def __setattr__(self, attrname, attrvalue):
        """
        Raises EnvironmentError because this set is readonly
        """
        raise EnvironmentError("This is read only")

import unittest
class TestLatchSetRO(unittest.TestCase):
    def test_normal_usage(self):
        somebus = WireSet()
        somebus.new("ia")
        self.ia_driver = 8
        somebus.connect("ia", self, "ia_driver")
        self.assertEqual(somebus.ia, 8, "Should read value from 'output'")
        self.ia_driver = 42
        self.assertEqual(somebus.ia, 42, "Should update value from 'output'")


###############################################################################

class LatchSetCollection:
    def new(self, bus_name, bus_template):
        self.__setattr__(bus_name, LatchSet(bus_template))
    # TODO setter returning an error (should use new)

class WireSetCollection:
    def new(self, bus_name, bus_template):
        self.__setattr__(bus_name, WireSet(bus_template))

class SynchronousCollection:
    def new(self, name, childobj):
        self.__setattr__(name, childobj)


###############################################################################

class Synchronous:
    """
    TODO Description
    TODO example
    """
    # TODO connect_bus to do connect_bus(outputbus, inputbus)
    def __init__(self):
        self.inputs_bus = WireSetCollection()
        self.outputs_bus = LatchSetCollection()

        # Attributes which are not Buses
        self.inputs = WireSet()
        self.outputs = LatchSet()
        self.states = LatchSet()

        self.children = SynchronousCollection()

        self._no_add_child = False # We can add children
        self.init()

    def init(self):
        """
        Should be implemented by child.
        Each child should declare signals and children here
        """
        print("Error, you should implement init() to declared your inputs, outputs, children");
        pass
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
        for outp in self.outputs_bus.__dict__:
            self.outputs_bus.__dict__[outp]._tick()
        self.outputs._tick()
        self.states._tick()
        for child_name in self.children.__dict__:
            self.children.__dict__[child_name]._recursive_update_signals()

    def _tick(self):
        """
        Internal function
        Recursively calls tick() from the object and _tick() from it's children
        """
        #print("_tick: New clock") # TODO remove debug messages
        self._no_add_child = True
        self.tick()
        for child_name in self.children.__dict__:
            self.children.__dict__[child_name]._tick()

    def simulate_one_cycle(self):
        self._tick() # Recursive, update all new_inputs, new_outputs, new_states
        self._recursive_update_signals() # Recursive, update all inputs, outputs, states at the end of the clock cycle

    def simulate(self, cycles=1, vcd=None):
        if not vcd is None:
            pass # TODO


import unittest
class TestSynchronous(unittest.TestCase):
    """
    Unit testing of Synchronous objects
    """
    def test_normal_usage(self):
        class Or(Synchronous):
            def init(self):
                self.inputs.new("ia")
                self.inputs.new("ib")
                self.outputs.new("o")
                self.states.new("register", 0)
                # TODO
            def tick(self):
                self.outputs.o = self.inputs.ia or self.inputs.ib
                self.states.register = self.inputs.ia and self.inputs.ib

        dut = Or() # Device Under Test

        # Initial state
        self.test_a = 0
        self.test_b = 0
        dut.inputs.connect("ia", self, "test_a")
        dut.inputs.connect("ib", self, "test_b")

        # Simulate one clock
        dut.simulate_one_cycle()
        self.assertEqual(dut.outputs.o, 0, "default inputs 0 or 0 = 0")
        self.assertEqual(dut.states.register, 0, "Default inputs 0 and 0 = 0")

        # Change inputs
        self.test_a = 3
        self.test_b = 1
        # Not change before next clock
        self.assertEqual(dut.outputs.o, 0, "default inputs 0 or 0 = 0")
        self.assertEqual(dut.states.register, 0, "Default inputs 0 and 0 = 0")
        dut.simulate_one_cycle()
        self.assertEqual(dut.outputs.o, 3, "default inputs 0 or 1 = 1")
        self.assertEqual(dut.states.register, 1, "Default inputs 0 and 1 = 0")

# TODO Interconnect children

if __name__ == '__main__':
    unittest.main()
