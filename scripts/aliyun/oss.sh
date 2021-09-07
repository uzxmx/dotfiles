source "$aliyun_dir/common.sh"

usage_oss() {
  cat <<-EOF
Usage: aliyun oss

Manage OSS.

Subcommands:
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
    l | list | cp)
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
    *)
      usage_oss
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
