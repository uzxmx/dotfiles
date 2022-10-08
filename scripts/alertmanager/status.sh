usage_status() {
  cat <<-EOF
Usage: alertmanager status

Show status.
EOF
  exit 1
}

cmd_status() {
  get_req /api/v2/status | jq
}
alias_cmd s status
