#!/usr/bin/env bash
#
# Install bc.

. $(dirname "$0")/utils.sh

if has_yum; then
  sudo yum install -y bc
else
  abort "Unsupported system"
fi
