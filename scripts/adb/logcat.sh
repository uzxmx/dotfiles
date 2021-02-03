source "$(dirname "$BASH_SOURCE")/common.sh"

usage_logcat() {
  cat <<-EOF
Usage: adb logcat

Enhanced adb logcat.

Options:
  -p only print logs from the given pid (specify - to select one by fzf)
  --help show original help
EOF
  exit 1
}

cmd_logcat() {
  local pid
  local -a opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -p)
        shift
        pid="$1"
        ;;
      --help)
        exec adb logcat -h
        ;;
    esac
    shift
  done

  local device
  device="$(select_device)"

  if [ "$pid" = "-" ]; then
    pid="$(select_process "$device")"
  fi

  if [ -n "$pid" ]; then
    opts+=("--pid=$pid")
  fi

  adb -s "$device" logcat "${opts[@]}"
}
alias_cmd l logcat
