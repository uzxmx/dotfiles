usage_verify_site() {
  cat <<-EOF
Usage: xcodeutils verify_site

Verify apple-app-site-association file.

Options:
  -a, --app the path to .app in Payload of an IPA file
  -d, --domain the domain
  -v, --verbose show verbose info

Example:
  $> xcodeutils verify_site -a foo.app
  $> xcodeutils verify_site -d example.com
EOF
  exit 1
}

cmd_verify_site() {
  local app domains verbose
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -a | --app)
        shift
        app="$1"
        ;;
      -d | --domain)
        shift
        domains="$1" ;; -v | --verbose) verbose=1 ;;
      *)
        usage_verify_site
        ;;
    esac
    shift
  done

  if [ -z "$app" -a -z "$domains" ]; then
    usage_verify_site
  fi

  if [ -n "$app" ]; then
    [ ! -d "$app" ] && echo 'You must pass in a valid app path.' && exit 1
    domains="$(codesign -d --entitlements :- "$app" 2>/dev/null | grep applinks: | sed -E 's;.*<string>applinks:(.+)</string>;\1;')"
  fi

  ! type -p jq &> /dev/null && echo 'jq not found, please install jq first.' && exit 1

  try_url() {
    local url="$1"
    echo
    echo ">>>> Try url: $url"
    local output="$(curl -L --max-redirs 3 -s "$url" 2>/dev/null)"
    if [ -n "$verbose" ]; then
      echo "$output"
    fi
    if echo "$output" | jq .applinks &>/dev/null; then
      echo "<<<< Found a valid apple-app-site-association file at: $url"
      return 0
    else
      echo "<<<< Invalid"
      return 1
    fi
  }

  local domain
  while read domain; do
    try_url "https://$domain/.well-known/apple-app-site-association" || \
      try_url "https://$domain/apple-app-site-association" || \
      try_url "http://$domain/.well-known/apple-app-site-association" || \
      try_url "http://$domain/apple-app-site-association" || true
  done <<<"$domains"
}
