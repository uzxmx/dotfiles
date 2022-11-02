usage_encode() {
  cat <<-EOF
Usage: url encode <data>

Encode a string to be url-safe. Note this encodes the whole string, so if you
specify a string like 'foo=bar', the '=' character will also be encoded.
EOF
  exit 1
}

cmd_encode() {
  local data
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -f)
        shift
        file="$1"
        ;;
      -*)
        usage_encode
        ;;
      *)
        data="$1"
        ;;
    esac
    shift
  done

  [ -z "$data" ] && usage_encode

  source "$DOTFILES_DIR/scripts/lib/url.sh"

  if check_command curl &>/dev/null; then
    url_encode_by_curl "$data"
  elif check_command jq &>/dev/null; then
    url_encode_by_jq "$data"
  elif check_command ruby &>/dev/null; then
    url_encode_by_ruby "$data"
  else
    abort "Please make sure you have one of these installed: curl/jq/ruby"
  fi
}
alias_cmd e encode
