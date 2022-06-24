usage_ssh() {
  cat <<-EOF
Usage: ssh-utils ssh [host-label]

Enhanced SSH command. You can specify a host label in '~/.ssh_hosts', it will
build the ssh command and connect to the remote.

All arguments after '-' should be valid ssh arguments, and will be passed into
ssh intactly.

By default an HTTP proxy will be listening at 8123 port on the remote. You can
disable this behavior by specifying '--disable-http-proxy'.

Options:
  -d, --dry-run Only output SSH command
  --disable-http-proxy
EOF
  exit 1
}

cmd_ssh() {
  local host_label dry_run disable_http_proxy
  local -a opts
  while [ $# -gt 0 ]; do
    case "$1" in
      -d)
        dry_run=1
        ;;
      --disable-http-proxy)
        disable_http_proxy=1
        ;;
      -)
        shift
        break
        ;;
      -*)
        usage_ssh
        ;;
      *)
        if [ -z "$host_label" ]; then
          host_label="$1"
        else
          abort "Only one host label should be specified."
        fi
        ;;
    esac
    shift
  done

  if [ -z "$disable_http_proxy" ]; then
    opts+=(-R 8123:localhost:8123)
  fi

  if [ -z "$host_label" ]; then
    host_label=$("$DOTFILES_DIR/scripts/bin/select-ssh-host")
  fi
  [ -z "$host_label" ] && exit

  local cmd=$("$DOTFILES_DIR/scripts/bin/build-ssh-cmd" "$host_label")
  if [ -z "$dry_run" ]; then
    $cmd "${opts[@]}" "$@"
  else
    echo $cmd "${opts[@]}" "$@"
  fi
}
