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
    docker exec -it "$id" bash
  fi
}
alias_cmd e exec
