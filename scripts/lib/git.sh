#!/bin/sh

# Check if the directory specified by the 2nd shell argument is already a git
# repository, if so, do nothin. Otherwise, clone from the remote url.
#
# @params:
#   $1: repository url
#   $2: directory to clone to
#   VARARGS: arguments which are passed to the clone command
git_clone() {
  local url="$1"
  local dir="$2"
  shift 2

  if [ ! -d "$dir" ] || ! (cd "$dir" && git status &> /dev/null); then
    git clone "$@" "$url" "$dir"
  fi
}
