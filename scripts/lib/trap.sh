#!/bin/sh

# This function allows to be called several times to add a command for a same
# trap. All the commands for that trap will be executed.
#
# @params:
#   $1: the command
#   VARARGS: the trap names
#
# @example:
#   trap_add 'echo foo' EXIT
#   trap_add call_some_func EXIT
#
# NOTE: this function only works for bash.
trap_add() {
  local cmd="$1"
  shift
  local trap_name
  for trap_name in "$@"; do
    trap -- "$(
      _extract_trap_cmd() { printf '%s\n' "$3"; }
      eval "_extract_trap_cmd $(trap -p "$trap_name")"
      printf '%s\n' "$cmd"
    )" "$trap_name"
  done
}

# Set the trace attribute for the above function. This is required to modify
# DEBUG or RETURN traps because functions don't inherit them unless the trace
# attribute is set.
declare -f -t trap_add
