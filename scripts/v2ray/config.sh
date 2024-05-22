usage_config() {
  cat <<-EOF
Usage: v2ray config [config-type]

The predefined config type includes 'socks_server'.
If no config type is specified, it will open an editor for you to edit.

Options:
  -f Force to overwrite the config file if it exists

Example:
  $> v2ray config socks_server -f
EOF
  exit 1
}

cmd_config() {
  local force config_type
  while [ $# -gt 0 ]; do
    case "$1" in
      -f)
        force=1
        ;;
      -*)
        usage_config
        ;;
      *)
        if [ -n "$config_type" ]; then
          abort "Only on config type can be specified"
        fi
        config_type="$1"
        ;;
    esac
    shift
  done

  local configfile="/usr/local/etc/v2ray/config.json"

  if [ -n "$config_type" ]; then
    local template
    case "$config_type" in
      socks_server)
        template="server/socks_config.json.sample"
        ;;
      *)
        abort "Unsupported config type '$config_type'"
        ;;
    esac
    [ -f "$configfile" ] && [ -z "$force" ] && abort "A config file already exists. You may specify '-f' to overwrite."
    sudo mkdir -p "$(dirname "$configfile")"
    sudo cp "$DOTFILES_DIR/v2ray/$template" "$configfile"
    "$DOTFILES_DIR/bin/v2ray" restart
  fi

  local old_md5
  if [ ! -e "$configfile" ]; then
    local template="$(find "$DOTFILES_DIR/v2ray" -name '*.json.sample' | fzf --prompt 'Select a template file to copy from: ')"
    [ -z "$template" ] && exit
    sudo mkdir -p "$(dirname "$configfile")"
    sudo cp "$template" "$configfile"
    sudo chmod a+w "$configfile"
  else
    old_md5="$(md5sum "$configfile" | awk '{print $1}')"
  fi
  if [ ! -w "$configfile" ]; then
    sudo chmod a+w "$configfile"
  fi

  "${EDITOR:-vi}" "$configfile"
  if [ ! "$old_md5" = "$(md5sum "$configfile" | awk '{print $1}')" ]; then
    "$DOTFILES_DIR/bin/v2ray" restart
  fi
}
alias_cmd c config
