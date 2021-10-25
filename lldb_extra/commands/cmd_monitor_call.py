import lldb
import optparse
import shlex
from datetime import datetime
from lldb_extra import utils

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f cmd_monitor_call.monitor_call monitor_call')
    print('The "monitor_call" command has been installed.')

def monitor_call(debugger, command, result, internal_dict):
    '''
    Monitor function calls. This records only one call for each function.
    '''

    command_args = shlex.split(command)
    parser = generate_option_parser()
    try:
        (options, args) = parser.parse_args(command_args)
    except:
        result.SetError(parser.usage)
        return

    if len(args) < 1 or args[0] == '':
        print('An output file is required.')
        return

    cmd_opts = ''
    if options.thread_name is not None:
        cmd_opts += ' -T "%s"' % options.thread_name
    if options.module is not None:
        module = debugger.GetSelectedTarget().FindModule(lldb.SBFileSpec(options.module))
        if not module.IsValid():
            result.SetError("Unable to find module '{}', to see list of modules, use 'image list -b'".format(options.module))
            return
        cmd_opts += ' --shlib="%s"' % options.module

    # Act on Dummy breakpoints - i.e. breakpoints set before a file is provided, which prime new targets.
    # cmd_opts += ' -D'

    print('Set breakpoint by `--func-regex`. It may cost much time if there are many symbols.')
    debugger.HandleCommand('breakpoint set --func-regex=. %s' % cmd_opts)
    debugger.HandleCommand('breakpoint command add -s python -o "cmd_monitor_call.dump_call(\'%s\', frame, bp_loc); return False"' % args[0])

def dump_call(path, frame, bp_loc):
    with utils.open_file(path, 'a') as f:
        f.write("%s: %s\n" % (str(datetime.now()), frame.GetFunctionName()))
        bp_loc.SetEnabled(False)

def generate_option_parser():
    usage = "usage: %prog <output-file>"
    parser = optparse.OptionParser(usage=usage, prog='monitor_call')

    parser.add_option('-T', '--thread-name',
                      dest='thread_name',
                      help='Monitor function calls for a thread')

    parser.add_option('-m', '--module',
                      dest='module',
                      help='Monitor function calls for a module')

    return parser
