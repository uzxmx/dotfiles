#!/bin/sh
#
# Find file hierarchically that the current directory is first checked, if not
# found, it goes up to parent directory and check, until root is reached.
#
# @params:
#   $1: the file name.
#   $2: the starting directory, optional, default to the current working directory.
#
# @example
#   find_file_hierarchical foo
#   find_file_hierarchical foo /tmp/bar/some-directory
find_file_hierarchical() {
  local name="$1"
  local dir="$(realpath "${2:-.}")"

  while true; do
    if [ -e "$dir/$name" ]; then
      echo "$dir/$name"
      break
    fi

    if [ "$dir" = "/" ]; then
      break
    fi

    dir="$(dirname $dir)"
  done
}
