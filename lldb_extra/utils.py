import lldb
import os
import string
from six import StringIO as SixStringIO

def isXcode():
    if "unknown" == os.environ.get("TERM", "unknown"):
        return True
    else:
        return False

def getTarget():
    return lldb.debugger.GetSelectedTarget()

def isProcStopped():
    target = getTarget()
    process = target.GetProcess()
    if not process:
        return False

    state = process.GetState()
    if state == lldb.eStateStopped:
        return True
    return False

def attrStr(msg, color='black'):
    if isXcode():
        return msg

    clr = {
    'cyan' : '\033[36m',
    'grey' : '\033[2m',
    'blink' : '\033[5m',
    'redd' : '\033[41m',
    'greend' : '\033[42m',
    'yellowd' : '\033[43m',
    'pinkd' : '\033[45m',
    'cyand' : '\033[46m',
    'greyd' : '\033[100m',
    'blued' : '\033[44m',
    'whiteb' : '\033[7m',
    'pink' : '\033[95m',
    'blue' : '\033[94m',
    'green' : '\033[92m',
    'yellow' : '\x1b\x5b33m',
    'red' : '\033[91m',
    'bold' : '\033[1m',
    'underline' : '\033[4m'
    }[color]
    return clr + msg + ('\x1b\x5b39m' if clr == 'yellow' else '\033[0m')

_loaded_scripts = {}

def get_script(path, options={}):
    if path not in _loaded_scripts:
        with open(path, 'r') as f:
            _loaded_scripts[path] = string.Template(f.read())

    return _loaded_scripts[path].substitute(options)

def get_pointer_size():
    return getTarget().addr_size

def handle_command(debugger, cmd, output=None):
    if output is None:
        debugger.HandleCommand(cmd)
    else:
        saved_output = debugger.GetOutputFile()
        saved_use_color = debugger.GetUseColor()
        debugger.SetUseColor(False)
        debugger.SetOutputFile(output)
        debugger.HandleCommand(cmd)
        debugger.SetOutputFile(saved_output)
        debugger.SetUseColor(saved_use_color)

def print_max_lines(s, max_lines=100):
    lines = s.splitlines()
    total_lines = len(lines)
    for line in lines[:min(total_lines, max_lines)]:
        print(line)
    if total_lines > max_lines:
        print('The output is large (%d lines), only %d lines are printed. To print all lines, use a file instead.' % (total_lines, max_lines))

def render_script_and_evaluate(file, render_opts):
    script = get_script(os.path.join(os.path.dirname(__file__), 'objc', file), render_opts)
    return evaluate_objc(script)

def evaluate_objc(script):
    '''Evaluate Objective-C codes. The returned type is `lldb.SBValue`.
    You can use `format_sbvalue` to get its description.
    '''
    expr_options = lldb.SBExpressionOptions()
    expr_options.SetIgnoreBreakpoints(True)
    expr_options.SetFetchDynamicValue(lldb.eNoDynamicValues)
    expr_options.SetTimeoutInMicroSeconds(30 * 1000 * 1000)
    expr_options.SetTryAllThreads(False)
    expr_options.SetTrapExceptions(False)
    expr_options.SetUnwindOnError(True)
    expr_options.SetGenerateDebugInfo(False)
    expr_options.SetLanguage(lldb.eLanguageTypeObjC_plus_plus)
    expr_options.SetCoerceResultToId(True)
    return getTarget().EvaluateExpression(script, expr_options)

def format_sbvalue(sbvalue):
    if sbvalue.error.success:
        return str(sbvalue.GetObjectDescription())
    else:
        return str(sbvalue.error)

def get_registers(frame, kind):
    '''Return the registers given the frame and the kind of registers desired.

    Return None if there's no such kind.
    '''
    registerSet = frame.GetRegisters() # Return type of SBValueList.
    for value in registerSet:
        if kind.lower() in value.GetName().lower():
            return { r.GetName(): r for r in value }

    return None

def get_GPRs(frame):
    '''Return the general purpose registers of the frame as a dict.
    '''
    return get_registers(frame, 'general purpose')

def get_FPRs(frame):
    '''Return the floating point registers of the frame as a dict.
    '''
    return get_registers(frame, 'floating point')

def get_ESRs(frame):
    '''Return the exception state registers of the frame as a dict.
    '''
    return get_registers(frame, 'exception state')

def resume_execution(frame):
    '''Resume the execution.
    '''
    frame.GetThread().GetProcess().Continue()

def delete_breakpoint(name):
    res = lldb.SBCommandReturnObject()
    getTarget().GetDebugger().GetCommandInterpreter().HandleCommand('break delete %s' % name, res)
    if res.Succeeded() != True:
        print(res.GetError())

def get_module_names(thread):
    '''
    Return a sequence of module names from the stack frames of this thread.
    '''
    def GetModuleName(i):
        return thread.GetFrameAtIndex(
            i).GetModule().GetFileSpec().GetFilename()

    return list(map(GetModuleName, list(range(thread.GetNumFrames()))))

def get_function_names(thread):
    '''
    Return a sequence of function names from the stack frames of this thread.
    '''
    def GetFuncName(i):
        return thread.GetFrameAtIndex(i).GetFunctionName()

    return list(map(GetFuncName, list(range(thread.GetNumFrames()))))

