#!/bin/sh
#
# This script is a composite script which provides useful utilities for
# installing software on different systems.

. $(dirname "$BASH_SOURCE")/tmpfile.sh
. $(dirname "$BASH_SOURCE")/utils.sh
. $(dirname "$BASH_SOURCE")/git.sh
. $(dirname "$BASH_SOURCE")/dmg.sh

. $(dirname "$BASH_SOURCE")/path.sh

# Check if a command exists in the PATH.
check_command() {
  (PATH="$(new_path_exclude "$DOTFILES_DIR/bin" "$DOTFILES_DIR/bin_nim")" type -p "$1")
}

# Parse arguments.
remainder=()
while [ $# -gt 0 ]; do
  case "$1" in
    -*)
      if type usage &>/dev/null; then
        usage
      else
        echo "Unsupported option '$1'"
        exit 1
      fi
      ;;
    *)
      remainder+=("$1")
      ;;
  esac
  shift
done
set - "${remainder[@]}"
