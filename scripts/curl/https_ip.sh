usage_https_ip() {
  cat <<-EOF
Usage: curl https_ip [commit]

Request an HTTPS server by IP address, instead of domain name.

Normally, when requesting an HTTPS server by IP address, it will fail because
of the unmatched domain name with the certificate. This sub command works by using
curl's --resolve option to specify the given IP, and like normal case, you
still need to specify a matched domain name with the certificate.

Use '-' to delimit the end of this sub command's options, and all other options
following it will be passed into original curl.

Options:
  -d, --domain a domain name that matches the certificate
  -v, --verbose verbose output

Example:
  $> curl https_ip 127.0.0.1/foo -d example.com
  $> curl https_ip 127.0.0.1:8443/foo -d example.com
  $> curl https_ip https://127.0.0.1/foo -d example.com - -X POST
EOF
  exit 1
}

cmd_https_ip() {
  local url domain verbose
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d | --domain)
        shift
        domain="$1"
        ;;
      -v | --verbose)
        verbose=1
        ;;
      -)
        shift
        break
        ;;
      -*)
        usage_https_ip
        ;;
      *)
        url="$1"
        ;;
    esac
    shift
  done

  [ -n "$domain" ] || (echo 'Domain name is required.' && exit 1)

  local regexp="^(https:\\/\\/)?([0-9.]+)(:([0-9]+))?(.*)$"
  source "$DOTFILES_DIR/scripts/lib/gsed.sh"
  if ! echo "$url" | $SED -E "/$regexp/!{q1}" &>/dev/null; then
    echo "Invalid URL: $url"
    echo "URL should match the regular expression: $regexp"
    exit 1
  fi

  local ip="$(echo "$url" | $SED -E "s;$regexp;\2;")"
  local port="$(echo "$url" | $SED -E "s;$regexp;\4;")"
  local remainder="$(echo "$url" | $SED -E "s;$regexp;\5;")"
  cmd=(curl "https://$domain$remainder:${port:-443}" --resolve "$domain:${port:-443}:$ip" "$@")
  [ -z "$verbose" ] || echo "${cmd[@]}"
  "${cmd[@]}"
}
