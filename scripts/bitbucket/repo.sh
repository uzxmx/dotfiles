usage_repo() {
  cat <<-EOF
Usage: bitbucket repo

Subcommands:
  l, list   - list repositories
  g, get    - get a repository
  c, create - create a repository
  d, delete - delete a repository
EOF
  exit 1
}

cmd_repo() {
  local cmd="$1"
  shift || true

  case "$cmd" in
    l | list | c | create | d | delete | g | get)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        c)
          cmd="create"
          ;;
        d)
          cmd="delete"
          ;;
        g)
          cmd="get"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_repo_$cmd" &>/dev/null && "usage_repo_$cmd"
          ;;
      esac
      "cmd_repo_$cmd" "$@"
      ;;
    *)
      usage_repo
      ;;
  esac
}
alias_cmd r repo

usage_repo_list() {
  cat <<-EOF
Usage: bitbucket repo list

List repositories.

Options:
  -w <workspace slug> workspace to use
EOF
  exit 1
}

# TODO add page and sort support
cmd_repo_list() {
  check_workspace

  req "repositories/$workspace?pagelen=100" | jq -r '.values[] | "Name: \(.name)\tCreated at: \(.created_on)\tUpdated at: \(.updated_on)"' | column -t -s $'\t'
}

usage_repo_get() {
  cat <<-EOF
Usage: bitbucket repo get [name]

Get a repository.

Options:
  -w <workspace slug> workspace to use
  -k <project key> project key to use
  --show-git-url output git url
EOF
  exit 1
}

git_url_from_full_name() {
  echo "git@bitbucket.org:$1.git"
}

cmd_repo_get() {
  check_workspace

  local name show_git_url
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --show-git-url)
        show_git_url=1
        ;;
      -*)
        usage_repo_get
        ;;
      *)
        name="$1"
        ;;
    esac
    shift
  done

  if [ -z "$name" ]; then
    source "$dotfiles_dir/scripts/lib/prompt.sh"
    ask_for_input name "Name for the repo to get: "
  fi
  local resp="$(req "repositories/$workspace/$name")"
  local slug="$(echo "$resp" | jq -r '.slug')"
  if [ "$slug" = "$name" ]; then
    if [ "$show_git_url" = "1" ]; then
      git_url_from_full_name "$(echo "$resp" | jq -r '.full_name')"
    else
      echo "$resp"
    fi
  else
    echo "Repo with name $name not exists" >&2
    exit 1
  fi
}

usage_repo_create() {
  cat <<-EOF
Usage: bitbucket repo create

Create a repository.

Options:
  -w <workspace slug> workspace to use
  -k <project key> project key to use
EOF
  exit 1
}

cmd_repo_create() {
  check_workspace
  check_project_key

  local name="$1"
  if [ -z "$name" ]; then
    source "$dotfiles_dir/scripts/lib/prompt.sh"
    ask_for_input name "Name for the repo to create: "
  fi
  local resp="$(req "repositories/$workspace/$name" -XPOST -H "Content-Type: application/json" -d"{
  \"scm\": \"git\",
  \"project\": { \"key\": \"$project_key\" },
  \"is_private\": true
}")"
  local slug="$(echo "$resp" | jq -r '.slug')"
  if [ "$slug" = "$name" ]; then
    local remote_url="$(git_url_from_full_name "$(echo "$resp" | jq -r '.full_name')")"
    source "$dotfiles_dir/scripts/lib/git.sh"
    git_try_initial_push "$remote_url" origin bitbucket
  else
    echo "$resp" >&2
    exit 1
  fi
}

usage_repo_create() {
  cat <<-EOF
Usage: bitbucket delete create

Delete a repository.

Options:
  -w <workspace slug> workspace to use
EOF
  exit 1
}

cmd_repo_delete() {
  check_workspace

  local name="$1"
  source "$dotfiles_dir/scripts/lib/prompt.sh"
  if [ -z "$name" ]; then
    ask_for_input name "Name for the repo to delete: "
  fi
  if cmd_repo_get "$name" >/dev/null; then
    local confirm
    ask_for_input confirm "Please type the name to confirm the deletion: "
    if [ "$confirm" = "$name" ]; then
      req "repositories/$workspace/$name" -XDELETE
      echo "Repo deleted"
    else
      echo "Cancelled"
    fi
  fi
}
