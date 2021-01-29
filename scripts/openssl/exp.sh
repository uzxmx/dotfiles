usage_exp() {
  cat <<-EOF
Usage: openssl exp <host | file>

Show expiration info of a certificate. You can specify a host or a file. The
host should have port 443 open. Shell pipe is also supported.

Options:
  --host use the arg as a host
  --file use the arg as a file
  -d, --dry-run dry run

Example:
  $> openssl exp example.com
EOF
  exit 1
}

cmd_exp() {
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
        usage_exp
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
alias_cmd e exp
