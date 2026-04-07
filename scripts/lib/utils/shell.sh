#!/bin/sh

# Parse a shell options string (respecting shell quoting rules) into an array
# variable. Useful when an options string may contain quoted paths with spaces.
#
# @params:
#   $1: the array variable name
#   $2: the options string
#
# @example
#   parse_shell_opts opts "root@host -i '/path/with space/key.pem'"
#   ssh "${opts[@]}" ...
parse_shell_opts() {
  local name=$1
  local opts_str=$2
  eval "${name}=(${opts_str})"
}
