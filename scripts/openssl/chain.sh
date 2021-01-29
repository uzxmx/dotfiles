cmd_chain() {
  check_host "$@"
  openssl s_client -showcerts -connect "$1:443" -servername "$1" </dev/null 2>&1 | awk '
BEGIN { first_cert = 1 }
/-----BEGIN/ { cert_section = 1 }
{ if (!first_cert && cert_section) print }
/-----END/ { cert_section = 0; first_cert = 0 }
'
}
