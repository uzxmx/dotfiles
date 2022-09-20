#!/bin/sh

# Bash doesn't support ${parameter@Q} before 4.4.
# Ref:
#   https://github.com/bminor/bash/blob/bash-4.4-alpha/CHANGES#L425-L426
#   https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
_bash_quote() {
  local value=$1
  if type -p bc &>/dev/null && [ "$(echo "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]} >= 4.4" | bc)" = "1" ]; then
    echo "${value@Q}"
  else
    printf "%q" "$value"
  fi
}

_shell_quote() {
  if [ -n "$BASH" ]; then
    _bash_quote "$1"
  else
    # For zsh
    echo "${1:q}"
  fi
}

# Expand tilde in quotes.
#
# @params:
#   $1: a quoted path starting with tilde
#
# @example
#   expand_tilde_in_quotes "~/foo"
expand_tilde_in_quotes() {
  eval echo "$1"
}
