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

# This function encodes a string to be url-safe. Note this encodes the whole
# string, so if you specify a string like `foo=bar`, the `=` character will
# also be encoded.
#
# @params:
#   $1: the string to be url encoded
url_encode() {
  url_encode_by_curl "$@"
}

url_encode_by_jq() {
  jq -rn --arg x "$1" '$x|@uri'
}

url_encode_by_curl() {
  local result="$(curl -s -o /dev/null --max-time 0.001 -w %{url_effective} --get --data-urlencode "=$1" "http://localhost:1")"
  echo "${result##http://localhost:1/?}"
}

url_encode_by_ruby() {
  ruby -e "require 'uri'; puts URI.encode_www_form_component('$1')"
}
