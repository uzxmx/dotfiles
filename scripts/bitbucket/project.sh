usage_project() {
  cat <<-EOF
Usage: bitbucket project

List projects.

Options:
  -w <workspace slug> workspace to use
EOF
  exit 1
}

cmd_project() {
  check_workspace
  req "workspaces/$workspace/projects" | jq -r '.values[] | "Name: \(.name)\tKey: \(.key)\tCreated at: \(.created_on)"' | column -t -s $'\t'
}
alias_cmd p project
