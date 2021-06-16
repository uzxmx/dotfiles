usage_user() {
  cat <<-EOF
Usage: gitlab user

Manage users.

Subcommands:
  l, list - list users
  g, get  - get a user or show current user
EOF
  exit 1
}

cmd_user() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_user

  case "$cmd" in
    l | list | g | get)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        g)
          cmd="get"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_user_$cmd" &>/dev/null && "usage_user_$cmd"
          ;;
      esac
      "cmd_user_$cmd" "$@"
      ;;
    *)
      usage_user
      ;;
  esac
}
alias_cmd u user

usage_user_list() {
  cat <<-EOF
Usage: gitlab user list

List users.
EOF
  exit 1
}

process_user_list_output() {
  jq -r '.[] | "ID: \(.id)\tName: \(.name)\tUsername: \(.username)\tState: \(.state)\tLast activity on: \(.last_activity_on)\tIs admin: \(.is_admin)"' | column -t -s $'\t'
}

cmd_user_list() {
  req '/api/v4/users?per_page=100' | process_user_list_output
}

usage_user_get() {
  cat <<-EOF
Usage: gitlab user get <domain-name>

Get a user or show current user.

Options:
  -u <id> The user ID
EOF
  exit 1
}

cmd_user_get() {
  local user
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -u)
        shift
        user="$1"
        ;;
      *)
        usage_user_get
        ;;
    esac
    shift
  done

  if [ -z "$user" ]; then
    req_path="/api/v4/user"
  else
    req_path="/api/v4/users/$user"
  fi
  req "$req_path"
}
