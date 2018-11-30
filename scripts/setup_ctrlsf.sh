#!/usr/bin/env bash
#
# Setup ctrlsf.vim plugin.

set -e

case $OSTYPE in
  darwin*)
    if ! type brew >/dev/null; then
      echo 'You must install `brew` before you can continue'
      exit 1
    fi
    brew install the_silver_searcher
    ;;
  linux-gnu)
    if ! type apt-get >/dev/null; then
      echo 'Only debian system supported'
      exit 1
    fi
    apt-get install silversearcher-ag
    ;;
esac
