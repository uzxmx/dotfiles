#!/bin/sh

# Split string into lines of strings with a specified separator.
#
# @params:
#   $1: the string
#   $2: the separator
#
# @example
#   str="foo\tbar"
#   split_str_into_lines $str "\t"
split_str_into_lines() {
  local str=$1
  local separator=$2
  echo "$str" | tr "$separator" "\n"
}

# Split string into lines of strings which are used to fill an array variable.
#
# @params:
#   $1: the string
#   $2: the separator
#   $3: the array name
#
# @example
#   local ary
#   str="foo\tbar"
#   split_str_into_array $str "\t" ary
#   echo ${ary[1]} # result: foo
#   echo ${ary[2]} # result: bar
#   echo ${#ary[@]} # result: 2
split_str_into_array() {
  local str=$1
  local separator=$2
  local name=$3
  lines_to_array $name < <(split_str_into_lines $str $separator)
}
