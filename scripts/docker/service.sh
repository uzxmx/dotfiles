. "$(dirname "$BASH_SOURCE")/common.sh"

usage_service() {
  cat <<-EOF
Usage: docker s

Manage services.

Subcommands:
  l, ls, list - list services
  ps          - list the tasks of a service
EOF
  exit 1
}

cmd_service() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_service

  case "$cmd" in
    l | ls | list | ps)
      case "$cmd" in
        l | ls)
          cmd="list"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_service_$cmd" &>/dev/null && "usage_service_$cmd"
          ;;
      esac
      "cmd_service_$cmd" "$@"
      ;;
    *)
      usage_service
      ;;
  esac
}
alias_cmd s service

usage_service_list() {
  cat <<-EOF
Usage: docker s list

List services.
EOF
  exit 1
}

cmd_service_list() {
  docker service ls
}

usage_service_ps() {
  cat <<-EOF
Usage: docker s ps

List the tasks of a service.
EOF
  exit 1
}

cmd_service_ps() {
  local service="$(select_service)"
  [ -z "$service" ] && exit
  docker service ps "$service" --no-trunc
}
