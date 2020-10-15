#!/bin/sh
#
# This script provides platform dependent utilities.

is_mac() {
  if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    return 0
  else
    return 1
  fi
}

is_wsl() {
  [[ "$(uname -r)" =~ Microsoft$ ]]
}

is_linux() {
  [[ "$OSTYPE" =~ ^linux ]]
}

has_apt() {
  type -p apt-get &>/dev/null
}

has_dpkg() {
  type -p dpkg &>/dev/null
}

has_yum() {
  type -p yum &>/dev/null
}

has_snap() {
  type -p snap &>/dev/null
}

has_systemd() {
  pidof systemd &>/dev/null
}

brew_install() {
  if ! type -p brew &>/dev/null; then
    abort 'You must install `brew` before you can continue'
  fi
  brew install "$@"
}

# Download and install a debian package.
#
# @params:
#   $1: remote url
download_and_install_debian_package() {
  if [ -z "$1" ]; then
    abort 'Remote url is required.'
  fi
  name="$(basename "$1")"
  dest="/tmp/$name"
  curl -C- -L -o "$dest" "$1"
  sudo dpkg -i "$dest"
  rm "$dest"
}
