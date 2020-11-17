#!/bin/sh

# This function helps to capture the output into a shell variable, but still send the output to the stdout to display.
# @params:
#   $1: the variable name
#   VARARGS: command to execute
#
# @example
#    local foo
#    io_run_capture_and_display foo ls
io_run_capture_and_display() {
  local name="$1"; shift
  exec 5>&1
  local value="$("$@" | tee >(cat - >&5))"
  eval $name="$(_shell_quote "$value")"
}
