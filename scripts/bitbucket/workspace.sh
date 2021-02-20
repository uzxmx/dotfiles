usage_workspace() {
  cat <<-EOF
Usage: bitbucket workspace

List workspaces.
EOF
  exit 1
}

cmd_workspace() {
  req workspaces | jq -r '.values[] | "Slug: \(.slug)\tName: \(.name)\tPrivate: \(.is_private)"' | column -t -s $'\t'
}
alias_cmd w workspace