def get_symbol_names(thread):
    '''
    Return a sequence of symbols for this thread.
    '''
    def GetSymbol(i):
        return thread.GetFrameAtIndex(i).GetSymbol().GetName()

    return list(map(GetSymbol, list(range(thread.GetNumFrames()))))

def get_filenames(thread):
    '''
    Return a sequence of file names from the stack frames of this thread.
    '''
    def GetFilename(i):
        return thread.GetFrameAtIndex(
            i).GetLineEntry().GetFileSpec().GetFilename()

    return list(map(GetFilename, list(range(thread.GetNumFrames()))))

def get_line_numbers(thread):
    '''
    Return a sequence of line numbers from the stack frames of this thread.
    '''
    def GetLineNumber(i):
        return thread.GetFrameAtIndex(i).GetLineEntry().GetLine()

    return list(map(GetLineNumber, list(range(thread.GetNumFrames()))))

def get_pc_addresses(thread):
    '''
    Return a sequence of pc addresses for this thread.
    '''
    def GetPCAddress(i):
        return thread.GetFrameAtIndex(i).GetPCAddress()

    return list(map(GetPCAddress, list(range(thread.GetNumFrames()))))

def stop_reason_to_str(enum):
    '''Returns the stopReason string given an enum.'''
    if enum == lldb.eStopReasonInvalid:
        return "invalid"
    elif enum == lldb.eStopReasonNone:
        return "none"
    elif enum == lldb.eStopReasonTrace:
        return "trace"
    elif enum == lldb.eStopReasonBreakpoint:
        return "breakpoint"
    elif enum == lldb.eStopReasonWatchpoint:
        return "watchpoint"
    elif enum == lldb.eStopReasonExec:
        return "exec"
    elif enum == lldb.eStopReasonSignal:
        return "signal"
    elif enum == lldb.eStopReasonException:
        return "exception"
    elif enum == lldb.eStopReasonPlanComplete:
        return "plancomplete"
    elif enum == lldb.eStopReasonThreadExiting:
        return "threadexiting"
    else:
        return "Unknown StopReason enum"

def get_args_as_string(frame, showFuncName=True):
    '''
    Return the args of the input frame object as a string.
    '''
    # arguments     => True
    # locals        => False
    # statics       => False
    # in_scope_only => True
    vars = frame.GetVariables(True, False, False, True)  # type of SBValueList
    args = []  # list of strings
    for var in vars:
        args.append("(%s)%s=%s" % (var.GetTypeName(),
                                   var.GetName(),
                                   var.GetValue()))
    if frame.GetFunction():
        name = frame.GetFunction().GetName()
    elif frame.GetSymbol():
        name = frame.GetSymbol().GetName()
    else:
        name = ""
    if showFuncName:
        return "%s(%s)" % (name, ", ".join(args))
    else:
        return "(%s)" % (", ".join(args))

# From https://github.com/llvm-mirror/lldb/blob/master/packages/Python/lldbsuite/test/lldbutil.py
def get_stacktrace(thread):
    '''Get a simple stack trace of this thread.'''

    output = SixStringIO()
    target = thread.GetProcess().GetTarget()

    depth = thread.GetNumFrames()

    mods = get_module_names(thread)
    funcs = get_function_names(thread)
    symbols = get_symbol_names(thread)
    files = get_filenames(thread)
    lines = get_line_numbers(thread)
    addrs = get_pc_addresses(thread)

    if thread.GetStopReason() != lldb.eStopReasonInvalid:
        desc = "stop reason=" + stop_reason_to_str(thread.GetStopReason())
    else:
        desc = ""
    print(
        "Stack trace for thread id={0:#x} name={1} queue={2} ".format(
            thread.GetThreadID(),
            thread.GetName(),
            thread.GetQueueName()) + desc,
        file=output)

    for i in range(depth):
        frame = thread.GetFrameAtIndex(i)
        function = frame.GetFunction()

        load_addr = addrs[i].GetLoadAddress(target)
        if not function:
            file_addr = addrs[i].GetFileAddress()
            start_addr = frame.GetSymbol().GetStartAddress().GetFileAddress()
            symbol_offset = file_addr - start_addr
            print(
                "  frame #{num}: {addr:#016x} {mod}`{symbol} + {offset}".format(
                    num=i,
                    addr=load_addr,
                    mod=mods[i],
                    symbol=symbols[i],
                    offset=symbol_offset),
                file=output)
        else:
            print(
                "  frame #{num}: {addr:#016x} {mod}`{func} at {file}:{line} {args}".format(
                    num=i,
                    addr=load_addr,
                    mod=mods[i],
                    func='%s [inlined]' %
                    funcs[i] if frame.IsInlined() else funcs[i],
                    file=files[i],
                    line=lines[i],
                    args=get_args_as_string(
                        frame,
                        showFuncName=False) if not frame.IsInlined() else '()'),
                file=output)

    return output.getvalue()

def dump_memory(addr, size):
    res = lldb.SBCommandReturnObject()
    interpreter = getTarget().GetDebugger().GetCommandInterpreter()
    interpreter.HandleCommand('memory read %d -c %d' % (addr, size), res)
    return res.GetOutput()
