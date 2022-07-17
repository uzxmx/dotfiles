usage_keys() {
  cat <<-EOF
Usage: redis-cli keys

Dump all keys to a file.

Options:
  -o <file> File to output
EOF
  exit 1
}

cmd_keys() {
  local file
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -o)
        shift
        file="$1"
        ;;
      *)
        usage_keys
        ;;
    esac
    shift
  done

  [ -z "$file" ] && abort "An output file is required."
  [ -f "$file" ] && abort "File $file already exists."

  $REDIS_CLI_CMD keys "*" >"$file"
}
