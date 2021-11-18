usage_restart() {
  cat <<-EOF
Usage: vpn restart

Restart ipsec VPN for client.
EOF
  exit 1
}

cmd_restart() {
  source "$vpn_dir/stop.sh"
  cmd_stop

  source "$vpn_dir/start.sh"
  cmd_start
}
