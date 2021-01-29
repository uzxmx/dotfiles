cmd_verify() {
  check_host "$@"
  openssl s_client -connect "$1:443" -servername "$1" < /dev/null
  show_expiration "$1"
}
alias_cmd v verify
