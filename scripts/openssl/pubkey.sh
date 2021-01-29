cmd_pubkey() {
  check_host "$@"
  openssl s_client -connect "$1:443" -servername "$1" 2>/dev/null < /dev/null | openssl x509 -pubkey -noout
}
