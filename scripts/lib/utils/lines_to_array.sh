#!/bin/sh

# This function converts lines of strings to an array variable that each element
# corresponds to one line. The array variable is defined with the name specified
# by the first parameter.
#
# @params:
#   $1: the array name
#
# @example
#   lines_to_array ary < <(echo -e "foo\n\nbar") # Size of result array is 2.
#
# @exaple-zsh
#   echo -e "foo\n\nbar" | lines_to_array ary # Size of result array is 2.
#
# Note the bash example also works on zsh.
lines_to_array() {
  local name=$1
  local value
  while read -r value; do
    if [ -n "$value" ]; then
      if [ -n "$BASH" ]; then
        eval $name+="($(_bash_quote "$value"))"
      else
        eval $name+="(${value:q})"
      fi
    fi
  done
}
