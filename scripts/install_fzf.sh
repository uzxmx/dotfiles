#!/usr/bin/env bash
#
# Install fzf (https://github.com/junegunn/fzf)

set -e

case $OSTYPE in
  darwin*)
    if ! type brew >/dev/null; then
      echo 'You must install `brew` before you can continue'
      exit 1
    fi
    brew install fzf
    /usr/local/opt/fzf/install --key-bindings --completion --no-bash --no-update-rc
    ;;
  linux-gnu)
    if ! type apt-get >/dev/null; then
      echo 'Only debian system supported'
      exit 1
    fi
    sudo apt-get install fzf
    ;;
esac
