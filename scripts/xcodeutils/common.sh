DEFAULT_ARCHIVES_DIR="$HOME/Library/Developer/Xcode/Archives"

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

get_profiles() {
  local filter_aps_environment filter_app_id
  local format="full"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --format)
        shift
        format="$1"
        ;;
      --aps-environment)
        shift
        filter_aps_environment="$1"
        ;;
      --app-id)
        shift
        filter_app_id="$1"
        ;;
      --valid)
        valid=1
        ;;
    esac
    shift
  done

  source "$dotfiles_dir/scripts/lib/date.sh"

  local decoded_profile aps_environment app_id
  local profile
  while read profile; do
    decoded_profile="$(security cms -D -i "$profile")"
    aps_environment="$(/usr/libexec/PlistBuddy -c "Print :Entitlements:aps-environment" /dev/stdin 2>/dev/null <<<"$decoded_profile" || true)"
    if [ -z "$filter_aps_environment" -o "$aps_environment" = "$filter_aps_environment" ]; then
      app_id="$(/usr/libexec/PlistBuddy -c "Print :Entitlements:application-identifier" /dev/stdin 2>/dev/null <<<"$decoded_profile")"
      if [ -z "$filter_app_id" -o "$app_id" = "$filter_app_id" ]; then
        if [ "$valid" = "1" ]; then
          local expire_date="$(/usr/libexec/PlistBuddy -c "Print :ExpirationDate" /dev/stdin 2>/dev/null <<<"$decoded_profile")"
          if [ -z "$expire_date" -o "$(convert_en_US_to_unix_time "$expire_date")" -le "$(date "+%s")" ]; then
            continue
          fi
        fi
        local str="$(/usr/libexec/PlistBuddy -c "Print :Name" /dev/stdin 2>/dev/null <<<"$decoded_profile")"
        if [ "$format" = "simple" ]; then
          profiles+=("$str")
        else
          local created_at="$(/usr/libexec/PlistBuddy -c "Print :CreationDate" /dev/stdin 2>/dev/null <<<"$decoded_profile")"
          profiles+=("$str!${aps_environment:-" "}!$app_id!created at $created_at")
        fi
      fi
    fi
  done < <(ls -t "$HOME/Library/MobileDevice/Provisioning Profiles/"*)
}
