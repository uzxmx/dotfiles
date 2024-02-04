usage_mirror() {
  cat <<-EOF
Usage: npm mirror [-e | -d]

Manage(show/enable/disable) mirrors for npm. By default it shows
which mirrors are enabled.

Options:
  -e enable mirrors
  -d disable mirrors
EOF
  exit 1
}

mirrors=(
  registry=https://registry.npmmirror.com
  disturl=https://registry.npmmirror.com/dist

  # Optional
  sass_binary_site=https://registry.npmmirror.com/node-sass
  electron_mirror=https://registry.npmmirror.com/electron/
  puppeteer_download_host=https://registry.npmmirror.com
  chromedriver_cdnurl=https://registry.npmmirror.com/chromedriver
  operadriver_cdnurl=https://registry.npmmirror.com/operadriver
  phantomjs_cdnurl=https://registry.npmmirror.com/phantomjs
  selenium_cdnurl=https://registry.npmmirror.com/selenium
  node_inspector_cdnurl=https://registry.npmmirror.com/node-inspector
)

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

  local mirror key value
  if [ "$action" = "enable" ]; then
    for mirror in "${mirrors[@]}"; do
      key="$(echo "$mirror" | awk -F= '{ print $1 }')"
      value="$(echo "$mirror" | awk -F= '{ print $2 }')"
      npm set "$key" "$value"
    done
  elif [ "$action" = "disable" ]; then
    for mirror in "${mirrors[@]}"; do
      key="$(echo "$mirror" | awk -F= '{ print $1 }')"
      npm config delete "$key"
    done
  fi
  for mirror in "${mirrors[@]}"; do
    key="$(echo "$mirror" | awk -F= '{ print $1 }')"
    echo "$key: $(npm get "$key")"
  done
}
