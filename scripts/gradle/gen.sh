usage_gen() {
  cat <<-EOF
Usage: gradle gen <project-name>

Generate a gradle based project.

Options:
  -t <type> project type, default is java-application
  -p <package> package, default is com.example
EOF
  exit 1
}

cmd_gen() {
  local project_name
  local project_type="java-application"
  local package="com.example"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -t)
        shift
        project_type="$1"
        ;;
      -*)
        usage_gen
        ;;
      *)
        if [ -z "$project_name" ]; then
          project_name="$1"
        else
          abort "Only one project name should be specified."
        fi
        ;;
    esac
    shift
  done

  [ -z "$project_name" ] && usage_gen
  [ -d "$project_name" ] && abort "Directory $project_name already exists."

  mkdir "$project_name"
  cd "$project_name"

  gradle init --type "$project_type" --dsl groovy --test-framework junit --project-name "$project_name" --package "$package"

  success "Project $project_name generated successfully."
}
