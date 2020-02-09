#!/usr/bin/env zsh

# This function converts lines of strings to an array variable that each element
# corresponds to one line. The array variable is defined with the name specified
# by the first parameter.
#
# @params:
#   $1: the array name
#
# @example
#   local ary
#   echo "foo\nbar" | lines_to_array ary
#   echo ${ary[1]} # result: foo
#   echo ${ary[2]} # result: bar
#   echo ${#ary[@]} # result: 2
lines_to_array() {
  local name=$1
  local -a values
  local value
  while read value; do
    values+=("$value")
  done
  eval $name'=("$values[@]")'
}
