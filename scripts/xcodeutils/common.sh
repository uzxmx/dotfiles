DEFAULT_ARCHIVES_DIR="$HOME/Library/Developer/Xcode/Archives"

source "$PWN_DIR/shell/lib/provisioning_profile.sh"

# Params:
#   $1: do not exit if workspace cannot be found
check_workspace() {
  if [ -z "$workspace_path" ]; then
    workspace_path="$(find . -name "*.xcworkspace" -maxdepth 1)"
    [ ! "$1" = "1" ] && [ -z "$workspace_path" ] && echo "Cannot infer a workspace in current directory." && exit 1
  fi
  true
}

# Params:
#   $1: do not exit if project cannot be found
check_project() {
  if [ -z "$project_path" ]; then
    project_path="$(find . -name "*.xcodeproj" -maxdepth 1)"
    [ ! "$1" = "1" ] && [ -z "$project_path" ] && echo "Cannot infer a project in current directory." && exit 1
  fi
  true
}

get_schemes() {
  check_workspace 1
  check_project 1
  local -a dirs
  if [ -n "$workspace_path" ]; then
    dirs+=("$workspace_path")
  fi
  if [ -n "$project_path" ]; then
    dirs+=("$project_path")
  fi
  if [ ! "${#dirs[@]}" -eq 0 ]; then
    find "${dirs[@]}" -name "*.xcscheme" -exec basename {} .xcscheme \;
  else
    echo 'Cannot find any scheme. Please check your Xcode project or workspace.'
    exit 1
  fi
}

select_scheme() {
  get_schemes | fzf +m --select-1 --prompt="Select a scheme: "
}
