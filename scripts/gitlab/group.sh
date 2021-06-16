usage_group() {
  cat <<-EOF
Usage: gitlab group

Manage groups.

Subcommands:
  l, list - list groups
EOF
  exit 1
}

cmd_group() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_group

  case "$cmd" in
    l | list)
      case "$cmd" in
        l)
          cmd="list"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_group_$cmd" &>/dev/null && "usage_group_$cmd"
          ;;
      esac
      "cmd_group_$cmd" "$@"
      ;;
    *)
      usage_group
      ;;
  esac
}
alias_cmd g group

usage_group_list() {
  cat <<-EOF
Usage: gitlab group list

List groups.
EOF
  exit 1
}

process_group_list_output() {
  jq -r '.[] | "ID: \(.id)\tName: \(.name)\tPath: \(.path)\tDescription: \(.description)"' | column -t -s $'\t'
}

cmd_group_list() {
  req '/api/v4/groups' | process_group_list_output
}
