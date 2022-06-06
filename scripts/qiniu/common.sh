check_keys() {
  access_key="${access_key:-$QINIU_ACCESS_KEY}"
  secret_key="${secret_key:-$QINIU_SECRET_KEY}"
  [ -z "$access_key" ] && abort "QINIU_ACCESS_KEY is required"
  [ -z "$secret_key" ] && abort "QINIU_SECRET_KEY is required"

  true
}

check_keys_and_bucket() {
  check_keys

  bucket="${bucket:-$QINIU_BUCKET}"
  [ -z "$bucket" ] && abort "QINIU_SECRET_KEY is required"

  true
}

get_upload_token() {
  check_keys_and_bucket

  local key="$1"
  local insert_only="${2:-1}"

  # https://developer.qiniu.com/kodo/1206/put-policy
  local put_policy="$(cat <<EOF
{
  "scope": "$bucket:$key",
  "insertOnly": $insert_only,
  "deadline": $(($(date +%s) + 3600)),
  "returnBody": "{ \"key\": \$(key), \"name\": \$(fname), \"size\": \$(fsize), \"hash\": \$(etag) }"
}
EOF
)"

  local encoded="$(echo -n "$put_policy" | base64 | tr +/ -_)"
  local sign="$(echo -n "$encoded" | openssl sha1 -hmac "$secret_key" -binary | base64 | tr +/ -_)"
  echo "$access_key:$sign:$encoded"
}

_req() {
  check_keys

  local method="$1"
  local path="$2"
  local query="$3"
  local body="$4"
  local host="${5:-uc.qbox.me}"
  local content_type="${6:-application/x-www-form-urlencoded}"

  local str="$method $path"
  if [ -n "$query" ]; then
    str="$str?$query"
  fi
  str="$str\nHost: $host\nContent-Type: $content_type"
  str="$str\n\n"

  if [ "$content_type" != "application/octet-stream" ]; then
    str="$str$body"
  fi

  local sign="$(echo -en "$str" | openssl sha1 -hmac "$secret_key" -binary | base64 | tr +/ -_)"
  local access_token="$access_key:$sign"
  local url="https://$host$path"
  if [ -n "$query" ]; then
    url="$url?$query"
  fi
  curl -s -H "Authorization: Qiniu $access_token" -H "Content-Type: $content_type" "$url"
}

get_req() {
  _req GET "$@"
}
