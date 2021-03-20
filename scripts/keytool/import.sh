usage_import() {
  cat <<-EOF
Usage: keytool import <path-to-jks-file> <path-to-cert-pem>...

Import one or more certs to a keystore. The cert should be an X.509
certificate.

When multiple certificates are specified, the alias for each entry will be the
alias name appended with the index (starting from 1).

Options:
  -t <type> keystore type, default is jks
  -p <password> keystore password
  -a <alias> default is myalias
EOF
  exit 1
}

cmd_import() {
  local alias_name storetype jks_path
  local storepass="$KEY_STORE_PASS"
  local -a certs
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -t)
        shift
        storetype="$1"
        ;;
      -a)
        shift
        alias_name="$1"
        ;;
      -p)
        shift
        storepass="$1"
        ;;
      -*)
        usage_import
        ;;
      *)
        if [ -z "$jks_path" ]; then
          jks_path="$1"
        else
          certs+=("$1")
        fi
        ;;
    esac
    shift
  done

  [ -z "$jks_path" ] && echo "A keystore file is required." && exit 1
  [ "${#certs[@]}" -eq 0 ] && echo "At least a cert file should be specified." && exit 1

  source "$dotfiles_dir/scripts/lib/prompt.sh"
  if [ -z "$storepass" ]; then
    ask_for_input storepass "Store password: " changeit
  fi

  local opts=(
    -importcert --noprompt
    -storetype "${storetype:-jks}"
    -keystore "$jks_path"
    -storepass "$storepass"
  )

  alias_name="${alias_name:-myalias}"

  if [ "${#certs[@]}" -eq 1 ]; then
    keytool -alias "$alias_name" "${opts[@]}" -file "${certs[0]}"
  else
    local i="1"
    for cert in "${certs[@]}"; do
      keytool -alias "$alias_name$i" "${opts[@]}" -file "$cert"
      i="$((i + 1))"
    done
  fi

  source "$(dirname "$BASH_SOURCE")/list.sh"
  cmd_list -p "$storepass" "$jks_path"
}
alias_cmd i import
