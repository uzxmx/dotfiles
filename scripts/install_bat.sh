#!/usr/bin/env bash
#
# Install bat (https://github.com/sharkdp/bat)

. $(dirname "$0")/utils.sh

if is_mac; then
  brew_install bat
else
  version="v0.12.1"
  name="bat-$version-x86_64-unknown-linux-gnu"
  rm -f /tmp/$name.tar.gz
  curl -L -o /tmp/$name.tar.gz https://github.com/sharkdp/bat/releases/download/$version/$name.tar.gz
  tar zxf $name.tar.gz -C /tmp
  sudo mv $name/bat /usr/local/bin
  sudo mv $name/bat.1 /usr/local/share/man/man1
  rm -rf $name.tar.gz $name
fi
