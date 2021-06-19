source "$android_dir/common.sh"

usage_avd() {
  cat <<-EOF
Usage: android avd

Wrapper for android virtual device manager.

Subcommands:
  l, list - list avds
EOF
  exit 1
}

cmd_avd() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_avd

  case "$cmd" in
    l | list)
      case "$cmd" in
        l)
          cmd="list"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_avd_$cmd" &>/dev/null && "usage_avd_$cmd"
          ;;
      esac
      "cmd_avd_$cmd" "$@"
      ;;
    *)
      usage_avd
      ;;
  esac
}
alias_cmd a avd

cmd_avd_list() {
  list_avds
}
