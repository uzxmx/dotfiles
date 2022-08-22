usage_tap() {
  cat <<-EOF
Usage: brew tap

Manage taps (Third-Party Repositories which provide a list of formulae).
EOF
  exit 1
}

cmd_tap() {
  brew tap "$@"
}
