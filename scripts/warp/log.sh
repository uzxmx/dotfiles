usage_log() {
  cat <<-EOF
Usage: warp log

Show WARP service logs (follow mode).
EOF
  exit 1
}

cmd_log() {
  journalctl -u warp-svc -f
}
alias_cmd l log
