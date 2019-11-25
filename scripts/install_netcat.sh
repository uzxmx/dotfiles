#!/usr/bin/env bash
#
# Install netcat

. $(dirname "$0")/utils.sh

if has_yum; then
  sudo yum install nc
else
  abort "Unsupported system"
fi
