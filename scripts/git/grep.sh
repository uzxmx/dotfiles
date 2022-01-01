usage_grep() {
  cat <<-EOF
Usage: g grep

Search file contents in the working directory, or a tree (ref)

Examples:
  # Search a word in current git tree (ref), showing all matched lines.
  g g -w sed

  # Search a string in current git tree (ref).
  g g sed

  # Search a word in a specific git tree (ref).
  g g -w sed HEAD^
  g g -w sed feature/foo
EOF
  exit 1
}

cmd_grep() {
  git grep "$@"
}
alias_cmd g grep
