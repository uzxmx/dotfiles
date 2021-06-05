usage_worktree() {
  cat <<-EOF
Usage: g worktree

Worktree utilities.

Subcommands:
  l, list   - list worktree
  a, add    - add worktree
  r, remove - remove worktree
EOF
  exit 1
}

cmd_worktree() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_worktree

  case "$cmd" in
    l | list | a | add | r | remove)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        a)
          cmd="add"
          ;;
        r)
          cmd="remove"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_worktree_$cmd" &>/dev/null && "usage_worktree_$cmd"
          ;;
      esac
      "cmd_worktree_$cmd" "$@"
      ;;
    *)
      usage_worktree
      ;;
  esac
}
alias_cmd w worktree

usage_worktree_list() {
  cat <<-EOF
Usage: g worktree list

List worktree.
EOF
  exit 1
}

cmd_worktree_list() {
  git worktree list
}

usage_worktree_add() {
  cat <<-EOF
Usage: g worktree add <path> [commit]

Create <path> and checkout <commit-ish> into it.
EOF
  exit 1
}

cmd_worktree_add() {
  local worktree_path commit
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -*)
        usage_worktree_add
        ;;
      *)
        if [ -z "$worktree_path" ]; then
          worktree_path="$1"
        else
          commit="$1"
        fi
        ;;
    esac
    shift
  done

  [ -z "$worktree_path" ] && echo "A worktree path is required." && exit 1

  if [ -z "$commit" ]; then
    source "$dotfiles_dir/scripts/fzf/git-common"
    commit="$(select_branch -a --prompt "Select a branch> ")"
    [ -z "$commit" ] && exit
  fi

  git worktree add "$worktree_path" "$commit"
}

usage_worktree_remove() {
  cat <<-EOF
Usage: g worktree remove

Remove worktree.
EOF
  exit 1
}

cmd_worktree_remove() {
  local result="$(cmd_worktree_list | fzf)"
  [ -z "$result" ] && exit
  local worktree_path="$(echo "$result" | awk '{print $1}')"

  source "$dotfiles_dir/scripts/lib/prompt.sh"
  if [ "$(yesno "Are you sure you want to delete the worktree at $worktree_path? (y/N)" "no")" = "yes" ]; then
    git worktree remove "$worktree_path" -f
  else
    echo Cancelled
  fi
}
