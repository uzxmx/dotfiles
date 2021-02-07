usage_rm_from_history() {
  cat <<-EOF
Usage: g rm_from_history <path>...

Remove files from git history.
EOF
  exit 1
}

cmd_rm_from_history() {
  [ "$#" -gt 0 ] || usage_rm_from_history

  local p paths
  for p in "$@"; do
    paths="\"$p\" $paths"
  done

  git filter-branch -f --prune-empty --index-filter "git rm -r --cached --ignore-unmatch $paths" HEAD
}
