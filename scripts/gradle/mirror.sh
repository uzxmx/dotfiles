usage_mirror() {
  cat <<-EOF
Usage: gradle mirror [-e | -d]

Manage(show/enable/disable) maven mirrors for gradle. By default it shows
whether mirrors are enabled.

Options:
  -e enable mirrors
  -d disable mirrors
EOF
  exit 1
}

cmd_mirror() {
  local action="show"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -e)
        action="enable"
        ;;
      -d)
        action="disable"
        ;;
      *)
        usage_mirror
        ;;
    esac
    shift
  done

  local mirrors_file="$HOME/.gradle/init.d/mirrors.gradle"
  if [ "$action" = "enable" ]; then
    [ -e "$mirrors_file" ] || gen gradle_mirrors &>/dev/null
  elif [ "$action" = "disable" ]; then
    [ -e "$mirrors_file" ] && rm "$mirrors_file"
  fi
  cat "$mirrors_file"
}
