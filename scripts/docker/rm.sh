source "$(dirname "$BASH_SOURCE")/common.sh"

usage_rm() {
  cat <<-EOF
Usage: docker rm [container-id]...

Remove docker containers.

Options:
  -f Force to remove, do not confirm
  -c, --created Remove containers with created status
  -e, --exited <time> Remove containers exited before a time, e.g. 1h, 1 hour, 2d, 2 weeks, 5m, 3year
EOF
  exit 1
}

cmd_rm() {
  local container_status exit_before force_remove
  local -a ids
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -c | --created)
        container_status="created"
        ;;
      -e | --exited)
        shift
        container_status="exited"
        exit_before="$1"
        ;;
      -f)
        force_remove=1
        ;;
      -*)
        usage_rm
        ;;
      *)
        ids+=("$1")
        ;;
    esac
    shift
  done

  if [ -z "$container_status" ]; then
    local id
    if [ "${#ids[@]}" -eq 0 ]; then
      id="$(select_container)"
      [ -z "$id" ] && exit
      ids=("$id")
    fi
    if [ -n "$force_remove" ]; then
      docker rm -f "${ids[@]}"
    else
      source "$DOTFILES_DIR/scripts/lib/prompt.sh"
      for id in "${ids[@]}"; do
        echo -e "Confirm to remove below container?\n$(docker ps -f "id=$id" | sed 1d)"
        if [ "$(yesno "(y/N)" "no")" = "yes" ]; then
          docker rm -f "$id"
          echo Removed successfully
        else
          echo Cancelled
        fi
      done
    fi
    exit
  elif [ "$container_status" = "exited" -a -z "$exit_before" ]; then
    abort "A time must be specified when removing exited containers."
  fi

  local lines="$(docker ps --filter="status=$container_status" --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | sed 1d)"

  perl "$(dirname "$BASH_SOURCE")/rm_containers.pl" "$lines" "$exit_before"
}
