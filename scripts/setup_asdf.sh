#!/usr/bin/env bash
#
# Setup asdf

. $(dirname "$0")/utils.sh
. $(dirname "$0")/lib/asdf.sh

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
  install_plugin_package "$plugin"
done
