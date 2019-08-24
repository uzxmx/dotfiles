#!/usr/bin/env bash
#
# Install fd (https://github.com/sharkdp/fd)

set -e

case $OSTYPE in
  darwin*)
    if ! type brew >/dev/null; then
      echo 'You must install `brew` before you can continue'
      exit 1
    fi
    brew install fd
    ;;
  linux-gnu)
    if ! type apt-get >/dev/null; then
      echo 'Only debian system supported'
      exit 1
    fi
    dest=/tmp/fd_7.3.0_amd64.deb
    wget 'https://github.com/sharkdp/fd/releases/download/v7.3.0/fd_7.3.0_amd64.deb' -O $dest
    sudo dpkg -i $dest
    rm $dest
    ;;
esac
