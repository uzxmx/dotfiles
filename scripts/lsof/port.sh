usage_port() {
  cat <<-EOF
Usage: lsof port <port>

Show port.

Options:
  --sudo Use sudo
  -p <protocol> Protocol, values include 'tcp' / 'udp', default is empty
  -s <state> Protocol state, values include 'listen', 'idle', etc.
EOF
  exit 1
}

cmd_port() {
  local port sudo protocol state
  local -a opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --sudo)
        sudo="sudo"
        ;;
      -p)
        shift
        protocol="$1"
        ;;
      -s)
        shift
        state="$1"
        ;;
      -*)
        usage_port
        ;;
      *)
        if [ -z "$port" ]; then
          port="$1"
        else
          abort "Only one port should be specified."
        fi
        ;;
    esac
    shift
  done

  [ -z "$port" ] && usage_port

  if [ -n "$state" ]; then
    [ -z "$protocol" ] && abort "A protocol must be specified by '-p'."
    opts+=(-s "$protocol:$state")
  fi

  $sudo lsof -nP -i "$protocol:$port" "${opts[@]}"
}
alias_cmd p port
