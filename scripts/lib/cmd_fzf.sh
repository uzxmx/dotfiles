#!/bin/sh

# This function helps you to seach some command by its description, so you
# don't need to remember the exact command name and arguments. To use it in a
# script, you need to declare a shell variable called `FZF_COMMANDS` and at a
# proper time, call this function. `FZF_COMMANDS` is a multi-lines string, each
# line should be composed of a command description and a command, which is
# separated by `\t`. Note there should be only one `\t` in a line.
#
# @params:
#   VARARGS: fzf arguments
#
# @example-script
#   source cmd_fzf.sh
#
#   a_shell_function() { echo Called in a shell function }
#
#   FZF_COMMANDS="List files in current directory\tls
#   Echo something\techo foo
#   Shell function can also be specified\ta_shell_function
#   "
#
#   cmd="$1"
#   case "$1" in
#     ...
#
#     fzf)
#       shift
#       "cmd_$cmd" "$@"
#       ;;
#
#     ...
#   esac
#
cmd_fzf() {
  local line="$(echo -e "$FZF_COMMANDS" | fzf -d "\t" --with-nth=1 "$@")"
  local cmd="$(echo "$line" | awk -F "\t" '{print $2}')"
  if [ -n "$cmd" ]; then
    eval "$cmd"
  fi
}

# Like `cmd_fzf`, but allows the caller to process when user presses an expected key.
#
# @params:
#   $1: the variable name to capture `query`, `key` and `selection` into.
#   $2: the expected keys, separated by comma.
#   VARARGS: fzf arguments
cmd_fzf_expect() {
  local name="$1"
  local expect_opts="$2"
  shift 2

  call_fzf "$name" -d "\t" --with-nth=1 --print-query --expect="$expect_opts" "$@" < <(echo -e "$FZF_COMMANDS")

  local _query _key _result
  eval _query="\${$name[0]}"
  eval _key="\${$name[1]}"
  eval _result="\${$name[2]}"

  if [ -z "$_key" ]; then
    local cmd="$(echo "$_result" | awk -F "\t" '{print $2}')"
    if [ -n "$cmd" ]; then
      eval "$cmd"
    fi
  fi
}
