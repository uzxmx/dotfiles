usage_upload() {
  cat <<-EOF
Usage: xcodeutils upload [--apiKey <key-id>] [--apiIssuer <issuer-id>] <path-to-ipa-file>

Upload an ipa file to AppStore and TestFlight.

Note: You must have a key file with name conforming to the format
'AuthKey_{apiKey}.p8' in some folder of your filesystem, such as
'~/.appstoreconnect/private_keys'. The '{apiKey}' in that format is also used
as the value of '--apiKey'. The key file can be downloaded from
https://appstoreconnect.apple.com/access/api.

You can also use 'APP_STORE_CONNECT_API_KEY' and 'APP_STORE_CONNECT_API_ISSUER'
environment variables to specify 'apiKey' and 'apiIssuer'.

Example:
  $> xcodeutils upload ~/Downloads/foo.ipa
EOF
  exit 1
}

cmd_upload() {
  local ipa_path
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --apiKey)
        shift
        APP_STORE_CONNECT_API_KEY="$1"
        ;;
      --apiIssuer)
        shift
        APP_STORE_CONNECT_API_ISSUER="$1"
        ;;
      *)
        ipa_path="$1"
        ;;
    esac
    shift
  done

  source "$dotfiles_dir/scripts/lib/prompt.sh"
  if [ -z "$APP_STORE_CONNECT_API_KEY" ]; then
    ask_for_input APP_STORE_CONNECT_API_KEY "API key ID: "
  fi

  if [ -z "$APP_STORE_CONNECT_API_ISSUER" ]; then
    ask_for_input APP_STORE_CONNECT_API_ISSUER "API issuer ID: "
  fi

  if [ -z "$ipa_path" ]; then
    ask_for_input ipa_path "Path to the ipa file: "
  fi

  [ ! -f "$ipa_path" ] && echo "File $ipa_path doesn't exist." && exit 1

  xcrun altool --upload-app --verbose \
    --file "$ipa_path" \
    --apiKey "$APP_STORE_CONNECT_API_KEY" \
    --apiIssuer "$APP_STORE_CONNECT_API_ISSUER"
}
alias_cmd u upload
