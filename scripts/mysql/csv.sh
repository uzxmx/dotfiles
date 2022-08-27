usage_csv() {
  cmd_csv -h
}

cmd_csv() {
  source "$DOTFILES_DIR/scripts/lib/go.sh"
  go_run_compiled "$mysql_dir/csv.go" "$@"
}
