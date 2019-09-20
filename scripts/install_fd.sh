#!/usr/bin/env bash
#
# Install fd (https://github.com/sharkdp/fd)

set -e

abort() {
  echo $@ >>/dev/stderr
  exit 1
}

case $OSTYPE in
  darwin*)
    if ! type brew &>/dev/null; then
      abort 'You must install `brew` before you can continue'
    fi
    brew install fd
    ;;
  linux-gnu)
    if type dpkg &>/dev/null; then
      dest=/tmp/fd_7.3.0_amd64.deb
      wget 'https://github.com/sharkdp/fd/releases/download/v7.3.0/fd_7.3.0_amd64.deb' -O $dest
      sudo dpkg -i $dest
      rm $dest
    else
      npm install -g fd-find
    fi
    ;;
esac
