#!/usr/bin/env bash
#
# Install fd (https://github.com/sharkdp/fd)

. $(dirname "$0")/utils.sh

if is_mac; then
  brew_install fd
elif has_dpkg; then
  dest=/tmp/fd_7.3.0_amd64.deb
  wget 'https://github.com/sharkdp/fd/releases/download/v7.3.0/fd_7.3.0_amd64.deb' -O $dest
  sudo dpkg -i $dest
  rm $dest
else
  npm install -g fd-find
fi
