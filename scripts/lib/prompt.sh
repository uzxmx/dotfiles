#!/bin/sh

# Prompt for yes/no
#
# @params:
#   $1: the message to show to user
#   $2: the default value, can be Y/y/Yes/yes/N/n/No/no, optional
#
# @output
#   Will output yes/no.
#
# @example
#   _yesno "Do you want to push after merging? (Y/n)" yes
_yesno() {
  local reply=$(rlwrap -S "$1" head -1)
  reply=$(echo "${reply:-$2}" | tr "A-Z" "a-z" )
  if $(echo "$reply" | grep -E "^y|yes$" &>/dev/null); then
    echo 'yes'
  else
    echo 'no'
  fi
}
