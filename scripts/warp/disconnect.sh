usage_disconnect() {
  cat <<-EOF
Usage: warp disconnect

Disconnect from Cloudflare WARP.
EOF
  exit 1
}

cmd_disconnect() {
  warp-cli disconnect
}
alias_cmd d disconnect
