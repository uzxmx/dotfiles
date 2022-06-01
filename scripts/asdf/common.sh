select_plugin() {
  ls "$ASDF_DATA_DIR/plugins" | fzf "$@"
}
