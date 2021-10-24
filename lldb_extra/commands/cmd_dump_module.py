import lldb
import optparse
import shlex
import os

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f cmd_dump_module.dump_module dump_module')
    print('The "dump_module" command has been installed.')

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

    target = debugger.GetSelectedTarget()
    if options.all:
        for m in target.module_iter():
            do_dump_module(target, m, options.output_dir)
    elif len(args) > 0:
        for e in args:
            module = target.FindModule(lldb.SBFileSpec(e))
            if not module.IsValid():
                result.SetError("Unable to find module '{}', to see list of modules, use 'image list -b'".format(e))
                return
            do_dump_module(target, module, options.output_dir)
    else:
        result.SetError('You should either pass in module names or specify `-a` to dump all modules. (Hint: use `image list -b` to get all modules)')

def do_dump_module(target, m, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    filename = '%s__%s' % (m.file.basename, m.uuid)
    with open(os.path.join(output_dir, filename), 'w') as f:
        f.write('Fullpath: %s\n' % m.file.fullpath)
        f.write('Number of sections: %s\n' % m.num_sections)
        f.write('Number of symbols: %s\n' % m.num_symbols)
        if m.num_symbols > 0:
            f.write('Symbols:\n')
            for sym in m:
                f.write('%s : 0x%x - 0x%x\n' % (sym.name, sym.addr.GetLoadAddress(target), sym.end_addr.GetLoadAddress(target)))

def generate_option_parser():
    usage = "usage: %prog [module-name]..."
    parser = optparse.OptionParser(usage=usage, prog='dump_module')
    parser.add_option('-a', '--all',
                      action='store_true',
                      default=False,
                      dest='all',
                      help='Dump all modules, one module per file, with module name and uuid as filename')

    parser.add_option('-d', '--output-dir',
                      dest='output_dir',
                      default='modules',
                      help='The directory to output files, default is `modules`')

    return parser
