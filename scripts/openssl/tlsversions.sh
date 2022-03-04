cmd_tlsversions() {
  check_host "$@"
  local versions=(1 1_1 1_2 1_3)
  local host="$(echo "$1" | awk -F: '{print $1}')"
  local port="$(echo "$1" | awk -F: '{print $2}')"
  for version in "${versions[@]}"; do
    expected=$(echo "Protocol *: *TLSv$version" | tr _ .)
    if openssl s_client -tls$version -connect "$host:${port:-443}" -servername "$host" 2>/dev/null < /dev/null | grep "$expected" >/dev/null; then
      supported=
    else
      supported=not
    fi
    printf "TLSv%-3s %3s supported\n" "$version" "$supported" | tr _ .
  done
}
