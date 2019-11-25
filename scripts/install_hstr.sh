#!/usr/bin/env bash
#
# Install hstr (https://github.com/dvorka/hstr)

. $(dirname "$0")/utils.sh

if is_mac; then
  brew_install hstr
elif has_apt; then
  sudo add-apt-repository ppa:ultradvorka/ppa
  sudo apt-get update
  sudo apt-get install -y hstr
else
  abort "Unsupported system"
fi
