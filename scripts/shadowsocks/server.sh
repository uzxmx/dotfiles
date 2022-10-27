usage_server() {
  cat <<-EOF
Usage: shadowsocks server

Run as a remote server.

Options:
  -l <address> the address to listen at, with the form [ip]:<port>
  -p <password> the password to use for authentication
  -c <cipher> the cipher to use, default is AES-256-GCM
EOF
  exit 1
}

cmd_server() {
  local listen_addr password
  local cipher="AEAD_AES_256_GCM"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -l)
        shift
        listen_addr="$1"
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
        usage_server
        ;;
    esac
    shift
  done

  [ -z "$listen_addr" ] && abort "A listen address is required"
  [ -z "$password" ] && abort "A password is required"

  go-shadowsocks2 -s "ss://$cipher:$password@$listen_addr" -verbose
}
alias_cmd s server
