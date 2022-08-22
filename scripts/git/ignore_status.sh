usage_ignore_status() {
  cat <<-EOF
Usage: g ignore_status [file]...

Check whether a file is ignored by git.
EOF
  exit 1
}

cmd_ignore_status() {
  git status --ignored "$@"
}
