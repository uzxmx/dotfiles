import os
import lldb
import optparse
import shlex
import tempfile
import re

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f cmd_dump_function.dump_function dump_function')
    print('The "dump_function" command has been installed.')

def dump_function(debugger, command, result, internal_dict):
    usage = '''usage: %prog <address> [-d <directory>] [-f <file>]

When no file is specified, the file will be named by the function name.
When no directory is specified, current working directory will be used.'''
    parser = optparse.OptionParser(prog='dump_function', usage=usage)
    parser.add_option('-d', '--dir', dest='dir', help='directory to store the generated file')
    parser.add_option('-f', '--file', dest='file', help='path to the generated file, can be used w/o `-d` option')

    try:
        (options, args) = parser.parse_args(shlex.split(command))
    except:
        return

    if len(args) == 0:
        print('You need to specify an address which is contained by the function.')
        return

    file = None
    file_is_tmp = True
    dest_path = None
    if options.file is not None:
        dest_path = os.path.join(options.dir if options.dir is not None else os.getcwd(), options.file)
        file = open(dest_path, 'w')
        file_is_tmp = False
    else:
        file = tempfile.TemporaryFile(mode='w+')

    new_output = lldb.SBFile.Create(file)
    saved_output = debugger.GetOutputFile()
    saved_use_color = debugger.GetUseColor()
    debugger.SetUseColor(False)
    debugger.SetOutputFile(new_output)
    debugger.HandleCommand('disassemble -a "%s" --force' % args[0])
    debugger.SetOutputFile(saved_output)
    debugger.SetUseColor(saved_use_color)

    if file_is_tmp:
        file.seek(0)
        name = str(file.readline().strip())
        name = re.sub(r'^[^0-9a-zA-Z]*(.*?)[^0-9a-zA-Z]*$', r'\1', name)
        name = re.sub(r'[^0-9a-zA-Z]', '_', name)
        dest_path = os.path.join(options.dir if options.dir is not None else os.getcwd(), name + '.asm')
        target_file = open(dest_path, 'w')
        file.seek(0)
        target_file.writelines(file.readlines())
        target_file.close()

    new_output.Close()

    print('Function has been dumped to %s.' % dest_path)
