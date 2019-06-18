#!/usr/bin/env bash
#
# Install progress viewer (https://github.com/Xfennec/progress)

set -e

case $OSTYPE in
  darwin*)
    if ! type brew >/dev/null; then
      echo 'You must install `brew` before you can continue'
      exit 1
    fi
    brew install progress
    ;;
  linux-gnu)
    if ! type apt-get >/dev/null; then
      echo 'Only debian system supported'
      exit 1
    fi
    sudo apt-get install progress
    ;;
esac
