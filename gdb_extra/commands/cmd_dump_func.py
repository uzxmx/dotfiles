import gdb
import optparse
import shlex
from gdb_extra.command import GenericCommand

class CmdDumpFunc(GenericCommand):
    """Dump function into a file."""
    _prog = "dump_func"
    _usage = '''usage: %prog
    '''

    def __init__(self):
        super().__init__()
        self.add_option('-d', '--dir', dest='dir', help='directory to store the generated file')
        self.add_option('-f', '--file', dest='file', help='path to the generated file, can be used w/o `-d` option')

    def do_invoke(self, options, args):
        if len(args) == 0:
            self.usage()
            return
        gdb.execute('disassemble %s' % args[0])

CmdDumpFunc()
