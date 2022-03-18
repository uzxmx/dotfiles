usage_init() {
  cat <<-EOF
Usage: bitbucket init

Make a new repo (under current folder) or move existing one in/to bitbucket.

Options:
  -n <name> Repo name to create, will ask you to input if not specified
  --no-interactive Do not ask to input, use the folder name as the repo name instead

Examples:
  # Create a repo named as 'bar' with project key 'FOO'.
  # Hint: you can get all project keys by 'bitbucket project list'.
  bitbucket init -k FOO -n bar
EOF
  exit 1
}

remote_added() {
  [ -n "$(git remote get-url $1 2>/dev/null)" ]
}

cmd_init() {
  check_workspace
  check_project_key

  local name no_interactive
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -n)
        shift
        name="$1"
        ;;
      --no-interactive)
        no_interactive=1
        ;;
      *)
        usage_init
        ;;
    esac
    shift
  done

  local rootdir="$(git rev-parse --show-toplevel 2>/dev/null)"
  if [ -z "$rootdir" ]; then
    git init
    rootdir="$(git rev-parse --show-toplevel 2>/dev/null)"
  fi

  local remote="origin"
  local add_remote="1"
  if remote_added "$remote"; then
    remote="bitbucket"
    if remote_added "$remote"; then
      unset add_remote
      echo "A remote with name bitbucket has already been added."
    fi
  fi

  if [ "$add_remote" = "1" ]; then
    source "$(dirname "$BASH_SOURCE")/repo.sh"

    if [ -z "$name" ]; then
      name="$(basename "$rootdir")"
      if [ -z "$no_interactive" ]; then
        source "$dotfiles_dir/scripts/lib/prompt.sh"
        ask_for_input name "Name for which repo to create: " "$name"
      fi
    fi

    local result
    if ! result=$(cmd_repo_get --show-git-url "$name" 2>/dev/null); then
      cmd_repo_create "$name"
      exit
    fi

    git remote add "$remote" "$result"
  fi

  local push_opts=()
  if [ "$remote" = "origin" ]; then
    push_opts+=(-u)
  fi
  git push "$remote" --all "${push_opts[@]}"
  git push "$remote" --tags
}
alias_cmd i init
