ALIYUN_CONFIG_FILE="$HOME/.aliyun/config.json"

process_profile_opts() {
  profile_opts=()

  if [ -n "$region" ]; then
    ALIYUN_REGION="$region"
  fi
  if [ -n "$ALIYUN_REGION" ]; then
    profile_opts+=(
      "--region=$ALIYUN_REGION"
    )
  fi

  if [ -n "$access_key_id" ]; then
    ALIYUN_ACCESS_KEY_ID="$access_key_id"
  fi
  if [ -n "$access_key_secret" ]; then
    ALIYUN_ACCESS_KEY_SECRET="$access_key_secret"
  fi

  if [ -n "$ALIYUN_ACCESS_KEY_ID" -a -n "$ALIYUN_ACCESS_KEY_SECRET" ]; then
    profile_opts+=(
      "--access-key-id=$ALIYUN_ACCESS_KEY_ID"
      "--access-key-secret=$ALIYUN_ACCESS_KEY_SECRET"
    )
  elif [ -n "$ALIYUN_PROFILE" ]; then
    profile_opts+=("--profile" "$ALIYUN_PROFILE")
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
  if [ -n "$func" ]; then
    local output
    output="$(aliyun "$@" "${profile_opts[@]}")"
    echo "$output" | $func
  else
    aliyun "$@" "${profile_opts[@]}"
  fi
}

_top_domains=(
  "com"
  "cn"
  "com.cn"
  "net"
  "co"
  "info"
  "me"
  "org"
)

remove_top_domain() {
  if [ -z "$_top_domains_for_sed" ]; then
    local top_domain
    for top_domain in "${_top_domains[@]}"; do
      if [ -n "$_top_domains_for_sed" ]; then
        _top_domains_for_sed="$_top_domains_for_sed|"
      fi
      _top_domains_for_sed="$_top_domains_for_sed$(echo ".$top_domain" | sed 's/\./\\./g')\$"
    done
  fi

  local domain="$(echo "$1" | sed -E "s/$_top_domains_for_sed//")"
  if [ "$domain" = "$1" ]; then
    echo "Cannot parse domain $1, please update top domains." >&2
    exit 1
  fi
  echo "$domain"
}

parse_rr() {
  local domain="$1"
  local rr
  domain="$(remove_top_domain "$domain")"
  rr="$(echo ".$domain" | sed -E 's/^(.*)\.[^\.]+$/\1/')"
  echo "$rr" | sed 's/^\.*//'
}

parse_primary_domain() {
  local domain="$1"
  local rr
  rr="$(parse_rr "$domain")"
  if [ -n "$rr" ]; then
    domain="$(echo "$domain" | sed "s/^$rr\.//")"
  fi
  echo "$domain"
}
