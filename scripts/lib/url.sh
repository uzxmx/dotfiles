#!/bin/sh

# This function parses the path part from a given url.
#
# @params:
#   $1: the url
#   $2: whether to remove the prefixed slash
url_get_path() {
  local url="$1"
  local remove_prefix_slash="$2"

  url="$(echo "$url" | sed -E "s/^https?:\/\///")"
  url="$(echo "$url" | sed -E "s/^[^\/]+//")"
  url="$(echo "$url" | sed -E "s/\?.*$//")"

  if [ "$remove_prefix_slash" = "1" ]; then
    echo "$url" | sed "s/^\///"
  else
    echo "$url"
  fi
}
