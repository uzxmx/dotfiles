source "$(dirname "$BASH_SOURCE")/common.sh"

usage_filter() {
  "$qiniu_dir/filter.rb" -h
  exit 1
}

cmd_filter() {
  "$qiniu_dir/filter.rb" "$@"
}
alias_cmd f filter
