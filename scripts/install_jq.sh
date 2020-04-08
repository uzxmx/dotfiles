#!/usr/bin/env bash
#
# Install jq.

. $(dirname "$0")/utils.sh

if is_mac; then
  brew_install jq
elif has_yum; then
  sudo yum install -y epel-release
  sudo yum install -y jq
elif has_apt; then
  sudo apt-get install -y jq
else
  abort "Unsupported system"
fi
