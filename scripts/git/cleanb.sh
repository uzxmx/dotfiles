usage_cleanb() {
  cat <<-EOF
Usage: g cleanb

Clean local branches that are gone on the remote.
EOF
  exit 1
}

cmd_cleanb() {
  git fetch -p

  local branch
  source "$dotfiles_dir/scripts/lib/prompt.sh"
  for branch in $(LANG=en_US git branch -vv | grep ': gone]' | awk '{print $1}'); do
    if [ "$(yesno "Sure to delete branch $branch? (y/N)" "no")" = "no" ]; then
      echo "Skip branch $branch"
    else
      git branch -D "$branch"
      echo "Branch $branch deleted"
    fi
  done
}
