#!/usr/bin/env bash

. $(dirname "$0")/utils.sh

if is_mac; then
  brew_install socat
elif has_yum; then
  sudo yum install -y socat
else
  abort "Unsupported system"
fi
