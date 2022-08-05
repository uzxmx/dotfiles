common_scripts_for_x509_help() {
  cat <<'EOF'
  cat <<-HELP
Usage: openssl $cmd <host | file>

$description

You can specify a host or a file. When specifying a host, the default port is 443. Shell
pipe is also supported.

Options:
  --host use the arg as a host
  --file use the arg as a file
  -d, --dry-run dry run
HELP
  exit 1
EOF
}

common_scripts_for_x509() {
  cat <<'EOF'
  local prefix arg arg_type
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --host)
        arg_type="host"
        ;;
      --file)
        arg_type="file"
        ;;
      -d | --dry-run)
        prefix="echo"
        ;;
      -*)
        $usage_fn
        ;;
      *)
        arg="$1"
        ;;
    esac
    shift
  done

  if [ ! -t 0 ]; then
    arg_type="file"
    arg="-"
  fi

  if [ "$arg_type" = "file" ] || [ -z "$arg_type" -a -e "$arg" ]; then
    $prefix "$OPENSSL_CMD" x509 -noout -in "$arg" "${x509_opts[@]}"
  else
    check_host "$arg"
    local host="$(echo "$arg" | awk -F: '{print $1}')"
    local port="$(echo "$arg" | awk -F: '{print $2}')"
    local cmd="echo | "$OPENSSL_CMD" s_client -connect \"$host:${port:-443}\" -servername \"$host\" 2>/dev/null | "$OPENSSL_CMD" x509 -noout "${x509_opts[@]}""
    ${prefix:-eval} "$cmd"
  fi
EOF
}
