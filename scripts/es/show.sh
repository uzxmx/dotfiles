usage_show() {
  cat <<-EOF
Usage: es show [type]

Show elasticsearch resources of a type.

Supported types:
  * n/node/nodes
  * i/index/indices
  * c/count: docs count

Options:
  -v log request to stderr
EOF
  exit 1
}

cmd_show() {
  local t
  local -a remainder
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -*)
        usage_show
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
nodes
indices
count
EOF
))"
  fi

  local subpath
  case "$t" in
    n | nodes?)
      t="nodes"
      ;;
    i | index | indices)
      t="indices"
      ;;
    c | count)
      t="count"
      subpath="$1"
      ;;
  esac

  if [ -z "$subpath" ]; then
    req "/_cat/$t?v"
  else
    req "/_cat/$t/$subpath?v"
  fi
}
alias_cmd s show
alias_cmd c show
alias_cmd cat show
