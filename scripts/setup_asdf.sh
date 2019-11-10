#!/usr/bin/env bash
#
# Setup asdf

. $(dirname "$0")/utils.sh

if [[ ! -e ~/.asdf ]]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4
  . ~/.asdf/asdf.sh
fi

plugins=(python ruby nodejs java)
for plugin in ${plugins[*]}; do
  if ! asdf plugin-list | grep "$plugin" &>/dev/null; then
    asdf plugin-add "$plugin"
  fi
done

asdf install python 3.8.0
asdf install ruby 2.6.4

if [[ ! -e ~/.asdf/shims/node ]]; then
  ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
fi
asdf install nodejs 12.13.0

asdf install java adopt-openjdk-9+181
