usage_ps() {
  cat <<-EOF
Usage: docker ps

List containers.

Options:
  -a Show all containers
  -s <status> Filter by container status, can be 'exited'
EOF
  exit 1
}

cmd_ps() {
  local -a opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -s)
        shift
        opts+=(--filter "status=$1")
        ;;
      -a)
        opts+=("$1")
        ;;
      *)
        usage_ps
        ;;
    esac
    shift
  done

  docker ps "${opts[@]}"
}
