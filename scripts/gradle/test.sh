usage_test() {
  cat <<-EOF
Usage: gradle test

This subcommand add '--info' option to the original subcommand.
EOF
  exit 1
}

cmd_test() {
  "$gradle_bin" test --info "$@"
}
