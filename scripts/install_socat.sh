#!/usr/bin/env bash

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
    brew install socat
    ;;
esac
