usage_fzf() {
  cat <<-EOF
Usage: ps fzf

Select a process by fzf. When a process is selected, output its details.
EOF
  exit 1
}

cmd_fzf() {
  source "$DOTFILES_DIR/scripts/lib/ps.sh"
  local pid
  pid="$(ps_fzf_select_pid)"
  [ -z "$pid" ] && exit
  echo "pid: $pid"
  echo "ppid: $(ps -p "$pid" -o ppid | sed 1d)"
  echo "command and arguments: $(ps -p "$pid" -o command | sed 1d)"
  echo "time started: $(ps -p "$pid" -o start | sed 1d)"
  echo "elapsed running time: $(ps -p "$pid" -o etime | sed 1d)"
  echo "full name of control terminal: $(ps -p "$pid" -o tty | sed 1d)"
}
