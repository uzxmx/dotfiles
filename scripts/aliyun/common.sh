ALIYUN_CONFIG_FILE="$HOME/.aliyun/config.json"

process_profile_opts() {
  profile_opts=()
  if [ -n "$ALIYUN_PROFILE" ]; then
    profile_opts+=("--profile" "$ALIYUN_PROFILE")
  elif [ -n "$ALIYUN_ACCESS_KEY_ID" -a -n "$ALIYUN_ACCESS_KEY_SECRET" ]; then
    profile_opts+=(
      "--access-key-id=$ALIYUN_ACCESS_KEY_ID"
      "--access-key-secret=$ALIYUN_ACCESS_KEY_SECRET"
    )
  fi
}

get_all_profiles_name() {
  cat "$ALIYUN_CONFIG_FILE" | jq -r '.profiles[].name'
}

select_profile() {
  get_all_profiles_name | fzf "$@"
}

run_cli() {
  local func="$1"
  shift
  if [ -z "$func" ]; then
    aliyun "${profile_opts[@]}" "$@"
  else
    aliyun "${profile_opts[@]}" "$@" | $func
  fi
}
