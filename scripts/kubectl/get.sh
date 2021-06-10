usage_get() {
  cat <<-EOF
Usage: kubectl get [type]

Get resources.

Supported types:
  * p/pod/pods
  * s/service/services
  * d/deployment/deployments
  * ss/statefulset/statefulsets
  * ds/daemonset/daemonsets
EOF
  exit 1
}

cmd_get() {
  local t
  local -a remainder
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -h)
        usage_get
        ;;
      *)
        if [ -z "$t" ]; then
          t="$1"
        else
          remainder+=("$1")
        fi
        ;;
    esac
    shift
  done
  set - "${remainder[@]}"

  if [ -z "$t" ]; then
    t="$(fzf < <(cat <<EOF
pods
services
deployments
statefulsets
daemonsets
EOF
))"
  fi

  case "$t" in
    p)
      t="pods"
      ;;
    s)
      t="services"
      ;;
    d)
      t="deployments"
      ;;
    ss)
      t="statefulsets"
      ;;
    ds)
      t="daemonsets"
      ;;
  esac

  run_cli get "$t" "$@"
}
alias_cmd g get
