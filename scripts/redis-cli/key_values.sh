usage_key_values() {
  cat <<-EOF
Usage: redis-cli key_values <output-dir>

Dump keys and values. Each key is used as the name of a file, and the value is
stored in the file.

Options:
  -r <regexp> Regular expression to filter keys
EOF
  exit 1
}

cmd_key_values() {
  local output_dir regexp
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -r)
        shift
        regexp="$1"
        ;;
      -*)
        usage_key_values
        ;;
      *)
        output_dir="$1"
        ;;
    esac
    shift
  done

  [ -z "$output_dir" ] && abort "An output directory is required."
  [ -d "$output_dir" ] && abort "Directory $output_dir already exists, please remove it first."

  source "$DOTFILES_DIR/scripts/lib/tmpfile.sh"
  create_tmpfile tmpfile
  $REDIS_CLI_CMD keys "*" >"$tmpfile"
  local key
  while read key; do
    local type="$($REDIS_CLI_CMD type "$key")"
    local dir="$output_dir/$type"
    mkdir -p "$dir"
    local cmd
    case "$type" in
      string)
        cmd="get"
        ;;
      set | zset)
        cmd="smembers"
        ;;
      hash)
        cmd="hgetall"
        ;;
      *)
        warn "Unsupported type $type"
        ;;
    esac
    $REDIS_CLI_CMD get "$key" >"$dir/$key"
  done < <(cat "$tmpfile")
}
