usage_ocsp_req() {
  cat <<-EOF
Usage: openssl ocsp_req <host>

Send request to OCSP (Online Certificate Status Protocol) responder. It can
also be used to check if the server has enabled OCSP stapling (to improve
loading speed if access to the original OCSP responder is blocked from client).

When OCSP stapling is not enabled, performance problem may occur for new users.
It becomes even worse when it's hard to reproduce.

As a conclusion of my experiment, iOS system caches the certificate status
globally after the first successful return (I'm not sure about how long it will
be cached). Also there seems no way to clear the cache, so it may be hard to
reproduce if it suddenly becomes slow to access.

To reproduce it on the client device, use a proxy and deploy a new temporary
certificate (issued by the same issuer as production); or just use a new
device.

Options:
  --show-uri only show OCSP responder URI
  --stapling check if OCSP stapling is supported by the server
  -v, --verbose show verbose output

Example:
  $> openssl ocsp_req example.com
EOF
  exit 1
}

parse_ocsp_response() {
  echo "$1" | awk '
BEGIN { ocsp_section = 0 }
/OCSP Response Data:/ { ocsp_section = 1; print; next }
/^[^ ]/ { ocsp_section = 0 }
{ if (ocsp_section) print }
'
}

check_ocsp_cert_status() {
  if echo "$1" | grep -i 'Cert Status: good$' &>/dev/null; then
    echo 'Cert is good.'
  else
    echo 'Cert is not good.'
  fi
}

cmd_ocsp_req() {
  local show_uri uri check_stapling verbose arg
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --show-uri)
        show_uri=1
        ;;
      --stapling)
        check_stapling=1
        ;;
      -v | --verbose)
        verbose=1
        ;;
      -*)
        usage_ocsp_req
        ;;
      *)
        arg="$1"
        ;;
    esac
    shift
  done

  check_host "$arg"
  local host="$(echo "$arg" | awk -F: '{print $1}')"
  local port="$(echo "$arg" | awk -F: '{print $2}')"
  if [ "$check_stapling" = "1" ]; then
    local resp="$(parse_ocsp_response "$(openssl s_client -connect "$host:${port:-443}" -servername "$arg" -status < /dev/null 2>/dev/null)")"
    if [ -z "$resp" ]; then
      echo 'OCSP stapling is not enabled.'
    else
      [ "$verbose" = "1" ] && echo -e "$resp\n"
      echo "OCSP stapling is enabled."
      check_ocsp_cert_status "$resp"
    fi
    exit
  fi

  local cert_file="$(mktemp)"
  "$DOTFILES_DIR/bin/openssl" cert "$host" >"$cert_file"
  uri="$(openssl x509 -noout -ocsp_uri -in "$cert_file")"
  if [ "$show_uri" = "1" ]; then
    echo "OCSP Responder URI: $uri"
  else
    local chain_file="$(mktemp)"
    "$DOTFILES_DIR/bin/openssl" chain "$host" >"$chain_file"
    # It may result in "Bad Request" without "Host" header. See http://www.jfcarter.net/~jimc/documents/bugfix/21-openssl-ocsp.html.
    local resp="$(parse_ocsp_response "$(openssl ocsp -issuer "$chain_file" -cert "$cert_file" -text -url "$uri" -header Host "$(echo "$uri" | sed -E 's#(https?://)?([^/:]+).*#\2#')" 2>/dev/null)")"
    [ "$verbose" = "1" ] && echo -e "$resp\n"
    check_ocsp_cert_status "$resp"
    rm "$chain_file"
  fi
  rm "$cert_file"
}
