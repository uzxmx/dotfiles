#!/bin/sh

source ~/.dotfiles/scripts/lib/utils/capture_source_and_signal.sh

px() {
  capture_source_and_signal ~/.dotfiles/scripts/misc/proxyctl "$@"
}

pe() {
  px enable "$@"
}

pd() {
  px disable "$@"
}

pi() {
  px info "$@"
}
