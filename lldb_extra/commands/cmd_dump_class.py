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
    Dump a class. The class inherit from a NSObject class.

Examples:
    dump_class NSView
    dump_class UIView
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
        result.SetError('You need to specify a class name.')
        return

    script = utils.get_script(os.path.join(os.path.dirname(__file__), 'dump_class.mm'), { 'class_name': args[0] })

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
        result.SetError("Failed to dump class: %s" % str(expr_sbvalue.error))
        return

    print(str(expr_sbvalue.GetObjectDescription()))

    if stopped_by_us:
        print('The process was automatically interrupted. Please resume it manually.')

def generate_option_parser():
    usage = "usage: %prog <class-name>"
    parser = optparse.OptionParser(usage=usage, prog='dump_class')
    return parser
