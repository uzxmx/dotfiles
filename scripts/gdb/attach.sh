source "$dotfiles_dir/scripts/gdb/common.sh"

usage_attach() {
  cat <<-EOF
Usage: gdb attach [--pid <pid>]

Attach to a running program.

$(common_help)

Options:
  --pid <pid> the process id to attach
EOF
  exit 1
}

cmd_attach() {
  local pid
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --pid)
        shift
        pid="$1"
        ;;
      *)
        usage_attach
        ;;
    esac
    shift
  done

  if [ -z "$pid" ]; then
    source "$dotfiles_dir/scripts/lib/ps.sh"
    pid="$(ps_fzf_select_pid)"
  fi

  run_gdb -p "$pid"
}
alias_cmd a attach
