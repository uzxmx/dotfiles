. "$(dirname "$BASH_SOURCE")/common.sh"

usage_logs() {
  cat <<-EOF 1>&2
Usage: docker logs

Show logs of a container selected by fzf.
EOF
  exit 1
}

cmd_logs() {
  if [ "$#" -gt 0 ]; then
    docker logs "$@"
  else
    local id="$(select_container)"
    [ -z "$id" ] && exit
    docker logs -f "$id"
  fi
}
alias_cmd l logs
