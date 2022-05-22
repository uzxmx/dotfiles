#!/bin/sh

# Output new path.
#
# @params:
#   VARARGS: variable paths to be excluded
new_path_exclude() {
  local result="$PATH"
  local sanitized_path
  for i in "$@"; do
    sanitized_path="$(dirname $i)/$(basename $i)"
    result=$(echo "$result" | sed -E -e "s#([^:]*:?)${sanitized_path}/{0,1}(:.*|$)#\1\2#g" -e "s#:+#:#g")
  done
  echo $result
}

# Check if a command exists in the PATH.
#
# @params:
#   $1: the command
check_command() {
  (PATH="$(new_path_exclude "$DOTFILES_DIR/bin" "$DOTFILES_DIR/bin_nim")" type -p "$1")
}
