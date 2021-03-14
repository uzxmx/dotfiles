usage_log() {
  cat <<-EOF
Usage: kubectl log

Show logs.

Options:
  -n, --tail <number> Number of lines to show from the end of the logs (default 10)
EOF
  exit 1
}

check_stern() {
  if ! type -p stern &>/dev/null; then
    "$dotfiles_dir/scripts/install/stern"
  fi
}

cmd_log() {
  local num
  local -a remainder
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -n | --tail)
        shift
        num="$1"
        ;;
      -h)
        usage_log
        ;;
      *)
        remainder+=("$1")
        ;;
    esac
    shift
  done

  check_stern
  stern --tail="${num:-10}" "${remainder[@]}"
}
alias_cmd l log
alias_cmd logs log
