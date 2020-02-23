#!/usr/bin/env zsh
#
# Setup asdf

. $(dirname "$0")/utils.sh

# Required by asdf-python
$(dirname "$0")/install_python_dependencies.sh

# Required by asdf-ruby
$(dirname "$0")/install_ruby_dependencies.sh

# Required by asdf-java
check_and_install_executable jq || exit $?

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

asdf install java adopt-openjdk-11.0.6+10
