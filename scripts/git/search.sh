usage_search() {
  cat <<-EOF
Usage: g search

Search file contents in the git history.

For more info, please visit https://git-scm.com/book/en/v2/Git-Tools-Searching

Examples:
  # Search a string, showing oneline format.
  g s -S ' sed ' --pretty="format:%h %<(30,trunc)%s %ai %an %d"

  # Search with regexp, showing the patch.
  g s -G '\bsed\b ' -p
EOF
  exit 1
}

cmd_search() {
  git log "$@"
}
alias_cmd s search
