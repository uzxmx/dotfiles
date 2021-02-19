usage_test() {
  cat <<-EOF
Usage: mvn test

This subcommand cleans the target before running the test.
EOF
  exit 1
}

cmd_test() {
  mvn clean test "$@"
}
