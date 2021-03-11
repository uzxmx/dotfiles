source "$aliyun_dir/common.sh"

usage_profile() {
  cat <<-EOF
Usage: aliyun profile

Manage profiles.

Subcommands:
  a, add    - add profile
  l, list   - list profiles
  d, delete - delete profile
  u, use    - set a default profile
EOF
  exit 1
}

cmd_profile() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_profile

  case "$cmd" in
    a | add | l | list | d | delete | u | use)
      case "$cmd" in
        a)
          cmd="add"
          ;;
        l)
          cmd="list"
          ;;
        d)
          cmd="delete"
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
Usage: aliyun profile add <profile>

Add profile.

To find a supported region, you can execute 'aliyun ecs regions'.

Options:
  -i access key id
  -s access key secret
  -r region, e.g. cn-shanghai, cn-shenzhen
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

  aliyun configure set -p "$profile" --access-key-id "$access_key_id" --access-key-secret "$access_key_secret" --region "$region"
}

cmd_profile_list() {
  aliyun configure list
}

usage_profile_delete() {
  cat <<-EOF
Usage: aliyun profile delete [profiles...]

Delete profile.

Options:
  -a delete all profiles
EOF
  exit 1
}

cmd_profile_delete() {
  local delete_all
  local -a profiles
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -a)
        delete_all=1
        ;;
      -*)
        usage_profile_delete
        ;;
      *)
        profiles+=("$1")
        ;;
    esac
    shift
  done

  source "$dotfiles_dir/scripts/lib/utils/common.sh"
  source "$dotfiles_dir/scripts/lib/utils/lines_to_array.sh"
  if [ "$delete_all" = "1" ]; then
    lines_to_array profiles < <(get_all_profiles_name)
  elif [ "${#profiles[@]}" -eq 0 ]; then
    lines_to_array profiles < <(select_profile -m)
  fi
  if [ "${#profiles[@]}" -gt 0 ]; then
    source "$dotfiles_dir/scripts/lib/prompt.sh"
    if [ "$(yesno "Are you sure you want to delete?(y/N)" no)" = "no" ]; then
      echo Cancelled
      exit 1
    fi

    for profile in "${profiles[@]}"; do
      aliyun configure delete --profile "$profile"
    done
  fi
}

cmd_profile_use() {
  local profile
  profile="$(select_profile)"
  aliyun configure set --profile "$profile"
}
