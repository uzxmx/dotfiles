#!/bin/sh

# When no executable is found and docker is available, it will be run by docker.
# Specify 'SELECT_VERSION=1' to select a version when there are multiple images.
#
# @params:
#   $1: the command name
#   $2: the optional image to check, can specify with a tag, default to the command name
#   $3: the optional image to pull when check fails, can specify with a tag, default to the checked image
check_cmd_with_docker_fallback() {
  local cmd="$1"
  local image_to_check="${2:-$cmd}"
  local image_to_pull="${3:-$image_to_check}"
  if type -p "$cmd" &>/dev/null; then
    echo "$cmd"
  elif type -p docker &>/dev/null; then
    local version="$(docker images  --format "{{.Repository}}:{{.Tag}}" "$image_to_check")"
    if [ -z "$version" ]; then
      [ "$(yesno "$cmd is not found in the PATH, but docker is found. Do you want to run it by docker? (Y/n)" "yes")" = "no" ] && echo Cancelled && exit 1
      docker pull "$image_to_pull"
      version="$image_to_pull"
    elif [ "$(echo "$version" | wc -l)" -gt 1 ]; then
      if [ "$SELECT_VERSION" = "1" ]; then
        version="$(echo "$version" | fzf --prompt "Select a version> ")"
      else
        version="$(echo "$version" | head -1)"
      fi
    fi
    echo "docker run --rm --network host $version $cmd"
  else
    # Still return the cmd even if it fails.
    echo "$cmd"
  fi
}
