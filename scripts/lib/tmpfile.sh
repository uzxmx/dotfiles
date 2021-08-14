#!/bin/sh

source "$dotfiles_dir/scripts/lib/trap.sh"

_create_tmp() {
  local is_dir="$1"
  local name="$2"
  local _tmp
  if [ "$is_dir" = "1" ]; then
    _tmp="$(mktemp -d)"
  else
    _tmp="$(mktemp)"
  fi
  eval $name="$_tmp"
  trap_add "[ -e \"$_tmp\" ] && rm -rf \"$_tmp\"" EXIT
}

# Create a temporary file. The file will be automatically deleted on exit.
#
# @params:
#   $1: the shell variable name to store the created file
#
# @example:
#   local tmpfile
#   create_tmpfile tmpfile
create_tmpfile() {
  _create_tmp 0 "$1"
}

# Create a temporary directory. The directory will be automatically deleted on exit.
#
# @params:
#   $1: the shell variable name to store the created directory
#
# @example:
#   local tmpfile
#   create_tmpfile tmpfile
create_tmpdir() {
  _create_tmp 1 "$1"
}
