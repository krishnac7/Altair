# This file contains all required dependency for Cycle Accurate Simulation in Python
# FIXME make sure parents assess what their clocks are and raise error if incompatible
# FIXME test for clock domain crossing
class Interface:
    def __init(self):
        pass # FIXME initialise attributes

    def add_signal(self, signal_name, initial_value=None, documentation=""):
        """
        Parameters:
            signal_name: name of the signal, it is used to access the signal later in the code and you can find it in dumps
            initial_value: Value of the signal if no other value is assigned to it
            documentation: Explain what is this signal used for

        Add a signal to the internal list of signals.
        It should be called right after the instanciation of an Interface object and never after
        TODO Lock the Interface to forbit adding signal after any other member has been called
        """
        pass # FIXME
    def get(self, signal_name):
        """
        Returns the value of signal named signal_name
        Raises KeyError if no signal for this name can be found
        """
        # TODO raise KeyError("signal_name is wrong")
        pass # FIXME
    def set(self, signal_name, signal_value):
        """
        Set the value of signal signal_name to signal_value (will be effective next clock cycle)
        Raises KeyError if no signal for this name can be found

        This should only be called one time per clock.
        Raises EnvironmentError if set multiple times
        TODO check it is called only once per clock
        """
        # TODO raise KeyError("signal_name is wrong")
        # TODO store next value
        pass # FIXME
    def _tick(self):
        """
        Internally used to update the result of get() and reset set()
        """
        # TODO iterate each childs and make sure their _tick is called (if implemented)
        pass # FIXME


class Synchronous:
    def __init__(self, clock_div=1):
        """
        clock_div, Clock divider: 1 by default => tick() will be called as often as possible, every clock cycle

        You should only use new_input, new_output and new_child in this function
        You should not need any other attribrute
        """
        self.clock_div = clock_div
        pass # FIXME
    

    def new_input(self, signal_name, initial_value):
        """
        Should only be called in __init__()
        """
        self.inputs[signal_name] = initial_value
    def new_output(self, signal_name, initial_value):
        """
        Should only be called in __init__()
        """
        self.outputs[signal_name] = initial_value
    def new_state(self, signal_name, initial_value):
        """
        Should only be called in __init__()
        """
        self.states[signal_name] = initial_value
    def new_child(self, child_name, child_object):
        """
        Should only be called in __init__()
        """
        self.children[child_name] = child_object

    def get_input(self, signal_name):
        """
        Parameters:
            signal_name, name of the signal

        Raises KeyError if no signal for this name can be found

        Return the signal's value
        WARNING: if a the returned signal is an interface is should you should never
        call object.get_input("...").set() NEVER ! (consider it as content)
        use set_input instead
        """
        pass # FIXME
    def get_output(self, signal_name):
        """
        Parameters:
            signal_name, name of the signal

        Raises KeyError if no signal for this name can be found

        Return the signal's value
        WARNING: if a the returned signal is an interface is should you should never
        call object.get_output("...").set() NEVER ! (consider it as content)
        use set_output instead
        """
        pass # FIXME
    def get_state(self, signal_name):
        """
        Parameters:
            signal_name, name of the signal

        Raises KeyError if no signal for this name can be found

        Return the signal's value
        WARNING: if a the returned signal is an interface is should you should never
        call object.get_state("...").set() NEVER ! (consider it as content)
        use set_state instead
        """
        pass # FIXME
    def get_child(self, child_name):
        """
        Parameters:
            child_name, name of the child

        Raises KeyError if no child for this name can be found

        Return the a reference to this child
        """
        pass # FIXME

    def set_state(self, signal_name, signal_value=None):
        """
        Parameters:
            signal_name, name of the signal
            signal_value, Can be used to set integer value

            Raises KeyError if no signal for this name can be found

        Examples:
            object.set_state("registerA", 0x42) # Setting a register
        """
        pass # FIXME
    def set_output(self, signal_name, signal_value=None):
        """
        Parameters:
            signal_name, name of the signal
            signal_value, Can be used to set integer value

            Raises KeyError if no signal for this name can be found

            Returns the a reference to the signal for you to set it's member if it is an Interface

        Examples:
            object.set_output("led_out", 1)
            object.set_output("DataBus").set("ack", 1)
            # DataBus' type is Interface
            # It contains many signals, one of them is ack
            # In this example we set DataBus.ack to 1
        """
        pass # FIXME
    def set_input(self, signal_name, signal_value=None):
        """
        Parameters:
            signal_name, name of the signal
            signal_value, Can be used to set integer value

            Raises KeyError if no signal for this name can be found

            Returns the a reference to the signal for you to set it's member if it is an Interface

        Examples:
            object.set_input("a", 2)
            object.set_input("DataBus").set("data", 897)
            # DataBus' type is Interface
            # It contains many signals, one of them is data
            # In this example we set DataBus.data to 897
        """
        pass # FIXME

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
    def _tick(self):
        """
        Internal function
        Recursively calls tick() from the object and _tick() from it's children
        """
        self.tick()
        for child_name in self.children:
            self.children[child_name]._tick()