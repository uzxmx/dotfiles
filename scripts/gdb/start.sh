source "$dotfiles_dir/scripts/gdb/common.sh"

usage_start() {
  cat <<-EOF
Usage: gdb start <executable>

Start gdb and stop at the entrypoint.
By default, the stdin/stdout/stderr of the program is redirected to '/dev/null'.

$(common_help)

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

  before_gdbinit_post_hook="starti"

  run_gdb "$file"
}
alias_cmd s start
