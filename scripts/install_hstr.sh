#!/usr/bin/env bash
#
# Install hstr (https://github.com/dvorka/hstr)

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
    brew install hstr
    ;;
  linux-gnu)
    if type apt-get &>/dev/null; then
      sudo add-apt-repository ppa:ultradvorka/ppa
      sudo apt-get update
      sudo apt-get install hstr
    else
      abort "Unsupported system"
    fi
    ;;
esac
