#!/bin/sh

if ! type asdf &>/dev/null; then
  if [ -f "$DOTFILES_TARGET_DIR/.asdf/asdf.sh" ]; then
    source "$DOTFILES_TARGET_DIR/.asdf/asdf.sh"
  fi
fi

plugin_installed() {
  asdf plugin-list | grep "$1" &>/dev/null
}

parse_package_version() {
  grep "$1" "$DOTFILES_DIR/tool-versions" | cut -d ' ' -f 2 | head -1
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
        "$DOTFILES_DIR/bin/hub" download -d "$DOTFILES_TARGET_DIR/.asdf/plugins/java" halcyon/asdf-java 7a04f7c1a615370cc639d3ee02a91e99ecca27b5
        ;;
      golang)
        "$DOTFILES_DIR/bin/hub" download -d "$DOTFILES_TARGET_DIR/.asdf/plugins/golang" kennyp/asdf-golang 9297fbefb1f95aaeadfd872b53d28e355a3e67e5
        ;;
      *)
        asdf plugin-add "$plugin"
        ;;
    esac
  fi

  if [ -z "$package_version" ]; then
    package_version="$(parse_package_version $plugin)"
  fi
  asdf install "$plugin" "$package_version"
}

find_package_path() {
  local version="$("$DOTFILES_DIR/bin/asdf" - list "$1" | awk '{print $1}' | grep "$2" | tail -1)"
  if [ -n "$version" ]; then
    "$DOTFILES_DIR/bin/asdf" - where "$1" "$version"
  fi
}
