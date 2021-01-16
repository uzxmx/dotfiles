select_plugin() {
  ls ~/.asdf/plugins | fzf "$@"
}
