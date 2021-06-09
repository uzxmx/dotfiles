#!/bin/sh

# Output new path.
#
# @params:
#   VARARGS: variable paths to be excluded
new_path_exclude() {
  local result="$PATH"
  local sanitized_path
  for i in "$@"; do
    sanitized_path="$(dirname $i)/$(basename $i)"
    result=$(echo "$result" | sed -E -e "s#([^:]*:?)${sanitized_path}/{0,1}(:.*|$)#\1\2#g" -e "s#:+#:#g")
  done
  echo $result
}
