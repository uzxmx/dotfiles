usage_start() {
  cat <<-EOF
Usage: lldb start <executable>

Start lldb and stop at the entrypoint.
By default, the stdin/stdout/stderr of the program is redirected to '/dev/null'.

This script also imports 'lldb_extra' directory in this dotfiles repo to
PYTHONPATH, so you can use anything provided by 'lldb_extra' when you're in the
python interpreter.

You can put lldb commands in a file named as 'lldbinit.post' in current working
directory, it will be loaded when the program stops at the entrypoint.

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

  local lldbinit_post
  if [ -f lldbinit.post ]; then
    lldbinit_post="$(cat lldbinit.post)"
  fi

  local lldb_commands="$(cat <<EOF
command script import $dotfiles_dir/lldb_extra
command script import $dotfiles_dir/lldb_extra/commands.py
process launch --stop-at-entry -i "${stdin:-/dev/null}" -o "${stdout:-/dev/null}" -e "${stderr:-/dev/null}"
$lldbinit_post
dis -p
EOF
)"

  lldb -s <(echo "$lldb_commands") "$file"
}
alias_cmd s start
