. "$(dirname "$BASH_SOURCE")/common.sh"

usage_copy() {
  cat <<-EOF
Usage: docker copy <file>

Copy to/from a docker container.
EOF
  exit 1
}

cmd_copy() {
  local file="$1"
  if [ -z "$file" ]; then
    abort "A file is required"
  fi

  source "$DOTFILES_DIR/scripts/lib/prompt.sh"
  local upload="$(yesno "Upload? (Y/n)" "yes")"

  local id="$(select_container)"
  [ -z "$id" ] && exit

  if [ "$upload" = "yes" ]; then
    docker cp "$file" "$id:/tmp/$(basename "$file")"
  else
    docker cp "$id:$file" .
  fi
}
