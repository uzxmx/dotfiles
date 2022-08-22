usage_update() {
  cat <<-EOF
Usage: brew update

Fetch the newest version of Homebrew and update taps (all formulae) from
GitHub.
EOF
  exit 1
}

cmd_update() {
  brew update -v "$@"
}
