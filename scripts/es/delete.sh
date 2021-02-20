. "$(dirname "$BASH_SOURCE")/common.sh"

usage_delete() {
  cat <<-EOF
Usage: es delete [type]

Delete index.

Options:
  -v log request to stderr
EOF
  exit 1
}

cmd_delete() {
  local index
  index="$(select_index)"
  if [ -z "$index" ]; then
    echo "There is no index available"
    exit 1
  fi
  source "$dotfiles_dir/scripts/lib/prompt.sh"
  if [ "$(yesno "Confirm to delete this index: $index? (y/N)" "no")" = "no" ]; then
    echo "Cancelled"
    exit
  fi
  req "/$index" -XDELETE
}
alias_cmd d delete
