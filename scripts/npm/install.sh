usage_install() {
  cat <<-EOF
Usage: npm install

This subcommand add '--verbose' option to the original subcommand.
EOF
  exit 1
}

cmd_install() {
  npm install --verbose "$@"
}
alias_cmd i install
