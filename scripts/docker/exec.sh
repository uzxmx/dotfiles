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
    if [ "$(docer exec "$id" bash -c "echo foo" 2>&1)" = "foo" ]; then
      docker exec -it "$id" bash
    else
      docker exec -it "$id" sh
    fi
  fi
}
alias_cmd e exec
