import os
import lldb
import optparse
import shlex
import utils

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f cmd_dump_block.dump_block dump_block')
    print('The "dump_block" command has been installed.')

def dump_block(debugger, command, exe_ctx, result, internal_dict):
    '''
    Dump an objective-c block.

Examples:
    # Dump a block whose pointer is `0x103c63910`.
    dump_block 0x103c63910

    # Dump to a file.
    dump_block 0x103c63910 -f block.txt
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

    output = None
    if options.file is not None:
        output = lldb.SBFile.Create(open(options.file, 'w'))

    try:
        process = utils.getTarget().GetProcess()
        block_addr = int(args[0], 0)

        dump_signature(debugger, result, process, block_addr, output)
        disassemble(debugger, result, process, block_addr, output)
    finally:
        if output is not None:
            output.Close()

    if stopped_by_us:
        print('The process was automatically interrupted. Please resume it manually.')

def dump_signature(debugger, result, process, block_addr, output):
    error = lldb.SBError()
    pointer_size = utils.get_pointer_size()
    flags = process.ReadUnsignedFromMemory(block_addr + pointer_size, 4, error)
    if not error.Success():
        result.SetError(error)
        return

    block_has_signature = ((flags & (1 << 30)) != 0)
    block_has_copy_dispose_helpers = ((flags & (1 << 25)) != 0)

    if block_has_signature:
        block_descriptor = process.ReadPointerFromMemory(block_addr + 2 * 4 + 2 * pointer_size, error)
        if not error.Success():
            result.SetError(error)
            return

        signature_addr = block_descriptor + 2 * pointer_size
        if block_has_copy_dispose_helpers:
            signature_addr += 2 * pointer_size

        signature_pointer = process.ReadPointerFromMemory(signature_addr, error)
        signature = process.ReadCStringFromMemory(signature_pointer, 256, error)
        if not error.Success():
            result.SetError(error)
            return

        escaped_signature = signature.replace('"', '\\"')

        method_signature_cmd = 'po [NSMethodSignature signatureWithObjCTypes:"' + escaped_signature + '"]'
        utils.handle_command(debugger, method_signature_cmd, output)

def disassemble(debugger, result, process, block_addr, output):
    error = lldb.SBError()
    invoke_function_pointer = process.ReadPointerFromMemory(block_addr + utils.get_pointer_size() + 2 * 4, error)
    if not error.Success():
        result.SetError(error)
        return

    utils.handle_command(debugger, 'disassemble -a "%s" --force' % invoke_function_pointer, output)

def generate_option_parser():
    usage = "usage: %prog <obj-address>"
    parser = optparse.OptionParser(usage=usage, prog='dump_block')
    parser.add_option('-f', '--file',
                      dest='file',
                      help='File to output')

    return parser
