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
  registry=https://registry.npm.taobao.org
  disturl=https://npm.taobao.org/dist

  # Optional
  sass_binary_site=https://npm.taobao.org/mirrors/node-sass
  electron_mirror=https://npm.taobao.org/mirrors/electron/
  puppeteer_download_host=https://npm.taobao.org/mirrors
  chromedriver_cdnurl=https://npm.taobao.org/mirrors/chromedriver
  operadriver_cdnurl=https://npm.taobao.org/mirrors/operadriver
  phantomjs_cdnurl=https://npm.taobao.org/mirrors/phantomjs
  selenium_cdnurl=https://npm.taobao.org/mirrors/selenium
  node_inspector_cdnurl=https://npm.taobao.org/mirrors/node-inspector
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
