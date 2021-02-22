usage_show() {
  cat <<-EOF
Usage: xcodeutils show

Show information of some type. By default it shows the project information.

Options:
  -t show the information of some type, include: p(roject)/c(onfigurations)/s(chemes)/t(argets)/w(orkspace)
  -json output with JSON format
  -w <path-to-workspace> can be inferred
  -p <path-to-project> can be inferred

Example:
  $> xcodeutils show -json
EOF
  exit 1
}

cmd_show() {
  local show_type="project"
  local -a opts

  source "$xcodeutils_dir/common_options.sh"

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -t)
        shift
        show_type="$1"
        ;;
      -json)
        opts+=(-json)
        ;;
      *)
        usage_show
        ;;
    esac
    shift
  done

  [ -z "$show_type" ] && echo 'You must specify a type by -t.' && exit 1

  case "$show_type" in
    p | project)
      xcodebuild -list "${opts[@]}"
      ;;
    c | configuration | configurations)
      xcodebuild -list -json | jq -r ".project.configurations[]"
      ;;
    s | scheme | schemes)
      get_schemes
      ;;
    t | target | targets)
      xcodebuild -list -json | jq -r ".project.targets[]"
      ;;
    w | workspace)
      check_workspace
      xcodebuild -list -workspace "$workspace_path" "${opts[@]}"
      ;;
  esac
}
alias_cmd s show
