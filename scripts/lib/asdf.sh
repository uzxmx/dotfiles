#!/bin/sh

plugin_installed() {
  asdf plugin list | grep "$1" &>/dev/null
}

parse_package_version() {
  grep "^$1 " "$DOTFILES_DIR/tool-versions" | cut -d ' ' -f 2 | head -1
}

_ruby_ffi_workaround() {
  # error: call to undeclared function 'ffi_prep_closure'
  # Ref: https://github.com/ffi/ffi/issues/869
  export RUBY_CFLAGS=-DUSE_FFI_CLOSURE_ALLOC
}

install_plugin_package() {
  local plugin="$1"
  local package_version="$2"
  if ! plugin_installed "$plugin"; then
    case "$plugin" in
      ruby)
        asdf plugin add "$plugin" https://github.com/uzxmx/asdf-ruby.git
        ;;
      # java)
      #   # asdf plugin add "$plugin" https://github.com/uzxmx/asdf-java.git
      #   "$DOTFILES_DIR/bin/hub" download -d "$DOTFILES_TARGET_DIR/.asdf/plugins/java" halcyon/asdf-java 7a04f7c1a615370cc639d3ee02a91e99ecca27b5
      #   ;;
      # golang)
      #   "$DOTFILES_DIR/bin/hub" download -d "$DOTFILES_TARGET_DIR/.asdf/plugins/golang" kennyp/asdf-golang 9297fbefb1f95aaeadfd872b53d28e355a3e67e5
      #   ;;
      *)
        asdf plugin add "$plugin"
        ;;
    esac
  fi

  if [ -z "$package_version" ]; then
    package_version="$(parse_package_version $plugin)"
  fi

  if is_mac; then
    if [ "$plugin" = "ruby" ]; then
      case "$package_version" in
        2.4.10)
          local ssldir="$(brew --prefix openssl@1.1 2>/dev/null || true)"
          export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$ssldir"

          _ruby_ffi_workaround
          ;;
        2.7.1)
          _ruby_ffi_workaround
          ;;
      esac
    fi
  fi

  asdf install "$plugin" "$package_version"
}

find_package_path() {
  local version="$("$DOTFILES_DIR/bin/asdf" - list "$1" | awk '{print $1}' | grep "$2" | tail -1)"
  if [ -n "$version" ]; then
    "$DOTFILES_DIR/bin/asdf" - where "$1" "$version"
  fi
}
