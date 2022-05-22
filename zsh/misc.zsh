# Hook that zsh will invoke when a command cannot be found.
command_not_found_handler() {
  "$DOTFILES_DIR/scripts/misc/command_not_found_handler" "$@"
}
