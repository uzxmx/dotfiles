source "$aliyun_dir/common.sh"

usage_oss() {
  cat <<-EOF
Usage: aliyun oss

Manage OSS.

Subcommands:
  mb      - Make bucket
  l, list - List buckets or objects
  cp      - upload, download or copy objects
EOF
  exit 1
}

cmd_oss() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_oss

  case "$cmd" in
    mb | l | list | cp)
      case "$cmd" in
        l)
          cmd="list"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_oss_$cmd" &>/dev/null && "usage_oss_$cmd"
          ;;
      esac
      "cmd_oss_$cmd" "$@"
      ;;
    -*)
      usage_oss
      ;;
    *)
      aliyun oss "$cmd" "$@"
      exit
      ;;
  esac
}
alias_cmd o oss

usage_oss_list() {
  cat <<-EOF
Usage: aliyun oss list [bucket]

List buckets when no bucket is given.

When a bucket is given, list all objects inside the bucket. If the region of
current profile is not matched with the region of the bucket, you need to
switch to the region of the bucket by '--region' option.

Use '--help' to get the original help.

Options:
  --region <region> the region of the bucket
EOF
  exit 1
}

cmd_oss_list() {
  local opt
  for opt in "$@"; do
    if [ "$opt" = "-h" ]; then
      usage_oss_list
    fi
  done

  process_profile_opts
  run_cli '' oss ls "$@"
}

usage_oss_cp() {
  cat <<-EOF
Usage: aliyun oss cp <src> <dst>

Upload, download or copy objects.

Use '--help' to get the original help.

Options:
  --region <region> the region of the bucket

Examples:
  aliyun oss cp foo.txt oss://bucket/foo.txt
  aliyun oss cp oss://bucket/foo.txt foo.txt
EOF
  exit 1
}

cmd_oss_cp() {
  local opt
  for opt in "$@"; do
    if [ "$opt" = "-h" ]; then
      usage_oss_cp
    fi
  done

  process_profile_opts
  run_cli '' oss cp "$@"
}

usage_oss_mb() {
  cat <<-EOF
Usage: aliyun oss mb <bucket-name>

Create a bucket.

Options:
  -e <endpoint-region> the endpoint region, default is 'cn-shanghai', you can execute 'aliyun ecs regions' to get one
  -a <acl> the access mode, values can be 'public-read-write' / 'public-read' / 'private', default is 'private'
EOF
  exit 1
}

cmd_oss_mb() {
  local bucket
  local endpoint_region="cn-shanghai"
  local acl="private"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -e)
        shift
        endpoint_region="$1"
        ;;
      -a)
        shift
        acl="$1"
        ;;
      -*)
        usage_oss_mb
        ;;
      *)
        if [ -z "$bucket" ]; then
          bucket="$1"
        else
          abort "Only one bucket name should be specified."
        fi
    esac
    shift
  done

  [ -z "$bucket" ] && abort "A bucket name should be specified."

  process_profile_opts
  run_cli '' oss mb --endpoint "oss-$endpoint_region.aliyuncs.com" --acl "$acl" "oss://$bucket"
}
