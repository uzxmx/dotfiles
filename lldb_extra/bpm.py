'''
Breakpoint Manager.
'''

import lldb
import os
import string
from six import StringIO as SixStringIO
from datetime import datetime
from lldb_extra import utils

def find_breakpoint_by_name(debugger, name):
    for b in debugger.GetSelectedTarget().breakpoint_iter():
        if b.MatchesName(name):
            return b

# For oneshot, we cannot rely on `breakpoint set -o true`, because the
# manual says "The breakpoint is deleted the first time it stop causes a
# stop". When breakpoint command is used, the breakpoint is only deleted
# when it returns True, but in general we don't want this. So we simulating
# the oneshot behavior by deleting the breakpoint on our own.
def add_breakpoint(debugger, name=None, addr=None, command=None, filename=None, oneshot=False,
        function_name=None, shlib_name=None):
    res = lldb.SBCommandReturnObject()
    interpreter = debugger.GetCommandInterpreter()

    cmd = 'breakpoint set -N %s' % name
    if addr is not None:
        cmd += ' -a %s' % addr
    elif function_name is not None:
        cmd += ' -n %s' % function_name

    if shlib_name is not None:
        cmd += ' -s %s' % shlib_name

    interpreter.HandleCommand(cmd, res)

    if not res.Succeeded():
        print('Failed to set breakpoint %s: \n%s' % (name, res.GetError()))
        return

    if filename is None:
        script = 'bpm.pre_breakpoint_command(frame);'
    else:
        script = 'with bpm.open_file("%s", "a") as file: bpm.pre_breakpoint_command(frame, file, "%s");' % (filename, name)

    if command is not None and len(command) > 0:
        script += ' %s;' % command

    if oneshot:
        script += ' res = lldb.SBCommandReturnObject(); lldb.debugger.GetCommandInterpreter().HandleCommand("breakpoint delete %s", res);' % name

    script += ' return False'

    interpreter.HandleCommand("breakpoint command add -s python -o '%s'" % script, res)

def open_file(path, mode):
    return utils.open_file(path, mode)

def pre_breakpoint_command(frame, file=None, name=None):
    if file is not None:
        msg = '%s Thread: %s' % (str(datetime.now()), frame.GetThread().GetName())
        if name is not None:
            msg += ' Breakpoint: %s' % name
        file.write('==== %s ====\n' % msg)

def bpc_memcpy(frame, file):
    regs = utils.get_GPRs(frame)
    error = lldb.SBError()
    rdi = regs['rdi'].GetData().GetUnsignedInt64(error, 0)
    rsi = regs['rsi'].GetData().GetUnsignedInt64(error, 0)
    rdx = regs['rdx'].GetData().GetUnsignedInt64(error, 0)
    file.write('Src:\n%s' % utils.dump_memory(rsi, rdx))
    file.write('Count: %d\n' % rdx)
    file.write('Dest: 0x%x\n' % rdi)

def bpc_dump_regs(frame, file, *args):
    regs = utils.get_GPRs(frame)
    error = lldb.SBError()
    for arg in args:
        file.write('%s: 0x%x\n' % (arg, regs[arg].GetData().GetUnsignedInt64(error, 0)))

def bpc_dump_stacktrace(frame, file):
    file.write(utils.get_stacktrace(frame.GetThread()))
