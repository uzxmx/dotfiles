#!/bin/sh

source $(dirname "$BASH_SOURCE")/path.sh
PATH="$(new_path_exclude "$dotfiles_dir/bin")"

ensure_origin_exists() {
  local cmd="${1:-$(basename "$0")}"
  if ! type -p "$cmd" &>/dev/null; then
    echo "Oops, command '$cmd' not found." >&2

    echo -n "Would you like to install it? (Y/n)" >&2
    local input
    read input
    if ! [ -z "$input" -o "$input" = "Y" -o "$input" = "y" ]; then
      echo Cancelled. >&2
      exit
    fi

    local install_script="${2:-$cmd}"
    if [[ ! "$install_script" =~ ^/ ]]; then
      install_script="$dotfiles_dir/scripts/install/$install_script"
    fi

    "$install_script"
  fi

  true
}
