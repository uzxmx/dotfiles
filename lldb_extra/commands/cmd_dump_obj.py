import os
import lldb
import optparse
import shlex
import utils

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f cmd_dump_obj.dump_obj dump_obj')
    print('The "dump_obj" command has been installed.')

def dump_obj(debugger, command, exe_ctx, result, internal_dict):
    '''
    Dump an object.

Examples:
    # Dump an object whose pointer is `0x103d82480`.
    dump_obj 0x103d82480

    # Dump to a file.
    dump_obj 0x103d82480 -f obj.txt
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
        result.SetError('You need to specify an address.')
        return

    opts = { 'obj_pointer': args[0] }

    script = utils.get_script(os.path.join(os.path.dirname(__file__), 'dump_obj.mm'), opts)

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
        result.SetError("Failed to dump object: %s" % str(expr_sbvalue.error))
        return

    if options.file is None:
        print(str(expr_sbvalue.GetObjectDescription()))
    else:
        file = open(options.file, 'w')
        file.write(str(expr_sbvalue.GetObjectDescription()))
        file.close()

    if stopped_by_us:
        print('The process was automatically interrupted. Please resume it manually.')

def generate_option_parser():
    usage = "usage: %prog <obj-address>"
    parser = optparse.OptionParser(usage=usage, prog='dump_obj')
    parser.add_option('-f', '--file',
                      dest='file',
                      help='File to output')

    return parser