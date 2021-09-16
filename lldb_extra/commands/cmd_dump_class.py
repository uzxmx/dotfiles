import os
import lldb
import optparse
import shlex
from lldb_extra import utils
from six import StringIO as SixStringIO
import re

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

    # Dump all loaded classes in a specific module into `classes` directory, one file per class.
    dump_class -L -d classes -m UIKit

    # Dump all loaded classes which inherit NSViewController, one file per class.
    dump_class -L -p NSViewController
    '''

    stopped_by_us = False
    if not utils.isProcStopped():
        stopped_by_us = True
        debugger.HandleCommand('process interrupt')

    try:
        command_args = shlex.split(command)
        parser = generate_option_parser()
        try:
            (options, args) = parser.parse_args(command_args)
        except:
            result.SetError(parser.usage)
            return

        if len(args) == 0:
            if options.list_all_classes:
                list_classes(options, result)
            elif options.dump_all_classes:
                dump_all_classes(options, result)
            else:
                result.SetError('You need to specify at least a class name, `-l` or `-L` option.')
        else:
            do_dump_class(args[0], options, result)
    finally:
        if stopped_by_us:
            print('The process was automatically interrupted. Please resume it manually.')

def list_classes(options, result):
    output = get_classes(options, result)
    if output is not None:
        print_output(output, options.file)

def get_classes(options, result):
    opts = {
        'parent_class_name': options.filter_by_parent_class,
        'filter_by_parent_class': 1 if options.filter_by_parent_class else 0,
        'pre_block': '',
    }

    if options.module is not None:
        target = utils.getTarget()
        module = target.FindModule(lldb.SBFileSpec(options.module))
        if not module.IsValid():
            result.SetError("Unable to find module '{}', to see list of modules, use 'image list -b'".format(options.module))
            return
        bounds = []
        def loop_subsections(section):
            for subsec in section:
                lower_bound = subsec.GetLoadAddress(target)
                upper_bound = lower_bound + subsec.file_size
                bounds.append('({} <= addr && addr <= {})'.format(lower_bound, upper_bound))
        loop_subsections(module.FindSection("__DATA"))
        loop_subsections(module.FindSection("__DATA_DIRTY"))

        if len(bounds) > 0:
            opts['pre_block'] = 'uintptr_t addr = (uintptr_t) cls; if (!(%s)) { continue; }' % ' || '.join(bounds)

    expr_sbvalue = utils.render_script_and_evaluate('dump_all_classes.mm', opts)
    if expr_sbvalue.error.success:
        return expr_sbvalue.GetObjectDescription()
    else:
        result.SetError("Failed to dump: %s" % str(expr_sbvalue.error))

def dump_all_classes(options, result):
    output = get_classes(options, result)
    if output is not None:
        output_dir = options.output_dir if options.output_dir is not None else os.getcwd()
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        for cls in output.splitlines():
            if cls != '':
                options.file = os.path.join(output_dir, cls)
                do_dump_class(cls, options, result)

def do_dump_class(name, options, result):
    opts = { 'class_name': name, 'enable_class': 1 if options.all else 0 }
    expr_sbvalue = utils.render_script_and_evaluate('dump_class.mm', opts)
    if not expr_sbvalue.error.success:
        result.SetError("Failed to dump: %s" % str(expr_sbvalue.error))
        return

    output = SixStringIO()
    method_started = False
    for line in str(expr_sbvalue.GetObjectDescription()).splitlines():
        if method_started:
            match = re.match(r'^\[(.+)\] .*$', line)
            if match is None:
                method_started = False
            else:
                symbol = utils.get_symbol_name_by_addr(match.groups()[0])
                print('%s %s' % (line, symbol), file=output)
                continue
        elif line == 'Instance methods:' or line == 'Class methods:':
            method_started = True
        print('%s' % line, file=output)

    print_output(output.getvalue(), options.file)

def print_output(output, file=None):
    if file is None:
        utils.print_max_lines(output)
    else:
        file = open(file, 'w')
        file.write(output)
        file.close()

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

    parser.add_option('-m', '--module',
                      dest='module',
                      help='Filter class by module. You only need to give the module name (not fullpath). Must be used with `-l` or `-L` option')

    parser.add_option('-f', '--file',
                      dest='file',
                      help='File to output')

    parser.add_option('-L', '--dump-all-classes',
                      action='store_true',
                      default=False,
                      dest='dump_all_classes',
                      help='Dump currently loaded classes, one file per class. Note this may be time-consuming')

    parser.add_option('-d', '--output-dir',
                      dest='output_dir',
                      help='The directory to output files, only valid when combined with `-L` option')

    return parser
