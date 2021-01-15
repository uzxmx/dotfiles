#!/bin/sh

# The function (caller) executes a command (callee) specified by the first
# argument, with arguments specified by the remainder shell arguments. It
# captures the data from fd 3 sent by the callee, and parses the data based on
# the exit code of the callee. The stdout and stderr of the callee are not
# influenced, still connect to the stdout and stderr of the caller as before.
#
# When exit code is 0, it evaluates the data from fd 3 in the current shell.
#
# When exit code is 100, the data is a full command ready to execute. It places
# the command in the shell history and then executes.
#
# When exit code is 101, it pushes the data onto the editing buffer stack to
# let the user edit and then execute by pressing enter.
#
# When exit code is 102, it is the same as exit code 100, except that the
# command will be evaluated (can be shell builtins), rather than executed.
#
# @params:
#   $1: the executable to be called
#   VARARGS: the arguments passed to the executable
capture_source_and_signal() {
  local executable="$1"
  shift
  # Shell variable `result` is the captured output from fd 3.
  # Shell variable `signal` is the captured exit code.
  local result signal
  # Syntax error for bash: { result=$("$executable" "$@" 3>&1 >&4 4>&-) } 4>&1
  # local tmp=$(mktemp)
  # exec 4> $tmp
  # result=$("$executable" "$@" 3>&1 >&4)
  # https://www.gnu.org/software/bash/manual/html_node/Command-Grouping.html
  { result=$("$executable" "$@" 3>&1 >&4 4>&-); } 4>&1
  signal="$?"
  # rm $tmp
  # cat "$tmp" && exec 4>&- && rm "$tmp"
  if [ -n "$result" ]; then
    # There are some contents in fd 3.
    case "$signal" in
      # When exit code is 0, just evaluate the output in the current shell.
      0)
        eval "$result"
        ;;
      # When exit code is 100, the output is a full command ready to execute.
      # We first place the command in the shell history and then execute.
      100)
        print -s "${result:q}"
        # Use `command` shell builtin to execute external command instead of a
        # function or builtin.
        eval "command $result"
        ;;
      # When exit code is 101, just push the output onto the editing buffer
      # stack.
      101)
        print -z "${result:q}"
        ;;
      # When exit code is 102, the output is a full command ready to be evaluated.
      # We first place the command in the shell history and then evaluate it.
      102)
        print -s "${result:q}"
        eval "$result"
        ;;
    esac
  fi
}
