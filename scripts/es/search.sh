. "$(dirname "$BASH_SOURCE")/common.sh"

usage_search() {
  cat <<-EOF
Usage: es search [index]

Search index.

Options:
  -v log request to stderr
EOF
  exit 1
}

cmd_search() {
  local index="$1"
  if [ -z "$index" ]; then
    index="$(select_index)"
    if [ -z "$index" ]; then
      echo "There is no index available"
      exit 1
    fi
  fi
  req "/$index/_search"
}
alias_cmd s search
