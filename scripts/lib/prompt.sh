#!/bin/sh

_prompt_read_reply() {
  if type -p rlwrap &>/dev/null; then
    rlwrap -S "$1" head -1
  else
    echo -n "$1" >/dev/stderr
    local reply
    read reply
    echo "$reply"
  fi
}

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
#   local reply="$(yesno "Do you want to push after merging? (Y/n)" "yes")"
#   if [ "$reply" = "yes" ]; then
#     ...
#   fi
yesno() {
  local reply
  if [ -t 0 ]; then
    reply=$(_prompt_read_reply "$1")
  else
    reply=$(_prompt_read_reply "$1" </dev/tty)
  fi
  reply=$(echo "${reply:-$2}" | tr "A-Z" "a-z" )
  if $(echo "$reply" | grep -E "^y|yes$" &>/dev/null); then
    echo 'yes'
  else
    echo 'no'
  fi
}

# Prompt for a string. It will not stop until the input is present.
#
# @params:
#   $1: the variable to assign the input to.
#   $2: the description shown to the user.
#   $3: the default value, optional.
#
# @example
#   local name
#   ask_for_input name "Name: "
#
# TODO When completing a path with spaces, rlwrap cannot work properly.
ask_for_input() {
  while [ -z "$(eval "echo \$$1")" ]; do
    eval "$1=\"$(rlwrap -e "" --complete-filenames -S "$2" -P "$3" -o cat)\""
  done
}

# Prompt for a string. The input is allowed to be empty.
ask_for_input_empty() {
  eval "$1=\"$(rlwrap -e "" --complete-filenames -S "$2" -P "$3" -o cat)\""
}
