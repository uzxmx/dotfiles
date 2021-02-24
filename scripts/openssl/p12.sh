usage_p12() {
  cat <<-EOF
Usage: openssl p12 <file>

PKCS#12 utilities.

Options:
  -p <password> file pass phrase
EOF
  exit 1
}

cmd_p12() {
  local file
  local -a opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -p)
        shift
        opts+=(-passin pass:"$1")
        ;;
      -*)
        usage_p12
        ;;
      *)
        file="$1"
        ;;
    esac
    shift
  done

  openssl pkcs12 -in "$file" -nodes "${opts[@]}"
}
