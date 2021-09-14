source "$(dirname "$BASH_SOURCE")/common.sh"

usage_bucket() {
  cat <<-EOF
Usage: qiniu bucket

Manage buckets.

Subcommands:
  l, list - list buckets
  g, get  - get a bucket
EOF
  exit 1
}

cmd_bucket() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_bucket

  case "$cmd" in
    l | list | g | get)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        g)
          cmd="get"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_bucket_$cmd" &>/dev/null && "usage_bucket_$cmd"
          ;;
      esac
      "cmd_bucket_$cmd" "$@"
      ;;
    *)
      usage_bucket
      ;;
  esac
}
alias_cmd b bucket

usage_bucket_list() {
  cat <<-EOF
Usage: qiniu bucket list

List buckets.

Options:
  -k <access_key> access key
  -s <secret_key> secret key
EOF
  exit 1
}

cmd_bucket_list() {
  source "$qiniu_dir/common_options.sh"
  get_req /buckets
}

usage_bucket_get() {
  cat <<-EOF
Usage: qiniu bucket get <bucket>

Get a bucket.

Options:
  -k <access_key> access key
  -s <secret_key> secret key
EOF
  exit 1
}

cmd_bucket_get() {
  source "$qiniu_dir/common_options.sh"

  if [ -z "$1" ]; then
    abort 'A bucket name is required.'
  fi

  get_req /v2/domains "tbl=$1"
}
