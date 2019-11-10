#!/usr/bin/env bash
#
# Install rlwrap

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
    brew install rlwrap
    ;;
  linux-gnu)
    abort "Unsupported system"
    ;;
  *)
    abort "Unsupported system"
    ;;
esac
