source "$(dirname "$BASH_SOURCE")/common.sh"

usage_rmi() {
  cat <<-EOF
Usage: docker rmi [REGEXP]

Remove images in batch by editor. You can specify a regexp to grep images.
EOF
  exit 1
}

cmd_rmi() {
  source "$DOTFILES_DIR/scripts/lib/tmpfile.sh"
  create_tmpfile tmpfile

  cat >"$tmpfile" <<EOF
# Remove the lines if you want to keep the images.
#
EOF
  local format="table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}"
  if [ -n "$1" ]; then
    docker images --format "$format" | sed 1d | grep "$1" >>"$tmpfile"
  else
    docker images --format "$format" | sed 1d >>"$tmpfile"
  fi
  vi "$tmpfile"
  local ids reply
  ids=$(cat "$tmpfile" | grep -v "^#" | awk '{ print $3 }')

  source "$DOTFILES_DIR/scripts/lib/prompt.sh"
  reply=$(yesno "Are you sure you want to delete $(echo "$ids" | wc -l | awk '{ print $1 }') images? (y/N)" "no")
  [ "$reply" != "yes" ] && echo 'Cancelled' && exit

  echo "$ids" | while read id; do
    docker rmi $id || true
  done
}
