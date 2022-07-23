cmd_config() {
  local configfile="/usr/local/etc/v2ray/config.json"
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
