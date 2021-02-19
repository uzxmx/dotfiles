. "$(dirname "$BASH_SOURCE")/common.sh"

usage_exec() {
  cat <<-EOF
Usage: docker exec

Execute a comand in a container selected by fzf.
EOF
  exit 1
}

cmd_exec() {
  if [ "$#" -gt 0 ]; then
    docker exec "$@"
  else
    local id="$(select_container)"
    [ -z "$id" ] && exit
    source "$dotfiles_dir/scripts/lib/prompt.sh"
    local cmd
    ask_for_input cmd "Command: " sh
    docker exec -it "$id" "$cmd"
  fi
}
alias_cmd e exec
