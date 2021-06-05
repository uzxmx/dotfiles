usage_connect() {
  cat <<-EOF
Usage: openssl connect <host | file>

Show connectiration info of a certificate. You can specify a host or a file. The
host should have port 443 open. Shell pipe is also supported.

Options:
  -CAfile <file> a certificate authority file with PEM format
  -d, --dry-run dry run

Example:
  $> openssl connect example.com
EOF
  exit 1
}

cmd_connect() {
  openssl s_client -connect foo.example.com:443

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
        usage_connect
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
    $prefix openssl x509 -enddate -noout -in "$arg"
  else
    check_host "$arg"
    local cmd="echo | openssl s_client -connect \"$arg:443\" -servername \"$arg\" 2>/dev/null | openssl x509 -noout -dates"
    ${prefix:-eval} "$cmd"
  fi
}
alias_cmd c connect
