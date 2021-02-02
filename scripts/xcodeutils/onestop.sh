usage_onestop() {
  cat <<-EOF
Usage: xcodeutils onestop -m <method> -p <profile>

Archive, export and upload in one command. If you don't know the profile, use
'xcodeutils list_profiles' to find one.

Options:
  -m <method> the export method, e.g. app-store, development
  -p <profile> the profle
EOF
  exit 1
}

cmd_onestop() {
  local method profile
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -m)
        shift
        method="$1"
        ;;
      -p)
        shift
        profile="$1"
        ;;
      *)
        usage_onestop
        ;;
    esac
    shift
  done

  [ -z "$method" ] && echo "An export method is required" && exit 1
  [ -z "$profile" ] && echo "A profile is required" && exit 1

  local build_dir="build.$(date "+%Y%m%d%H%M%S")"
  echo "Build logs will be saved to $build_dir."

  local archive_path="$(xcodeutils archive --log-dir "$build_dir" | sed "s/^Archive is saved to //")"
  [ -z "$archive_path" ] && exit

  xcodeutils export -s "$archive_path" -m "$method" -p "$profile" "$build_dir/export" &>"$build_dir/export.log"

  local ipa="$(find "$build_dir/export" -name "*.ipa" -maxdepth 1)"
  [ -z "$ipa" ] && echo "Cannot find an IPA file to upload."

  case "$method" in
    app-store)
      xcodeutils upload "$ipa"
      ;;
    development)
      xcodeutils pgyer "$ipa"
      ;;
  esac
}
