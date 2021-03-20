usage_list() {
  cat <<-EOF
Usage: keytool list [path-to-jks-file]

List entries in a keystore. By default, it uses jks keystore type. A jks file
must be specified if '-ca' option is not specified.

Options:
  -ca show CA keystore

  -t <type> keystore type, default is jks
  -p <password> keystore password
  -rfc output in RFC style
  -v verbose output

  --aliases list all aliases
  -a <alias> the alias of the entry to show
EOF
  exit 1
}

cmd_list() {
  local jks_path storetype ca rfc verbose
  local list_aliases alias_name
  local storepass="$KEY_STORE_PASS"
  local -a opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -ca)
        ca=1
        ;;
      -t)
        shift
        storetype="$1"
        ;;
      -p)
        shift
        storepass="$1"
        ;;
      -rfc)
        rfc=1
        ;;
      -v)
        verbose=1
        ;;
      --aliases)
        list_aliases=1
        ;;
      -a)
        shift
        alias_name="$1"
        ;;
      -*)
        usage_list
        ;;
      *)
        jks_path="$1"
        ;;
    esac
    shift
  done

  if [ "$list_aliases" = "1" ]; then
    opts+=(-v)
  else
    if [ "$rfc" = "1" ]; then
      opts+=(-rfc)
    elif [ "$verbose" = "1" ]; then
      opts+=(-v)
    fi

    if [ -n "$alias_name" ]; then
      opts+=(-alias "$alias_name")
    fi
  fi

  local cmd
  if [ "$ca" = "1" ]; then
    cmd=(keytool -list -cacerts -storepass "${storepass:-changeit}" "${opts[@]}")
  elif [ -n "$jks_path" ]; then
    if [ -n "$storepass" ]; then
      opts+=(-storepass "$storepass")
    fi
    cmd=(keytool -list -keystore "$jks_path" -storetype "${storetype:-jks}" "${opts[@]}")
  else
    usage_list
  fi

  if [ "$list_aliases" = "1" ]; then
    "${cmd[@]}" | grep 'Alias name:'
  else
    "${cmd[@]}"
  fi
}
alias_cmd l list
