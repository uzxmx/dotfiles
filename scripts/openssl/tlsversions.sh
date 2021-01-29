cmd_tlsversions() {
  check_host "$@"
  local versions=(1 1_1 1_2 1_3)
  for version in "${versions[@]}"; do
    expected=$(echo "Protocol *: *TLSv$version" | tr _ .)
    if openssl s_client -tls$version -connect "$1:443" -servername "$1" 2>/dev/null < /dev/null | grep "$expected" >/dev/null; then
      supported=
    else
      supported=not
    fi
    printf "TLSv%-3s %3s supported\n" "$version" "$supported" | tr _ .
  done
}
