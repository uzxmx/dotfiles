usage_setup() {
  cat <<-EOF
Usage: warp setup [-p <port>]

Initialize WARP after first installation.

Options:
  -p <port>  proxy port (default: 40000)

Examples:
  \$> warp setup
  \$> warp setup -p 50000
EOF
  exit 1
}

cmd_setup() {
  local port=40000
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -p) port="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  warp-cli --accept-tos registration new
  warp-cli mode proxy
  warp-cli proxy port "$port"
  warp-cli connect
  warp-cli status
}
