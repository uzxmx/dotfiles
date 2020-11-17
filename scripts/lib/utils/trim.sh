#!/bin/sh

# Remove beginning and trailing whitespaces for a string. Whitespaces include
# tab, newline, vertical tab, form feed, carriage return, and space.
#
# Also see https://www.gnu.org/software/sed/manual/html_node/Character-Classes-and-Bracket-Expressions.html.
#
# @params:
#   $1: the string
#
# @example
#   local str="$(str_trim "  foo  ")"
str_trim() {
  local str="$1"
  echo "$1" | sed 's/^[[:space:]]\|[[:space:]]$//g'
}
