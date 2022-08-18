usage_rcup() {
  cat <<-EOF
Usage: vscode rcup

Setup rc files for vscode.
EOF
  exit 1
}

cmd_rcup() {
  "$DOTFILES_DIR/bin/vscode" sync_settings

  if is_mac; then
    local settings_path="$HOME/Library/Application Support/Code/User/settings.json"
    local target_path="$DOTFILES_DIR/tmp/vscode/settings.json"
    if ! is_link "$settings_path" "$target_path"; then
      if [ -L "$settings_path" -o -e "$settings_path" ]; then
        source "$DOTFILES_DIR/scripts/lib/prompt.sh"
        echo "File '$settings_path' already exists. Are you sure to remove it?"
        [ "$(yesno "(y/N)" "no")" = "no" ] && echo Cancelled && exit
        rm "$settings_path"
      fi
      ln -s "$target_path" "$settings_path"
    fi
  else
    abort "Unsupported system"
  fi
}
