#!/bin/sh

_origin_name="$(basename "$0")"

update_origin_path() {
  _origin_path="$(source "$dotfiles_dir/scripts/lib/path.sh"; PATH="$(new_path_exclude "$dotfiles_dir/bin")"; which $_origin_name || true)"
}

update_origin_path

run_origin() {
  [ -z "$_origin_path" ] && echo "Cannot find the wrapped origin." >&2 && exit 1
  "$_origin_path" "$@"
}

ensure_origin_exists() {
  _origin_name="${1:-$_origin_name}"
  if ! type -p "$_origin_name" &>/dev/null; then
    echo "Oops, command '$_origin_name' not found." >&2

    echo -n "Would you like to install it? (Y/n)" >&2
    local input
    read input
    if ! [ -z "$input" -o "$input" = "Y" -o "$input" = "y" ]; then
      echo Cancelled. >&2
      exit
    fi

    local install_script="${2:-$_origin_name}"
    if [[ ! "$install_script" =~ ^/ ]]; then
      install_script="$dotfiles_dir/scripts/install/$install_script"
    fi

    "$install_script"
  fi
  update_origin_path
}
