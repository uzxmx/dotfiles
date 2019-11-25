#!/usr/bin/env bash
#
# Install netcat

. $(dirname "$0")/utils.sh

if has_yum; then
  sudo yum install -y nc
else
  abort "Unsupported system"
fi
