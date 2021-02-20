usage_show() {
  cat <<-EOF
Usage: es show [type]

Show elasticsearch resources of a type.

Supported types:
  * n/node/nodes
  * i/index/indices

Options:
  -v log request to stderr
EOF
  exit 1
}

cmd_show() {
  local t
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -*)
        usage_show
        ;;
      *)
        t="$1"
        ;;
    esac
    shift
  done

  if [ -z "$t" ]; then
    t="$(fzf < <(cat <<EOF
nodes
indices
EOF
))"
  fi

  case "$t" in
    n | nodes?)
      t="nodes"
      ;;
    i | index | indices)
      t="indices"
      ;;
  esac

  req "/_cat/$t?v"
}
alias_cmd s show
