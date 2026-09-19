usage_del() {
  cat <<-EOF
Usage: proxy-users del <name>

Remove a user and all of their per-node UUIDs, and drop their emails from
the routing rules.

Example:
  proxy-users del alice
EOF
  exit 1
}

cmd_del() {
  need jq
  require_config

  local name="$1"
  [ -z "$name" ] && usage_del
  [ "$name" = "-h" ] && usage_del
  valid_name "$name"
  user_exists "$name" || die "User '$name' does not exist"

  read_config | jq --arg name "$name" '
    (.inbounds[] | select(.tag=="vless-in") | .settings.clients)
      |= map(select((.email | sub("-[^-]+$";"")) != $name))
    | .routing.rules |= map(
        if (.outboundTag // "" | startswith("n-"))
        then .user |= (map(select((. | sub("-[^-]+$";"")) != $name)))
        else . end)
    | .routing.rules |= map(select((.inboundTag != null) or ((.user // []) | length > 0)))
  ' | write_config

  reload_xray
  echo "Removed '$name'."
}
