usage_search() {
  cat <<-EOF
Usage: brew search <package-name>

Search remote packages.
EOF
  exit 1
}

cmd_search() {
  if [ "$#" -eq 0 ]; then
    usage_search
  fi
  brew search "$@"
}
alias_cmd s search
