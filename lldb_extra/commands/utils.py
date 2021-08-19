import lldb
import os
import string

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
