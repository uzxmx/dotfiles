check_keys_and_bucket() {
  access_key="${access_key:-$QINIU_ACCESS_KEY}"
  secret_key="${secret_key:-$QINIU_SECRET_KEY}"
  bucket="${bucket:-$QINIU_BUCKET}"

  [ -z "$access_key" ] && abort "QINIU_ACCESS_KEY is required"
  [ -z "$secret_key" ] && abort "QINIU_SECRET_KEY is required"
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
