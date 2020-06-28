#!/bin/sh
#
# Generate a random string.
#
# @params:
#   $1: the lenght of the string to be generated.
#
# @example
#   random_string 15
random_string() {
  local len="$1"
  local TR

  # GNU tr is required.
  if type gtr &>/dev/null; then
    TR=gtr
  else
    TR=tr
  fi

  head /dev/urandom | $TR -dc 'A-Za-z0-9' | head -c "$len"
}
