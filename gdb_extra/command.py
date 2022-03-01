import abc
import gdb
import optparse

# https://sourceware.org/gdb/onlinedocs/gdb/Commands-In-Python.html#Commands-In-Python

class GenericCommand(gdb.Command, metaclass=abc.ABCMeta):
    """This is an abstract class for invoking commands, should not be instantiated."""

    def __init__(self, *args, **kwargs):
        command_type = kwargs.setdefault("command", gdb.COMMAND_USER)
        complete_type = kwargs.setdefault("complete", gdb.COMPLETE_NONE)
        prefix = kwargs.setdefault("prefix", False)
        super().__init__(self._prog, command_type, complete_type, prefix)

        # TODO
        self._parser = optparse.OptionParser(prog=self._prog, usage=self._usage)

    def invoke(self, args, from_tty):
        argv = gdb.string_to_argv(args)
        (options, args) = self._parser.parse_args(argv)
        self.do_invoke(options, args)

    @abc.abstractproperty
    def _prog(self): pass

    @abc.abstractproperty
    def _usage(self): pass

    @abc.abstractmethod
    def do_invoke(self, options, args): pass

    def usage(self):
        # TODO usage
        pass

    def add_option(self, *args, **kwargs):
        self._parser.add_option(*args, **kwargs)
