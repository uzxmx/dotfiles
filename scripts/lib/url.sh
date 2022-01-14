#!/bin/sh

# This function parses the host from a given HTTP url.
#
# @params:
#   $1: the HTTP url
#   $2: whether to remove the port
url_get_host() {
  local url="$1"
  local remove_port="$2"

  url="$(echo "$url" | sed -E "s/^https?:\/\///")"
  url="$(echo "$url" | sed -E "s/^([^\/]+).*$/\1/")"

  if [ "$remove_port" = "1" ]; then
    echo "$url" | sed "s/:.*$//"
  else
    echo "$url"
  fi
}

# This function parses the path from a given HTTP url.
#
# @params:
#   $1: the HTTP url
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
