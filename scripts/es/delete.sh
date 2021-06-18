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
  index="$(select_index -m --prompt "Select indices: ")"
  if [ -z "$index" ]; then
    echo "There is no index available"
    exit 1
  fi
  source "$dotfiles_dir/scripts/lib/prompt.sh"
  echo "Confirm to delete below index: "
  echo "$index"
  if [ "$(yesno "(y/N): " "no")" = "no" ]; then
    echo "Cancelled"
    exit
  fi
  for i in $index; do
    echo "Deleting index: $i"
    req "/$i" -XDELETE
    echo
  done
}
alias_cmd d delete
