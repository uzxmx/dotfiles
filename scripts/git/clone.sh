usage_cl() {
  cat <<-EOF
Usage: g cl <url> [directory]

Clone with depth 1.

Options:
  -b the branch or tag to clone
  -r shallow clone submodules
EOF
  exit 1
}

cmd_cl() {
  local opts=(--depth 1)
  local dir url
  local -a opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -b)
        shift
        opts+=(-b "$1")
        ;;
      -r)
        opts+=(--recurse-submodules --shallow-submodules)
        ;;
      -*)
        usage_cl
        ;;
      *)
        if [ -z "$url" ]; then
          url="$1"
        elif [ -z "$dir" ]; then
          dir="$1"
        else
          usage_cl
        fi
        ;;
    esac
    shift
  done

  [ -z "$url" ] && usage_cl

  if [ -z "$dir" ]; then
    git clone "${opts[@]}" "$url"
  else
    git clone "${opts[@]}" "$url" "$dir"
  fi
}
