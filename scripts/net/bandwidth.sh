usage_bandwidth() {
  cat <<-EOF
Usage: net bandwidth [-4|-6] [-s <server-id>] [-- <speedtest-options>...]

Measure the current server's public-internet bandwidth (download, upload and
latency) using the official Ookla 'speedtest' CLI, which auto-selects the
nearest server for the most accurate result.

Options:
  -4              force IPv4
  -6              force IPv6
  -s <server-id>  test against a specific server (see 'speedtest -L')
  --              pass the remaining arguments to 'speedtest' verbatim
  -h              show this help

Examples:
  $> net bandwidth
  $> net bandwidth -4
  $> net bandwidth -s 1234
EOF
  exit 1
}

cmd_bandwidth() {
  local -a opts=(--accept-license --accept-gdpr)

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -4 | -6)
        opts+=("$1")
        ;;
      -s)
        shift
        opts+=("--server-id=$1")
        ;;
      --)
        shift
        opts+=("$@")
        break
        ;;
      -h | -*)
        usage_bandwidth
        ;;
    esac
    shift
  done

  if ! type -p speedtest &>/dev/null; then
    echo "Error: the Ookla 'speedtest' CLI is not installed." >&2
    echo "Install it with: $DOTFILES_DIR/scripts/install/speedtest" >&2
    return 1
  fi

  speedtest "${opts[@]}"
}
alias_cmd b bandwidth
