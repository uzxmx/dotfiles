. "$(dirname "$BASH_SOURCE")/common.sh"

usage_forward() {
  cat <<-EOF
Usage: kubectl forward <type> <ports>...

Forward one or more local ports to a pod.

Supported types:
  * p/pod
  * s/service
EOF
  exit 1
}

cmd_forward() {
  local -a remainder
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -h)
        usage_forward
        ;;
      *)
        remainder+=("$1")
        ;;
    esac
    shift
  done

  set - "${remainder[@]}"

  [ "$#" -lt 2 ] && usage_forward

  local target
  case "$1" in
    p | pod)
      target="$(select_pod)"
      [ -z "$target" ] && exit
      target="pod/$target"
      ;;
    s | service)
      target="$(select_service)"
      [ -z "$target" ] && exit
      target="service/$target"
      ;;
    *)
      echo "Unsupported type: $1"
  esac
  shift

  run_cli port-forward "$target" "$@"
}
alias_cmd f forward
