#!/bin/sh

source "$(dirname "$BASH_SOURCE")/utils.sh"

source "$(dirname "$BASH_SOURCE")/path.sh"
PATH="$(new_path_exclude "$DOTFILES_DIR/bin")"

if [ -e "$PWN_DIR" ]; then
  PATH="$(new_path_exclude "$PWN_DIR/bin")"
fi

alias_cmd() {
  local new_name="$1"
  local old_name="$2"
  eval "
    usage_$new_name() {
      usage_$old_name \"\$@\"
    }
    cmd_$new_name() {
      cmd_$old_name \"\$@\"
    }
  "
}

run() {
  local cmd="$1"
  shift
  if [ "$#" -eq 1 -a "$1" = "-h" ]; then
    type "usage_$cmd" &>/dev/null && "usage_$cmd"
  fi
  "cmd_$cmd" "$@"
}

underscore_and_run() {
  local cmd="$(echo "$1" | tr - _)"
  shift
  case "$1" in
    -h)
      type "usage_$cmd" &>/dev/null && "usage_$cmd"
      ;;
  esac
  "cmd_$cmd" "$@"
}
