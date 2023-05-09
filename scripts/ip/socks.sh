usage_socks() {
  cat <<-EOF
Usage: ip socks <host>:<port>

Get socks5 proxy IP.
EOF
  exit 1
}

cmd_socks() {
  local addr="$1"
  [ -z "$addr" ] && usage_socks

  local ip=$("$ip_dir/get_socks_proxy_ip.py" "$addr")
  if [ -n "$ip" ]; then
    echo "Socks proxy IP: $ip"
    echo 'Querying geo info...'
    "$DOTFILES_DIR/bin/ip" geo "$ip"
  fi
}
