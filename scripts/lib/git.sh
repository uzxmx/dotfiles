#!/bin/sh

# Check if the directory specified by the 2nd shell argument is already a git
# repository, if so, do nothing. Otherwise, clone from the remote url.
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

# Git shallow clone.
#
# @params:
#   $1: repository url
#   $2: directory to clone to
#   VARARGS: arguments which are passed to the clone command
git_shallow_clone() {
  local url="$1"
  local dir="$2"
  shift 2
  git_clone "$url" "$dir" --depth 1 "$@"
}

# This function tries to find a proper remote name that doesn't exist in the
# local repo. If all exist, an empty name will be output.
#
# @params
#   VARARGS: candidate remote names
git_try_remote_names() {
  local name
  for name in "$@"; do
    if ! git remote | grep -Fx "$name" &>/dev/null; then
      echo "$name"
      exit
    fi
  done
}

# This function tries to find a proper remote name that doesn't exist in the
# local repo. If one is found, it pushes to the remote. If this is the first
# remote, it also tracks it as upstream.
#
# @params
#   $1: the remote url
#   VARARGS: candidate remote names
git_try_initial_push() {
  local remote_url="$1"
  shift
  local remote_name="$(git_try_remote_names "$@")"
  if [ -z "$remote_name" ]; then
    echo "All candidate remote names exist. Please push to $remote_url manually." >&2
  else
    local -a opts
    if [ -z "$(git remote)" ]; then
      opts+=("-u")
    fi
    git remote add "$remote_name" "$remote_url"
    git push "${opts[@]}" "$remote_name" "refs/heads/*" --tags
  fi
}
