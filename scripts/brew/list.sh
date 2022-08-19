usage_list() {
  cat <<-EOF
Usage: brew list

List all installed packages (formulae and casks).
EOF
  exit 1
}

cmd_list() {
  brew list "$@"
}
alias_cmd l list
