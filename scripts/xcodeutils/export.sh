usage_export() {
  cat <<-EOF
Usage: xcodeutils export <export-path>

Export to an IPA file. The export path is a directory where an IPA file will be
exported.

When you don't specify an archive path, it will ask you to select one from the
standard archives directory managed by Xcode.

Options:
  -s <archive-path>
  -m <method> the export method, e.g. app-store, development
  -p <profile> the profle

Example:
  $> xcodeutils export foo
EOF
  exit 1
}

show_archives() {
  local query key archive
  local -a result
  local limit="$1"

  source "$dotfiles_dir/scripts/lib/utils/common.sh"
  source "$dotfiles_dir/scripts/lib/fzf.sh"

  get_archives() {
    local archive version_str bundle_version pipe_cmd
    local -a archives
    if [ -n "$limit" ]; then
      pipe_cmd="head -$limit"
    else
      pipe_cmd="cat"
    fi
    while read archive; do
      version_str="$(/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleShortVersionString" "$archive/Info.plist" 2>/dev/null)"
      bundle_version="$(/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleVersion" "$archive/Info.plist" 2>/dev/null)"
      archives+=("$(basename "$archive" .xcarchive) $version_str ($bundle_version)\t$archive")
    done < <(ls -t -d "$DEFAULT_ARCHIVES_DIR"/*/*.xcarchive | $pipe_cmd)
    (IFS=$'\n'; echo -e "${archives[*]}")
  }

  while true; do
    unset result
    call_fzf result --query="$query" --print-query +m --exit-0 \
      --prompt '(CTRL-T:show-all-archives) Select an archive> ' \
      --tiebreak=index -d "\t" --with-nth=1 \
      --expect="ctrl-t" \
      < <(get_archives)

    [ -z "${result[*]}" ] && break

    query="${result[0]}"
    key="${result[1]}"
    archive=("${result[@]:2}")
    case "$key" in
      ctrl-t)
        limit=
        ;;
      "")
        echo "$archive"
        break
        ;;
    esac
  done

}

select_archive() {
  local selection="$(show_archives 10)"
  echo "$selection" | awk -F "\t" '{print $2}'
}

cmd_export() {
  local archive_path export_path method profile
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -s)
        shift
        archive_path="$1"
        ;;
      -m)
        shift
        method="$1"
        ;;
      -p)
        shift
        profile="$1"
        ;;
      -*)
        usage_export
        ;;
      *)
        export_path="$1"
        ;;
    esac
    shift
  done

  [ -z "$export_path" ] && echo "Export path is required." && exit 1
  [ -e "$export_path" ] && echo "Export path already exists." && exit 1

  if [ -z "$archive_path" ]; then
    archive_path="$(select_archive)"
    [ -z "$archive_path" ] && echo "Archive path is required." && exit 1
  fi
  [ ! -e "$archive_path" ] && echo "Archive dosen't exist." && exit 1

  if [ -z "$method" ]; then
    method="$(echo -e "app-store\ndevelopment" | fzf --prompt="Select a method (e.g. you should select app-store when you want to upload to AppStore)> ")"
  fi

  local aps_environment
  case "$method" in
    development)
      aps_environment="development"
      ;;
    app-store)
      aps_environment="production"
      ;;
    "")
      echo "A method is required."
      exit 1
      ;;
  esac

  local bundle_id="$(/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleIdentifier" "$archive_path/Info.plist" 2>/dev/null)"

  if [ -z "$profile" ]; then
    local team="$(/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:Team" "$archive_path/Info.plist" 2>/dev/null)"
    local -a profiles
    get_profiles --format simple --aps-environment "$aps_environment" --app-id "$team.$bundle_id"
    local profile="$(IFS=$'\n'; echo "${profiles[*]}" | awk '!mem[$0]++' | fzf --prompt="Select a profile> ")"
    [ -z "$profile" ] && echo "A provision profile is required." && exit 1
  fi

  export EXPORT_METHOD="$method"
  export EXPORT_PROVISION_PROFILE_KEY="$bundle_id"
  export EXPORT_PROVISION_PROFILE_VALUE="$profile"
  local export_options_path="$(mktemp)"
  gen export_options - -f "$export_options_path" --overwrite >/dev/null

  xcodebuild -exportArchive -archivePath "$archive_path" \
    -exportOptionsPlist "$export_options_path" \
    -exportPath "$export_path"

  rm "$export_options_path"
}
alias_cmd e export
