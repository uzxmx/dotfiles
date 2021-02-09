#!/bin/sh
#
# This script checks if GNU sed is present in current system.

SED=
check_gsed() {
  local cmd
  if type gsed &>/dev/null; then
    cmd=gsed
  else
    cmd=sed
  fi
  if ! $cmd --version | head -1 | grep 'GNU sed' &>/dev/null; then
    echo "GNU sed is required."
    exit 1
  fi
  SED="$cmd"
}
check_gsed
