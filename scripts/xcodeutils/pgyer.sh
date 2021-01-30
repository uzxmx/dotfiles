usage_pgyer() {
  cat <<-EOF
Usage: xcodeutils pgyer [--apiKey key] <path-to-ipa-file>

Upload an ipa file to pgyer (https://www.pgyer.com).

Note: You need to specify an API key by --apiKey option or PGYER_API_KEY
environment variable.

Options:
  --apiKey <key> api key

Example:
  $> xcodeutils pgyer foo.ipa
EOF
  exit 1
}

cmd_pgyer() {
  local ipa_path api_key
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --apiKey)
        shift
        PGYER_API_KEY="$1"
        ;;
      *)
        ipa_path="$1"
        ;;
    esac
    shift
  done

  source "$dotfiles_dir/scripts/lib/prompt.sh"
  if [ -z "$PGYER_API_KEY" ]; then
    ask_for_input PGYER_API_KEY "API key: "
  fi

  if [ -z "$ipa_path" ]; then
    ask_for_input ipa_path "Path to an ipa file: "
  fi

  [ ! -f "$ipa_path" ] && echo "File $ipa_path doesn't exist." && exit 1

  local resp="$(curl -F "file=@$ipa_path" -F "_api_key=$PGYER_API_KEY" "https://www.pgyer.com/apiv2/app/upload")"
  if type jq &>/dev/null; then
    echo "$resp" | jq
    if [ "$(echo "$resp" | jq -r ".code")" = "0" ]; then
      local shortcut_url="$(echo "$resp" | jq -r ".data.buildShortcutUrl")"
      echo "You can download the app here: https://www.pgyer.com/$shortcut_url"
    fi
  else
    echo "$resp"
    echo "To download the app, extract 'buildShortcutUrl' from the above output, and append it to the url https://www.pgyer.com/."
  fi
}
