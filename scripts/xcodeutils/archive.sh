usage_archive() {
  cat <<-EOF
Usage: xcodeutils archive

Archive the product before it can be exported. The generated archive by default
is stored at the same location as you do in Xcode by Product -> Archive.

For simplicity, you don't need to specify anything. They can be inferred, or
when there're multiple candidates available, it will ask you to select one.

Note: To generate a correct archive, you may need to understand
target/scheme/configuration well.

Target: A target defines a list of classes, resources, custom scripts etc to include or
use when building.

Scheme: A scheme defines what happens when you press "Build", "Test", "Profile", etc.

Configuration: A targe contains one or more build configurations, e.g. Debug
and Release configuration. For example, you may want to set different compiler
options for different builds.

A scheme should be associated with one or more targets to build. And in a
scheme, actions like "Run", "Test", "Archive" should be configured with one and
only one configuration.

Options:
  -w <path-to-workspace> can be inferred
  -s <scheme>
  --clean clean before archiving
  -o <archive-path> path to save the archive, optional
  --simulator use iphonesimulator sdk

Example:
  $> xcodeutils archive
  $> xcodeutils archive --clean
EOF
  exit 1
}

cmd_archive() {
  local scheme archive_path sdk
  local -a actions
  process_common_options
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -s)
        shift
        scheme="$1"
        ;;
      --clean)
        actions+=(clean)
        ;;
      -o)
        shift
        archive_path="$1"
        ;;
      --iphonesimulator)
        sdk="iphonesimulator"
        ;;
      *)
        usage_archive
        ;;
    esac
    shift
  done

  check_workspace

  if [ -z "$scheme" ]; then
    scheme="$(select_scheme)"
    [ -z "$scheme" ] && echo 'Please specify a scheme by -s.'
  fi

  if [ -z "$archive_path" ]; then
    local created_at="$(LANG=en_US date +"%Y-%m-%d, %I:%M %p")"
    local project_name="$(basename "$(echo "$workspace_path" | sed -e 's/.xcworkspace$//')")"
    archive_path="$DEFAULT_ARCHIVES_DIR/$(echo "$created_at" | awk -F, '{print $1}')/$project_name $created_at.xcarchive"
  fi
  [ -e "$archive_path" ] && echo "Archive path $archive_path already exists, please remove it first." && exit 1

  actions+=(archive)
  xcodebuild -workspace "$workspace_path" \
    -scheme "$scheme" \
    -sdk "${sdk:-iphoneos}" -archivePath "$archive_path" \
    "${actions[@]}"
}
alias_cmd a archive
