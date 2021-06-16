ALL_SCOPES=(
  api
  read_user
  read_repository
  write_repository
  sudo
)

usage_imp_token() {
  cat <<-EOF
Usage: gitlab imp_token

Manage impersonation tokens.

Subcommands:
  l, list - list impersonation tokens of a user
  a, add  - add an impersonation token for a user
EOF
  exit 1
}

cmd_imp_token() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_imp_token

  case "$cmd" in
    l | list | a | add)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        a)
          cmd="add"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_imp_token_$cmd" &>/dev/null && "usage_imp_token_$cmd"
          ;;
      esac
      "cmd_imp_token_$cmd" "$@"
      ;;
    *)
      usage_imp_token
      ;;
  esac
}

usage_imp_token_list() {
  cat <<-EOF
Usage: gitlab imp_token list <user_id>

List impersonation tokens of a user.
EOF
  exit 1
}

process_imp_token_list_output() {
  jq -r '.[] | "ID: \(.id)\tName: \(.name)\tScopes: \(.scopes)\tCreated at: \(.created_at)\tExpires at: \(.expires_at)\tRevoked: \(.revoked)\tActive: \(.active)"' | column -t -s $'\t'
}

cmd_imp_token_list() {
  local user_id="$1"
  [ -z "$user_id" ] && usage_imp_token_list
  req "/api/v4/users/$user_id/impersonation_tokens?per_page=100" | process_imp_token_list_output
}


usage_imp_token_add() {
  cat <<-EOF
Usage: gitlab imp_token add

Add an impersonation token for a user.

Options:
  -u <user_id> The ID of the user
  -n <name> The name of the impersonation token
  -e <expire_time> The expiration date of the impersonation token in ISO format (YYYY-MM-DD)
  -s <scopes> The array of scopes of the impersonation token, separated by comma.
              Supported scopes include: ${ALL_SCOPES[@]}.
              'all' can be specified to enable all scopes.
EOF
  exit 1
}

cmd_imp_token_add() {
  local user_id name scopes
  local -a opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -u)
        shift
        user_id="$1"
        ;;
      -n)
        shift
        name="$1"
        ;;
      -e)
        shift
        opts+=(--data "expires_at=$1")
        ;;
      -s)
        shift
        scopes="$1"
        ;;
      *)
        usage_imp_token_add
        ;;
    esac
    shift
  done

  [ -z "$user_id" ] && echo "A user id is required." && exit 1
  [ -z "$name" ] && echo "A name is required." && exit 1
  [ -z "$scopes" ] && echo "A scope is required." && exit 1

  local -a ary
  if [ "$scopes" = "all" ]; then
    ary=("${ALL_SCOPES[@]}")
  else
    source "$dotfiles_dir/scripts/lib/utils.sh"
    ary=($(split_by "$scopes" ,))
  fi
  local s
  for s in "${ary[@]}"; do
    opts+=(--data "scopes[]=$s")
  done

  req "/api/v4//users/$user_id/impersonation_tokens" -XPOST --data "name=$name" "${opts[@]}"
}
