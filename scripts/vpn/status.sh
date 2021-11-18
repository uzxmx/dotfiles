usage_status() {
  cat <<-EOF
Usage: vpn status

Show VPN status.
EOF
  exit 1
}

cmd_status() {
  check_route_command

  local gw="$(ip route | awk '/default/ { print $3 }' | head -1)"
  if echo "$gw" | grep '^ppp0$' &>/dev/null; then
    echo "VPN is running."
  else
    echo "VPN is NOT running."
  fi
}
