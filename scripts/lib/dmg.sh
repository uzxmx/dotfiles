#!/bin/sh

# Mount a dmg file, do something, and unmount in the end.
#
# @params:
#   $1: the dmg file
#   $2: the shell function to execute, the mount point will be passed as the only parameter
mount_dmg_and_do() {
  [ -z "$2" ] && return
  local file="$1"
  local output dev_node mount_point
  output="$(hdiutil attach "$file")"
  dev_node="$(echo "$output" | grep "^/dev/disk" | awk -F "\t" '{print $1}' | sed 's/ *$//')"
  mount_point="$(echo "$output" | grep "^/dev/disk" | awk -F "\t" '{print $3}')"
  $2 "$mount_point"
  hdiutil detach "$dev_node" &>/dev/null
}
