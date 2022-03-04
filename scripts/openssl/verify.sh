usage_verify() {
  cat <<-EOF
Usage: openssl verify

Verify a host.
EOF
  exit 1
}

cmd_verify() {
  check_host "$@"
  local host="$(echo "$1" | awk -F: '{print $1}')"
  local port="$(echo "$1" | awk -F: '{print $2}')"
  openssl s_client -connect "$host:${port:-443}" -servername "$host" < /dev/null
  show_expiration "$1"
}
alias_cmd v verify
