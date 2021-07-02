usage_start() {
  cat <<-EOF
Usage: tmux start

Start a tmux session by selecting a tmuxinator project.
EOF
  exit 1
}

cmd_start() {
  local project
  project="$(tmuxinator list | sed 1d | fzf --prompt "Select a project> ")"
  if [ -n "$project" ]; then
    tmuxinator start "$project"
  fi
}
alias_cmd s start
