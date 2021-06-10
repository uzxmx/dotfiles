usage_mirror() {
  cat <<-EOF
Usage: pip mirror [-e | -d]

Manage(show/enable/disable) pip mirror. By default it shows whether mirror is
enabled.

Options:
  -e Enable mirror
  -d Disable mirror
EOF
  exit 1
}

cmd_mirror() {
  local action="show"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -e)
        action="enable"
        ;;
      -d)
        action="disable"
        ;;
      *)
        usage_mirror
        ;;
    esac
    shift
  done

  if [ "$action" = "enable" ]; then
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
  elif [ "$action" = "disable" ]; then
    pip config unset global.index-url
  fi
  pip config list | grep global.index-url=
}
