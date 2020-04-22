#!/bin/sh

# Check required variables.
#
# @params:
#   VARARGS: array of variable names to check
#
# @example
#   check_variables foo bar baz
check_variables() {
  local IFS=$'\n'
  echo "$*" | while read name; do
    if [ -z "$(eval "echo \$$name")" ]; then
      echo "$name is required"
      return 1
    fi
  done
}
