#!/usr/bin/env zsh

# Join variable arguments into a string by separator.
#
# @params:
#   $1: separator
#   VARARGS: array of strings to join
#
# @example
#   join_by $'\n' a b c
#   join_by ',' a b c
#   arr=(foo bar baz); join_by $'\n' "${arr[@]}"
join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

# Join variable arguments to lines.
#
# @params:
#   VARARGS: array of strings to join
#
# @example
#   join_to_lines a b c
#   arr=(foo bar baz); join_to_lines $arr
join_to_lines() {
  join_by $'\n' "$@"
}
