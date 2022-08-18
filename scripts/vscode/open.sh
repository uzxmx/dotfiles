usage_open() {
  cat <<-EOF
Usage: vscode open [project-dir]

Open a project specified by a directory, or current working directory if no
argument is specified.
EOF
  exit 1
}

cmd_open() {
  local opts=(--new-window)
  if [ "$#" -eq 0 ]; then
    "$vscode" "${opts[@]}" .
  else
    "$vscode" "${opts[@]}" "$@"
  fi
}
alias_cmd o open
