import os
import lldb
import optparse
import shlex
import utils

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f cmd_dump_class.dump_class dump_class')
    print('The "dump_class" command has been installed.')

def dump_class(debugger, command, exe_ctx, result, internal_dict):
    '''
    Dump a class or a list of classes. The class should inherit from NSObject class.

Examples:
    # Dump all loaded classes.
    dump_class -l

    # Dump all loaded classes which inherit NSViewController.
    dump_class -l -p NSViewController

    # Dump a class.
    dump_class NSView

    # Dump variables and methods for instance and class.
    dump_class -a UIView

    # Dump the class to a file.
    dump_class -a NSViewController -f NSViewController.txt
    '''

    stopped_by_us = False
    if not utils.isProcStopped():
        stopped_by_us = True
        debugger.HandleCommand('process interrupt')

    command_args = shlex.split(command)
    parser = generate_option_parser()
    try:
        (options, args) = parser.parse_args(command_args)
    except:
        result.SetError(parser.usage)
        return

    if len(args) == 0:
        if not options.list_all_classes:
            result.SetError('You need to specify a class name or `-l` option.')
            return
        opts = { 'parent_class_name': options.filter_by_parent_class, 'filter_by_parent_class': 1 if options.filter_by_parent_class else 0 }
        script = utils.get_script(os.path.join(os.path.dirname(__file__), 'dump_all_classes.mm'), opts)
    else:
        opts = { 'class_name': args[0], 'enable_class': 1 if options.all else 0 }
        script = utils.get_script(os.path.join(os.path.dirname(__file__), 'dump_class.mm'), opts)

    expr_options = lldb.SBExpressionOptions()
    expr_options.SetIgnoreBreakpoints(True)
    expr_options.SetFetchDynamicValue(lldb.eNoDynamicValues)
    expr_options.SetTimeoutInMicroSeconds(30 * 1000 * 1000)
    expr_options.SetTryAllThreads(False)
    expr_options.SetTrapExceptions(False)
    expr_options.SetUnwindOnError(True)
    expr_options.SetGenerateDebugInfo(True)
    expr_options.SetLanguage(lldb.eLanguageTypeObjC_plus_plus)
    expr_options.SetCoerceResultToId(True)

    expr_sbvalue = utils.getTarget().EvaluateExpression(script, expr_options)

    if not expr_sbvalue.error.success:
        result.SetError("Failed to dump: %s" % str(expr_sbvalue.error))
        return

    if options.file is None:
        utils.print_max_lines(str(expr_sbvalue.GetObjectDescription()))
    else:
        file = open(options.file, 'w')
        file.write(str(expr_sbvalue.GetObjectDescription()))
        file.close()

    if stopped_by_us:
        print('The process was automatically interrupted. Please resume it manually.')

def generate_option_parser():
    usage = "usage: %prog <class-name>"
    parser = optparse.OptionParser(usage=usage, prog='dump_class')
    parser.add_option('-a', '--all',
                      action='store_true',
                      default=False,
                      dest='all',
                      help='Dump variables and methods for instance and class. By default only dump for instance')

    parser.add_option('-l', '--list',
                      action='store_true',
                      default=False,
                      dest='list_all_classes',
                      help='List currently loaded classes')

    parser.add_option('-p', '--parent',
                      dest='filter_by_parent_class',
                      help='Filter by parent class, must be used with -l option')

    parser.add_option('-f', '--file',
                      dest='file',
                      help='File to output')

    return parser
