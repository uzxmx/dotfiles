usage_client() {
  cat <<-EOF
Usage: shadowsocks client

Run as a local server. This will start a local socks server, and forward the traffic to a remote shadowsocks server.

Options:
  -l <address> the address to listen at for the socks server, with the form [ip]:<port>
               default is ':1080'
  -s <address> the address of the remote shadowsocks server to connect, with the form <ip>:<port>
  -p <password> the password to use when connecting to the remote server
  -c <cipher> the cipher to use when connecting to the remote server, default is AES-256-GCM
EOF
  exit 1
}

cmd_client() {
  local listen_addr=":1080"
  local server_addr password
  local cipher="AEAD_AES_256_GCM"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -l)
        shift
        listen_addr="$1"
        ;;
      -s)
        shift
        server_addr="$1"
        ;;
      -p)
        shift
        password="$1"
        ;;
      -c)
        shift
        cipher="$1"
        ;;
      *)
        usage_client
        ;;
    esac
    shift
  done

  [ -z "$server_addr" ] && abort "A remote server address is required"
  [ -z "$password" ] && abort "A password is required for authentication"

  go-shadowsocks2 -c "ss://$cipher:$password@$server_addr" -socks "$listen_addr" -verbose
}
alias_cmd c client
