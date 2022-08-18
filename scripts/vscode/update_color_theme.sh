usage_update_color_theme() {
  cat <<-EOF
Usage: vscode update_color_theme

Update color theme for vscode.
EOF
  exit 1
}

cmd_update_color_theme() {
  "$DOTFILES_DIR/bin/vscode" sync_settings

  local options="Default Dark+
Default Light+"
  local theme settings_file json
  theme=$(echo "$options" | fzf --prompt "Select a color theme: ")
  settings_file="$DOTFILES_DIR/tmp/vscode/settings.json"
  json=$(cat "$settings_file" | jq ". += {\"workbench.colorTheme\": \"$theme\"}")
  if [ -n "$json" ]; then
    echo "$json" >"$settings_file"
  fi
}
