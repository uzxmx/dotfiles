'''
Add below command to `.lldbinit` file:

```
command script import lldb_extra/patch/patch_core_foundation.py
```
'''

import lldb

def __lldb_init_module(debugger, internal_dict):
    res = lldb.SBCommandReturnObject()
    interpreter = debugger.GetCommandInterpreter()
    interpreter.HandleCommand('breakpoint set -N __CFRunLoopServiceMachPort -n __CFRunLoopServiceMachPort -s CoreFoundation', res)
    interpreter.HandleCommand("breakpoint command add -s python -o 'return patch_core_foundation.patch_runloop(frame)'", res)

def patch_runloop(frame):
    target = frame.GetThread().GetProcess().GetTarget()
    addr = target.FindSymbols('__CFRunLoopServiceMachPort').symbols[0].addr.GetLoadAddress(target) + 787
    debugger = target.GetDebugger()
    interpreter = debugger.GetCommandInterpreter()
    res = lldb.SBCommandReturnObject()
    # TODO check the instructions to see if it should be patched.
    interpreter.HandleCommand("memory write %s 0x90 0x90" % addr, res)
    print('__CFRunLoopServiceMachPort patched')
    interpreter.HandleCommand("break delete __CFRunLoopServiceMachPort", res)
    return False
