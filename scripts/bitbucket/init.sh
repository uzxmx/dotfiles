usage_init() {
  cat <<-EOF
Usage: bitbucket init

Make a new repo (under current folder) or move existing one in/to bitbucket.
EOF
  exit 1
}

remote_added() {
  [ -n "$(git remote get-url $1 2>/dev/null)" ]
}

cmd_init() {
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

  source "$dotfiles_dir/scripts/lib/prompt.sh"
  if [ "$add_remote" = "1" ]; then
    source "$(dirname "$BASH_SOURCE")/repo.sh"

    local name result
    ask_for_input name "Name for which repo to create: " "$(basename "$rootdir")"
    if ! result=$(cmd_repo_get --show-git-url "$name" 2>/dev/null); then
      if ! result="$(cmd_repo_create "$name")"; then
        echo "$result"
        exit 1
      fi
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
