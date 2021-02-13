#!/bin/sh

if ! type asdf &>/dev/null; then
  if [ -f ~/.asdf/asdf.sh ]; then
    source ~/.asdf/asdf.sh
  fi
fi

plugin_installed() {
  asdf plugin-list | grep "$1" &>/dev/null
}

parse_package_version() {
  grep "$1" ~/.dotfiles/tool-versions | cut -d ' ' -f 2 | head -1
}

install_plugin_package() {
  local plugin="$1"
  local package_version="$2"
  if ! plugin_installed "$plugin"; then
    case "$plugin" in
      ruby)
        asdf plugin-add "$plugin" https://github.com/uzxmx/asdf-ruby.git
        ;;
      java)
        # asdf plugin-add "$plugin" https://github.com/uzxmx/asdf-java.git
        hub download -d ~/.asdf/plugins/java halcyon/asdf-java 7a04f7c1a615370cc639d3ee02a91e99ecca27b5
        ;;
      *)
        asdf plugin-add "$plugin"
        ;;
    esac
  fi

  if [ "$plugin" = "nodejs" -a ! -e ~/.asdf/shims/node ]; then
    ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
  fi

  if [ -z "$package_version" ]; then
    package_version="$(parse_package_version $plugin)"
  fi
  asdf install "$plugin" "$package_version"
}
