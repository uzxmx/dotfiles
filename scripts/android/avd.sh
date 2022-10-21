source "$android_dir/common.sh"

usage_avd() {
  cat <<-EOF
Usage: android avd

Manage android virtual devices.

Subcommands:
  l, list - list avds
  u, up   - start an avd
EOF
  exit 1
}

cmd_avd() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_avd

  case "$cmd" in
    l | list | u | up)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        u)
          cmd="up"
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

cmd_avd_up() {
  local avd
  avd="$(select_avd)"
  # TODO emulator "@$avd" -http-proxy "http://localhost:8125" -dns-server localhost
  emulator "@$avd"
}
