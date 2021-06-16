usage_ssh_key() {
  cat <<-EOF
Usage: gitlab ssh_key

Manage ssh keys.

Subcommands:
  l, list - list ssh keys for a user or current user
  a, add  - add ssh key for a user or current user
EOF
  exit 1
}

cmd_ssh_key() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_ssh_key

  case "$cmd" in
    l | list | a | add | d | delete)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        a)
          cmd="add"
          ;;
        d)
          cmd="delete"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_ssh_key_$cmd" &>/dev/null && "usage_ssh_key_$cmd"
          ;;
      esac
      "cmd_ssh_key_$cmd" "$@"
      ;;
    *)
      usage_ssh_key
      ;;
  esac
}
alias_cmd u ssh_key

usage_ssh_key_list() {
  cat <<-EOF
Usage: gitlab ssh_key list

List ssh keys for a user or current user. When no user is given, list for
current user.

Options:
  -u <id-or-username> The user ID or name
EOF
  exit 1
}

process_ssh_key_list_output() {
  jq -r '.[] | "ID: \(.id)\tTitle: \(.title)\tCreated at: \(.created_at)\tKey: \(.key)"' | column -t -s $'\t'
}

cmd_ssh_key_list() {
  local user
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -u)
        shift
        user="$1"
        ;;
      *)
        usage_ssh_key_list
        ;;
    esac
    shift
  done

  if [ -z "$user" ]; then
    req '/api/v4/user/keys?per_page=100' | process_ssh_key_list_output
  else
    req "/api/v4/users/$user/keys?per_page=100" | process_ssh_key_list_output
  fi
}

usage_ssh_key_add() {
  cat <<-EOF
Usage: gitlab ssh_key add

Add ssh key for a user or current user. When no user is given, add for current
user.

Options:
  -u <id> The user ID
  -t <title> The title
  -k <key> The public key
  -f <key-file> The public key file
EOF
  exit 1
}

cmd_ssh_key_add() {
  local user title key
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -u)
        shift
        user="$1"
        ;;
      -t)
        shift
        title="$1"
        ;;
      -k)
        shift
        key="$1"
        ;;
      -f)
        shift
        [ ! -e "$1" ] && echo "The key file $1 doesn't exist." && exit 1
        key="$(cat "$1")"
        ;;
      *)
        usage_ssh_key_add
        ;;
    esac
    shift
  done

  [ -z "$title" ] && echo "A title is required." && exit 1
  [ -z "$key" ] && echo "A key should be specified either by -k or -f" && exit 1

  local opts=(--data "title=$title" --data "key=$key")
  local req_path
  if [ -z "$user" ]; then
    req_path="/api/v4/user/keys"
  else
    req_path="/api/v4/users/$user/keys"
  fi
  req "$req_path" -XPOST "${opts[@]}"
}
