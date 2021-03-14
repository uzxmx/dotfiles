. "$(dirname "$BASH_SOURCE")/common.sh"

usage_exec() {
  cat <<-EOF
Usage: kubectl exec

Execute a comand in a container selected by fzf.
EOF
  exit 1
}

cmd_exec() {
  if [ "$#" -gt 0 ]; then
    run_cli exec "$@"
  else
    local name="$(select_pod)"
    [ -z "$name" ] && exit
    if [ "$(run_cli exec "$name" -- bash -c "echo foo" 2>&1)" = "foo" ]; then
      run_cli exec -it "$name" -- bash
    else
      run_cli exec -it "$name" -- sh
    fi
  fi
}
alias_cmd e exec
