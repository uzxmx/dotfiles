#!/usr/bin/env bash
#
# Install fzf (https://github.com/junegunn/fzf)

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
    brew install fzf
    /usr/local/opt/fzf/install --key-bindings --completion --no-bash --no-update-rc
    ;;
  linux-gnu)
    if type apt-get &>/dev/null; then
      sudo apt-get install fzf
    else
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      sudo ~/.fzf/install
    fi
    ;;
esac
