#!/bin/sh

# Find the index of the last occurrence of a substring in a string. -1 is
# output when not found
#
# @params:
#   $1: the string.
#   $2: the substring.
substr_rindex() {
  local str="$1"
  local substr="$2"
  local substr_len="${#substr}"
  local i="$((${#str} - $substr_len))"
  while [ "$i" -ge 0 ]; do
    if [ "$substr" = "${str:$i:$substr_len}" ]; then
      break
    fi
    i="$((i - 1))"
  done
  echo "$i"
}
