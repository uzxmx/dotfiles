usage_start() {
  cat <<-EOF
Usage: lldb start <executable>

Start lldb and stop at the entrypoint.
By default, the stdin/stdout/stderr of the program is redirected to '/dev/null'.

Options:
  -i <file> where the stdin is redirected
  -o <file> where the stdout is redirected
  -e <file> where the stderr is redirected
EOF
  exit 1
}

cmd_start() {
  local stdin stdout stderr
  local file="$1"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -i)
        shift
        stdin="$1"
        ;;
      -o)
        shift
        stdout="$1"
        ;;
      -e)
        shift
        stderr="$1"
        ;;
      -*)
        usage_start
        ;;
      *)
        file="$1"
        ;;
    esac
    shift
  done

  if [ ! -x "$file" ]; then
    echo "An executable file is required"
    exit 1
  fi

  local lldb_commands="$(cat <<EOF
process launch --stop-at-entry -i "${stdin:-/dev/null}" -o "${stdout:-/dev/null}" -e "${stderr:-/dev/null}"
dis -p
EOF
)"

  lldb -s <(echo "$lldb_commands") "$file"
}
alias_cmd s start
