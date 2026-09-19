usage_list() {
  cat <<-EOF
Usage: proxy-users list

List users and the nodes each one has.
EOF
  exit 1
}

cmd_list() {
  need jq
  require_config
  [ "$1" = "-h" ] && usage_list

  {
    printf 'USER\tNODES\n'
    read_config | jq -r '
      [.inbounds[] | select(.tag=="vless-in") | .settings.clients[].email]
      | map({ name: sub("-[^-]+$";""), node: sub("^.*-";"") })
      | group_by(.name)
      | map("\(.[0].name)\t\([.[].node] | join(","))")
      | .[]
    '
  } | column -t -s $'\t'
}
