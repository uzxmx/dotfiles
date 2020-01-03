#!/usr/bin/env zsh

# This function must be used as a side of a pipe. When call is finished, an
# array variable will be defined with name specified by the first parameter.
# 
# @params:
#   $1: the array name
#   VARARGS: fzf arguments
#
# @example
#   local foo
#   ls | pipe_to_fzf foo --expect=ctrl-e
#   echo ${foo[1]}
#   echo ${foo[2]}
pipe_to_fzf() {
  local name=$1; shift
  local -a values
  local value
  cat | fzf "$@" | while read value; do
    values+=("$value")
  done
  eval $name'=("$values[@]")'
}
