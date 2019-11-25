#!/usr/bin/env bash
#
# Install ag (https://github.com/ggreer/the_silver_searcher)

. $(dirname "$0")/utils.sh

if is_mac; then
  brew_install the_silver_searcher
elif has_apt; then
  sudo apt-get install -y silversearcher-ag
elif has_yum; then
  sudo yum install -y the_silver_searcher
else
  abort "Unsupported system"
fi
