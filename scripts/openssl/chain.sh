cmd_chain() {
  check_host "$@"
  local host="$(echo "$1" | awk -F: '{print $1}')"
  local port="$(echo "$1" | awk -F: '{print $2}')"
  "$OPENSSL_CMD" s_client -showcerts -connect "$host:${port:-443}" -servername "$host" </dev/null 2>&1 | awk '
BEGIN { first_cert = 1 }
/-----BEGIN/ { cert_section = 1 }
{ if (!first_cert && cert_section) print }
/-----END/ { cert_section = 0; first_cert = 0 }
'
}
