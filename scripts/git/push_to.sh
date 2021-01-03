. "$dotfiles_dir/scripts/fzf/git-common"

usage_pt() {
  cat <<-EOF 1>&2
Usage: g pt

Push a local branch to a remote branch.
EOF
  exit 1
}

cmd_pt() {
  local local_branch remote_branch
  local_branch="$(select_branch -l -vv --prompt "Select a local branch> " --query="$(git branch --show-current)")"
  if [ -n "$local_branch" ]; then
    remote_branch="$(select_branch -r --prompt "Select a remote branch> ")"
  fi
  if [ -n "$local_branch" -a -n "$remote_branch" ]; then
    local remote_repo="$(echo "$remote_branch" | awk -F/ '{print $1}')"
    source "$dotfiles_dir/scripts/lib/prompt.sh"
    local cmd=(git push -f "$remote_repo" "$local_branch:$(echo "$remote_branch" | sed "s:^$remote_repo/::")")
    echo -e "Following command will be executed:\n\n\t${cmd[@]}\n"
    if [ "$(yesno "Continue? (y/N)" "no")" = "yes" ]; then
      "${cmd[@]}"
    fi
  fi
}
