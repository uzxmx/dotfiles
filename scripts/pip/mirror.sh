usage_mirror() {
  cat <<-EOF
Usage: pip mirror [-e [aliyun|tuna]] [-d]

Manage pip mirror. By default it shows whether mirror is
enabled.

Options:
  -e [name] Enable mirror (default: aliyun)
              aliyun - Aliyun mirror
              tuna   - Tsinghua TUNA mirror
  -d        Disable mirror
EOF
  exit 1
}

cmd_mirror() {
  local action="show"
  local mirror="aliyun"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -e)
        action="enable"
        case "$2" in
          aliyun | ali | tuna | tsinghua)
            mirror="$2"
            shift
            ;;
          -*)
            ;;
          ?*)
            usage_mirror
            ;;
        esac
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

  if [ "$action" = "enable" ]; then
    local url
    case "$mirror" in
      aliyun | ali)
        url="https://mirrors.aliyun.com/pypi/simple/"
        ;;
      tuna | tsinghua)
        url="https://pypi.tuna.tsinghua.edu.cn/simple"
        ;;
    esac
    pip config set global.index-url "$url"
  elif [ "$action" = "disable" ]; then
    pip config unset global.index-url 2>/dev/null || true
  fi

  local url
  url=$(pip config list 2>/dev/null | grep '^global.index-url=' | cut -d= -f2- || true)
  if [ -n "$url" ]; then
    echo "mirror: $url"
  else
    echo "mirror: not set (using default PyPI)"
  fi
}

alias_cmd m mirror
