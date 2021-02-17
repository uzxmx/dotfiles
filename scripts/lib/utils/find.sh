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
  find_file_hierarchical_with_candidates . "$1"
}

# Find file hierarchically that the current directory is first checked, if not
# found, it goes up to parent directory and check, until root is reached. If
# the first candidate is not found, then the second is tried, and so on.
#
# @params:
#   $1: the starting directory
#   VARARGS: candidate files to find
#
# @example
#   find_file_hierarchical_with_candidates /starting-directory candidate1 candidate2
find_file_hierarchical_with_candidates() {
  local old_pwd="$(realpath "$1")"
  shift

  local name dir
  for name in "$@"; do
    dir="$old_pwd"
    while true; do
      if [ -e "$dir/$name" ]; then
        echo "$dir/$name"
        return
      fi

      if [ "$dir" = "/" ]; then
        break
      fi

      dir="$(dirname $dir)"
    done
  done
}
