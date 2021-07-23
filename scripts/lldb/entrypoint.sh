usage_entrypoint() {
  "$dotfiles_dir/bin/otool" entrypoint -h
}

cmd_entrypoint() {
  "$dotfiles_dir/bin/otool" entrypoint "$@"
}
alias_cmd e entrypoint
