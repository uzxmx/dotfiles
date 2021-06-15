. "$(dirname "$BASH_SOURCE")/common.sh"

usage_logs() {
  cat <<-EOF
Usage: docker logs

Show logs of a container selected by fzf. Extra arguments will be passed to the
original intact.
EOF
  exit 1
}

cmd_logs() {
  local id="$(select_container)"
  [ -z "$id" ] && exit
  if [ "$#" -gt 0 ]; then
    docker logs "$id" "$@"
  else
    docker logs "$id" -f -n 10
  fi
}
alias_cmd l logs
