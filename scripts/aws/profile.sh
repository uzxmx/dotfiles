source "$aws_dir/common.sh"

usage_profile() {
  cat <<-EOF
Usage: aws profile

Manage profiles.

Subcommands:
  a, add    - add profile
  l, list   - list profiles
  u, use    - set a default profile
EOF
  exit 1
}

cmd_profile() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_profile

  case "$cmd" in
    a | add | l | list | u | use)
      case "$cmd" in
        a)
          cmd="add"
          ;;
        l)
          cmd="list"
          ;;
        u)
          cmd="use"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_profile_$cmd" &>/dev/null && "usage_profile_$cmd"
          ;;
      esac
      "cmd_profile_$cmd" "$@"
      ;;
    *)
      usage_profile
      ;;
  esac
}

alias_cmd p profile

usage_profile_add() {
  cat <<-EOF
Usage: aws profile add <profile>

Add profile.

To find a supported region, you can execute 'aws ec2 regions'.

Options:
  -i access key id
  -s access key secret
  -r region, e.g. us-east-1, us-west-1
EOF
  exit 1
}

cmd_profile_add() {
  local profile access_key_id access_key_secret region
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -i)
        shift
        access_key_id="$1"
        ;;
      -s)
        shift
        access_key_secret="$1"
        ;;
      -r)
        shift
        region="$1"
        ;;
      -*)
        usage_profile_add
        ;;
      *)
        profile="$1"
        ;;
    esac
    shift
  done

  [ -z "$profile" ] && echo 'A profile name is required.' && exit 1
  [ -z "$access_key_id" ] && echo 'Access key id is required.' && exit 1
  [ -z "$access_key_secret" ] && echo 'Access key secret is required.' && exit 1
  [ -z "$region" ] && echo 'A region is required.' && exit 1

  aws configure set --profile "$profile" aws_access_key_id "$access_key_id"
  aws configure set --profile "$profile" aws_secret_access_key "$access_key_secret"
  aws configure set --profile "$profile" region "$region"
}

cmd_profile_list() {
  list_profiles
}

cmd_profile_use() {
  local profile aws_access_key_id aws_secret_access_key region
  profile="$(select_profile)"
  [ -z "$profile" ] && exit
  aws_access_key_id="$(aws configure get --profile "$profile" aws_access_key_id)"
  aws_secret_access_key="$(aws configure get --profile "$profile" aws_secret_access_key)"
  region="$(aws configure get --profile "$profile" region)"
  aws configure set default.aws_access_key_id "$aws_access_key_id"
  aws configure set default.aws_secret_access_key "$aws_secret_access_key"
  aws configure set default.region "$region"
}
