. "$(dirname "$BASH_SOURCE")/common.sh"

usage_run() {
  cat <<-EOF
Usage: docker run

Run a docker image.
EOF
  exit 1
}

cmd_run() {
  if [ "$#" -gt 0 ]; then
    docker run "$@"
  else
    local image="$(select_image)"
    [ -z "$image" ] && exit
    docker run -it --rm --entrypoint="/bin/sh" "$image"
  fi
}
alias_cmd r run
