import lldb
import optparse
import shlex

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f cmd_dump_module.dump_module dump_module')
    print('The "dump_module" command has been installed.')

# TODO:
#   1. filter by module
#   2. better to dump each module into one file with module name as filename
def dump_module(debugger, command, result, internal_dict):
    '''
    Dump modules.
    '''

    command_args = shlex.split(command)
    parser = generate_option_parser()
    try:
        (options, args) = parser.parse_args(command_args)
    except:
        result.SetError(parser.usage)
        return

    if options.file is None:
        result.SetError('An output file should be specified by `-f` option.')
        return

    with open(options.file, 'w') as f:
        target = debugger.GetSelectedTarget()
        for i, m in enumerate(target.module_iter()):
            if i != 0:
                f.write('\n========================================\n\n')
            f.write('Fullpath: %s\n' % m.file.fullpath)
            f.write('Number of sections: %s\n' % m.num_sections)
            f.write('Number of symbols: %s\n' % m.num_symbols)
            if m.num_symbols > 0:
                f.write('Symbols:\n')
                for sym in m:
                    f.write('%s : 0x%x - 0x%x\n' % (sym.name, sym.addr.GetLoadAddress(target), sym.end_addr.GetLoadAddress(target)))

def generate_option_parser():
    usage = "usage: %prog -f <output-file>"
    parser = optparse.OptionParser(usage=usage, prog='dump_module')
    parser.add_option('-f', '--file',
                      dest='file',
                      help='File to output')

    return parser
