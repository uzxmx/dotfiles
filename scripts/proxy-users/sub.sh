usage_sub() {
  cat <<-EOF
Usage: proxy-users sub <name> [--clash]

Print share config for a user.
  (default)   one vless:// link per node; import into any client and pick a node
  --clash     a full clash/mihomo YAML subscription with GEOIP rules
              (China direct, everything else via your nodes)

Examples:
  proxy-users sub alice
  proxy-users sub alice --clash > alice.yaml
EOF
  exit 1
}

cmd_sub() {
  need jq
  require_config; require_meta

  local name="" clash=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --clash) clash=1 ;;
      -h) usage_sub ;;
      -*) die "Unknown argument '$1'" ;;
      *) [ -z "$name" ] && name="$1" || die "Unexpected argument '$1'" ;;
    esac
    shift
  done
  [ -z "$name" ] && usage_sub
  valid_name "$name"
  user_exists "$name" || die "User '$name' does not exist"

  load_meta
  if [ -n "$clash" ]; then
    print_sub_clash "$name"
  else
    print_sub "$name"
  fi
}
