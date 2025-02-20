usage_clean() {
  cat <<-EOF
Usage: g clean

Clean untracked files.
EOF
  exit 1
}

cmd_clean() {
  git clean -d -i
}
