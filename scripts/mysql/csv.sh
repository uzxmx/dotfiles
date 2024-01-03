usage_csv() {
  cmd_csv -h
}

cmd_csv() {
  source "$DOTFILES_DIR/scripts/lib/go.sh"
  go_run_compiled "$mysql_dir/csv.go" "$@"

  echo "If you want to convert csv to excel, run below command:"
  echo
  echo "csv2xls --csv-delimiter , --csv-file-name file.csv --xls-file-name file.xls"
}
