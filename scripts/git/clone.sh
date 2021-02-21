usage_cl() {
  cat <<-EOF
Usage: g cl <url>

Clone with depth 1.

Options:
  -b the branch or tag to clone
  -d the directory to clone to
EOF
  exit 1
}

cmd_cl() {
  local opts=(--depth 1)
  local dir url
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -b)
        shift
        opts+=(-b "$1")
        ;;
      -d)
        shift
        dir="$1"
        ;;
      -*)
        usage_cl
        ;;
      *)
        url="$1"
        ;;
    esac
    shift
  done

  [ -z "$url" ] && usage_cl

  if [ -z "$dir" ]; then
    git clone "${opts[@]}" "$url"
  else
    git clone "${opts[@]}" "$url" "$directory"
  fi
}
