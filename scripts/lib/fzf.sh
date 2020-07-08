#!/bin/sh

# This function helps to capture the output of `fzf' as an array, especially
# useful when using `--expect' option of `fzf'. When call is finished, an array
# variable will be defined with name specified by the first parameter.  If you
# pass in `--expect' argument, the array size will be 2, otherwise 1.
#
# Note: This function won't work when the selected line contains any whitespace,
# because it will be identified as array element delimiter.
#
# @params:
#   $1: the array name
#   VARARGS: fzf arguments
#
# @example-zsh
#   ls | call_fzf foo --expect=ctrl-e
#   echo ${foo[1]}
#   echo ${foo[2]}
#
# @example-bash
#   call_fzf foo --expect=ctrl-e < <(ls)
#   echo ${foo[0]}
#   echo ${foo[1]}
#
# Note the bash example also works on zsh, except that the array index starts at 1.
call_fzf() {
  _call_program_with_array_output fzf "$@"
}

call_fzf_tmux() {
  _call_program_with_array_output fzf-tmux "$@"
}

_call_program_with_array_output() {
  local program=$1; shift
  local name=$1; shift
  local value
  if [ -n "$BASH" ]; then
    while read -r value; do
      if [ -n "$value" ]; then
        # Quote the value so it can be reused as input.
        eval $name+="($(_bash_quote "$value"))"
      fi
    done < <(cat | $program "$@")
  else
    # For zsh, when we use process substitution to call fzf, and the calling
    # context is from zshrc (not from a zsh script), fzf looks like stuck and
    # doesn't show selection list. So we work around it by using pipe.
    cat | $program "$@" | while read -r value; do
      if [ -n "$value" ]; then
        # Quote the value so it can be reused as input.
        eval $name+="(${value:q})"
      fi
    done
  fi
}
