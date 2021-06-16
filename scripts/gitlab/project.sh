usage_project() {
  cat <<-EOF
Usage: gitlab project

Manage projects.

Subcommands:
  l, list - list projects
EOF
  exit 1
}

cmd_project() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_project

  case "$cmd" in
    l | list | g | get | v | verify | a | add | d | delete | c | configure)
      case "$cmd" in
        l)
          cmd="list"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_project_$cmd" &>/dev/null && "usage_project_$cmd"
          ;;
      esac
      "cmd_project_$cmd" "$@"
      ;;
    *)
      usage_project
      ;;
  esac
}
alias_cmd p project

usage_project_list() {
  cat <<-EOF
Usage: gitlab project list

List projects.
EOF
  exit 1
}

process_project_list_output() {
  jq -r '.[] | "ID: \(.id)\tPath: \(.path_with_namespace)\tCreated at: \(.created_at)\tLast activity at: \(.last_activity_at)"' | column -t -s $'\t'
}

cmd_project_list() {
  req '/api/v4/projects?per_page=100' | process_project_list_output
}
