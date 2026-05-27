usage_connect() {
  cat <<-EOF
Usage: warp connect

Connect to Cloudflare WARP.
EOF
  exit 1
}

cmd_connect() {
  warp-cli connect
}
alias_cmd c connect
