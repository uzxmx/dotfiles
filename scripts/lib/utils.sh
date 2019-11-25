#!/bin/sh
#
# This script depends on `prompt.sh`.

info() {
  echo "$@"
}

warn() {
  echo "$@"
}

error() {
  echo "$@"
}

# Output error message to stderr, and exit.
abort() {
  echo "$@" >/dev/stderr
  exit 1
}

is_mac() {
  if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    return 0
  else
    return 1
  fi
}

has_apt() {
  if type -p apt-get &>/dev/null; then
    return 0
  else
    return 1
  fi
}

has_dpkg() {
  if type -p dpkg &>/dev/null; then
    return 0
  else
    return 1
  fi
}

has_yum() {
  if type -p yum &>/dev/null; then
    return 0
  else
    return 1
  fi
}

brew_install() {
  if ! type -p brew &>/dev/null; then
    abort 'You must install `brew` before you can continue'
  fi
  brew install "$@"
}

# Check if executable exists. If not, install it. A script with name `install_${executable}.sh`
# should exist in folder ~/.dotfiles/scripts.
#
# @params:
#   $1: executable name
#   $2: function to install the executable, optional
check_and_install_executable() {
  local executable=$1
  echo -n "Checking $executable..."
  if type -p $executable &>/dev/null; then
    echo 'Found'
  else
    echo 'Not found, installing...'
    local fn=$2
    if [ -n "$fn" ]; then
      $fn
    else
      $HOME/.dotfiles/scripts/install_${executable}.sh >/dev/null
    fi
    ret=$?
    if [ $ret = 0 ]; then
      echo 'Done'
    else
      exit $ret
    fi
  fi
}

check_and_install_executables() {
  for executable in "$@"; do
    check_and_install_executable "$executable"
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
#   $1: src file
#   $2: target file
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
