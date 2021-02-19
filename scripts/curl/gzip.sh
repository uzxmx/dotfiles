usage_gzip() {
  cat <<-EOF
Usage: curl gzip <url>

Check if a remote resource is gzipped.

For more info, please visit https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Accept-Encoding
EOF
  exit 1
}

cmd_gzip() {
  local url
  while [ $# -gt 0 ]; do
    case "$1" in
      -*)
        usage_gzip
        ;;
      *)
        url="$1"
        ;;
    esac
    shift
  done

  if [ -z "$url" ]; then
    usage_gzip
  fi

  source "$dotfiles_dir/scripts/lib/utils/common.sh"
  source "$dotfiles_dir/scripts/lib/io.sh"

  local output
  io_run_capture_and_display output curl -H "Accept-Encoding: gzip" "$url" -D - -o /dev/null -sS "${opts[@]}"

  echo -e "----\n"

  if echo "$output" | grep -i "Content-Encoding: *gzip" &>/dev/null; then
    echo Resource is gzipped
  else
    echo Resource is not gzipped
  fi
}
