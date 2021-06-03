process_profile_opts() {
  profile_opts=()
  if [ -n "$AWS_PROFILE" ]; then
    profile_opts+=("--profile" "$AWS_PROFILE")
  fi
}

get_all_profiles_name() {
  list_profiles --only-name --not-show-current
}

list_profiles() {
  local no_header only_name not_show_current
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --no-header)
        no_header="1"
        ;;
      --only-name)
        only_name="1"
        no_header="1"
        ;;
      --not-show-current)
        not_show_current="1"
        ;;
    esac
    shift
  done

  local profile aws_access_key_id aws_secret_access_key region
  local default_aws_access_key_id="$(aws configure get --profile default aws_access_key_id)"
  local output="Name\tAccess Key ID\tSecret\tRegion"
  local profiles
  if [ -z "$default_aws_access_key_id" ]; then
    profiles="$(aws configure list-profiles)"
  else
    profiles="$(aws configure list-profiles | grep -v "^default$")
default"
  fi
  local default_found
  while read profile; do
    if [ "$profile" = "default" -a "$default_found" = "1" ]; then
      break
    fi
    aws_access_key_id="$(aws configure get --profile "$profile" aws_access_key_id)"
    aws_secret_access_key="$(aws configure get --profile "$profile" aws_secret_access_key)"
    region="$(aws configure get --profile "$profile" region)"
    output="$output\n"
    if [ "$aws_access_key_id" = "$default_aws_access_key_id" ]; then
      if [ "$not_show_current" != "1" ]; then
        profile="*$profile"
      fi
      default_found="1"
    fi
    if [ "$only_name" = "1" ]; then
      output="$output$profile"
    else
      output="$output$profile\t$aws_access_key_id\t$aws_secret_access_key\t$region"
    fi
  done < <(echo "$profiles")

  if [ "$no_header" = "1" ]; then
    echo -e "$output" | sed 1d | column -t -s $'\t'
  else
    echo -e "$output" | column -t -s $'\t'
  fi
}

select_profile() {
  local result
  if [ "$#" -gt 0 ]; then
    result="$(list_profiles --no-header | fzf "$@")"
  else
    result="$(list_profiles --no-header | fzf --nth=1)"
  fi
  if [ -n "$result" ]; then
    echo "$result" | awk '{print $1}' | sed 's/^\*//'
  fi
}

run_cli() {
  local func="$1"
  shift
  if [ -z "$func" ]; then
    aws "${profile_opts[@]}" "$@"
  else
    aws "${profile_opts[@]}" "$@" | $func
  fi
}
