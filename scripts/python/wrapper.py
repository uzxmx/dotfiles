#!/usr/bin/env python3
import os
import shlex
import sys


def remove_path_from_env(target):
    paths = os.environ.get('PATH', '').split(':')
    os.environ['PATH'] = ':'.join(p for p in paths if p and p != target)


def print_and_exit(cmdline, code):
    quoted = ' '.join(shlex.quote(str(a)) for a in cmdline)
    try:
        fd3 = os.fdopen(3, 'w')
        fd3.write(quoted)
        fd3.close()
        sys.exit(code)
    except OSError:
        os.execvp(cmdline[0], [str(a) for a in cmdline])


def run_original(add_program=True):
    args = list(sys.argv[1:])
    if add_program:
        args.insert(0, os.path.basename(sys.argv[0]))
    print_and_exit(args, 100)


def run_original_if_required(check_dash=False):
    if check_dash:
        if len(sys.argv) > 1 and sys.argv[1] == '-':
            sys.argv[1] = os.path.basename(sys.argv[0])
            run_original(add_program=False)
    else:
        if len(sys.argv) > 1:
            run_original()


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <command> [args...]", file=sys.stderr)
        sys.exit(1)
    print_and_exit(sys.argv[1:], 100)
