#!/usr/bin/env bash

set -e

# Output error message to stderr, and exit.
abort() {
  echo "$@" >/dev/stderr
  exit 1
}

is_mac() {
  if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    return 0
  else
    return 1
  fi
}

brew_install() {
  if ! type brew &>/dev/null; then
    abort 'You must install `brew` before you can continue'
  fi
  brew install "$@"
}
