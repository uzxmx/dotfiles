usage_root() {
  cat <<-EOF
Usage: g root

Show git root directory.
EOF
  exit 1
}

cmd_root() {
  git rev-parse --show-toplevel
}
