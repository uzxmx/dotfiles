#!/bin/sh
#
# This script depends on `prompt.sh`.

. $(dirname "$BASH_SOURCE")/system.sh
. $(dirname "$BASH_SOURCE")/color.sh

# Split string by separator.
#
# @params:
#   $1: string to split
#   $2: separator
#
# @example
#   local names=`split_by "$line" ","`
#   echo "$names" | while read name do;
#     echo "$name"
#     ...
#   done
split_by() {
  local str=$1
  local separator=$2
  echo "$str" | tr "$separator" "\n"
}

# Check if executable exists. If not, install it. A script with name `${executable}'
# should exist in folder $DOTFILES_DIR/scripts/install.
#
# @params:
#   $1: executable name, multiple alias names are supported with `|` as separator, e.g. `netcat|nc`
#   $2: function to install the executable, optional
check_and_install_executable() {
  local executable=$1
  local names=`split_by "$1" "|"`
  local primary_name=$(echo $names | head -1)
  echo -n "Checking $primary_name..."
  while read name; do
    if type -p $name &>/dev/null; then
      echo 'Found'
      return 0
    fi
  done < <(echo "$names")

  echo 'Not found, installing...'
  local fn=$2
  if [ -n "$fn" ]; then
    $fn
  else
    "$DOTFILES_DIR/scripts/install/${primary_name}" >/dev/null
  fi
  ret=$?
  if [ $ret = 0 ]; then
    echo 'Done'
  else
    return $ret
  fi
}

check_and_install_executables() {
  for executable in "$@"; do
    check_and_install_executable "$executable" || return $?
  done
}

# Test if stdin is a terminal.
is_terminal() {
  tty -s
  return $?
}

# Check if src file is of type link, and whether links to target file if target file is specified.
#
# @params:
#   $1: src file
#   $2: target file, optional
is_link() {
  local src_file=$1
  local target_file=$2
  local result
  result="$(readlink "$src_file")"
  if [ $? != 0 ]; then
    return 1
  fi
  if [ -n "$target_file" -a "$target_file" != "$result" ]; then
    return 1
  fi
}

# Create a link.
#
# @params:
#   $1: src file (to be created)
#   $2: target file (to be linked to)
create_link() {
  local src_file=$1
  local target_file=$2
  [ -z "$target_file" ] && error 'target file is required' && return
  is_link "$src_file" "$target_file" && return
  if is_link "$src_file" || [ -f "$src_file" ]; then
    is_terminal || (error "Failed to create link $src_file -> $target_file" && return 1)
    local reply=`yesno "$src_file exists. Do you want to delete it and create a new link? (Y/n)" "yes"`
    [ "$reply" != "yes" ] && return 1
    rm "$src_file"
  fi
  ln -s "$target_file" "$src_file"
}
