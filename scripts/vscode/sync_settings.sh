usage_sync_settings() {
  cat <<-EOF
Usage: vscode sync_settings

Render settings file from a template.
EOF
  exit 1
}

cmd_sync_settings() {
  source "$DOTFILES_DIR/scripts/lib/template.sh"
  mkdir -p "$DOTFILES_DIR/tmp/vscode"
  render_shell_template_file "$DOTFILES_DIR/vscode/settings.json.tpl.sh.ofc" | sed "/^#/d" >"$DOTFILES_DIR/tmp/vscode/settings.json"
}
