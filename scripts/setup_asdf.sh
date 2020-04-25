#!/usr/bin/env bash
#
# Setup asdf

. $(dirname "$0")/utils.sh

# Required by asdf-python
$(dirname "$0")/install_python_dependencies.sh

# Required by asdf-ruby
$(dirname "$0")/install_ruby_dependencies.sh

# Required by asdf-java
check_and_install_executable jq

if [[ ! -e ~/.asdf ]]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4
  . ~/.asdf/asdf.sh
fi

plugins=(python ruby nodejs java golang)
for plugin in ${plugins[*]}; do
  if ! asdf plugin-list | grep "$plugin" &>/dev/null; then
    if [ "$plugin" = "java" ]; then
      asdf plugin-add "$plugin" https://github.com/uzxmx/asdf-java.git
    else
      asdf plugin-add "$plugin"
    fi
  fi
done

if [[ ! -e ~/.asdf/shims/node ]]; then
  ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
fi

parse_package_version() {
  grep "$1" ~/.dotfiles/tool-versions | cut -d ' ' -f 2 | head -1
}

for plugin in ${plugins[*]}; do
  asdf install "$plugin" "$(parse_package_version $plugin)"
done
