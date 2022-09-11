usage_list() {
  cat <<-EOF
Usage: acme list

List all issued certificates.
EOF
  exit 1
}

cmd_list() {
  run_acme --list
}
alias_cmd l list
