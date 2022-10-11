usage_setup_dotfiles() {
  "$DOTFILES_DIR/scripts/bootstrap/setup_remote" -h
}

cmd_setup_dotfiles() {
  "$DOTFILES_DIR/scripts/bootstrap/setup_remote" "$@"
}
