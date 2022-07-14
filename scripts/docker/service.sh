. "$(dirname "$BASH_SOURCE")/common.sh"

usage_service() {
  cat <<-EOF
Usage: docker service

Manage services.

Subcommands:
  i, inspect  - show the config of a service
  l, ls, list - list services
  ps          - list the tasks of a service
  log, logs   - show logs of a service
  u, update   - update the config of a service, e.g. replicas
EOF
  exit 1
}

cmd_service() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_service

  case "$cmd" in
    i | inspect | l | ls | list | ps | log | logs | u | update)
      case "$cmd" in
        i)
          cmd="inspect"
          ;;
        l | ls)
          cmd="list"
          ;;
        logs)
          cmd="log"
          ;;
        u)
          cmd="update"
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
Usage: docker service list

List services.
EOF
  exit 1
}

cmd_service_list() {
  docker service ls
}

usage_service_ps() {
  cat <<-EOF
Usage: docker service ps

List the tasks of a service.
EOF
  exit 1
}

cmd_service_ps() {
  local service="$(select_service)"
  [ -z "$service" ] && exit
  docker service ps "$service" --no-trunc
}

usage_service_log() {
  cat <<-EOF
Usage: docker service log

Show logs of a service. Extra arguments will be passed to the original intact
EOF
  exit 1
}

cmd_service_log() {
  local service="$(select_service)"
  [ -z "$service" ] && exit

  if [ "$#" -gt 0 ]; then
    docker service logs "$service" "$@"
  else
    docker service logs "$service" -f -n 10
  fi
}

usage_service_inspect() {
  cat <<-EOF
Usage: docker service inspect <service>

Show the config of a service.

Options:
  -o <file> File to output
EOF
  exit 1
}

cmd_service_inspect() {
  local service outfile
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -o)
        shift
        outfile="$1"
        ;;
      -*)
        usage_service_update
        ;;
      *)
        if [ -z "$service" ]; then
          service="$1"
        else
          abort "Only one service should be specified."
        fi
        ;;
    esac
    shift
  done

  if [ -z "$service" ]; then
    service="$(select_service)"
  fi
  [ -z "$service" ] && exit

  local result
  result=$(docker service inspect "$service")

  echo "$result" | less
}

usage_service_update() {
  cat <<-EOF
Usage: docker service update <service>

Update the config of a service.

Options:
  -f Force update even if no changes require it
  -r <replicas> Number of tasks
  --env-add <env> Add or update an environment variable
  --env-rm <env> Remove an environment variable
EOF
  exit 1
}

cmd_service_update() {
  local service
  local -a opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -f)
        opts+=(--force)
        ;;
      -r)
        shift
        opts+=(--replicas "$1")
        ;;
      --env-add)
        shift
        opts+=(--env-add "$1")
        ;;
      --env-rm)
        shift
        opts+=(--env-rm "$1")
        ;;
      -*)
        usage_service_update
        ;;
      *)
        if [ -z "$service" ]; then
          service="$1"
        else
          abort "Only one service should be specified."
        fi
        ;;
    esac
    shift
  done

  [ "${#opts[@]}" -eq 0 ] && usage_service_update

  if [ -z "$service" ]; then
    service="$(select_service)"
  fi
  [ -z "$service" ] && exit

  docker service update "$service" "${opts[@]}"
}
