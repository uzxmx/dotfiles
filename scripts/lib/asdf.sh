#!/bin/sh

plugin_installed() {
  asdf plugin-list | grep "$1" &>/dev/null
}

parse_package_version() {
  grep "$1" ~/.dotfiles/tool-versions | cut -d ' ' -f 2 | head -1
}

install_plugin_package() {
  plugin="$1"
  if ! plugin_installed "$plugin"; then
    if [ "$plugin" = "java" ]; then
      asdf plugin-add "$plugin" https://github.com/uzxmx/asdf-java.git
    elif [ "$plugin" = "golang" ]; then
      # TODO Once https://github.com/kennyp/asdf-golang/pull/31 is merged, we can delete this.
      asdf plugin-add "$plugin" https://github.com/uzxmx/asdf-golang.git
    else
      asdf plugin-add "$plugin"
    fi
  fi

  if [ "$plugin" = "nodejs" -a ! -e ~/.asdf/shims/node ]; then
    ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
  fi

  asdf install "$plugin" "$(parse_package_version $plugin)"
}
