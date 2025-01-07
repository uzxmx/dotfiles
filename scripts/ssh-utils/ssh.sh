usage_ssh() {
  cat <<-EOF
Usage: ssh-utils ssh [host-label | user@host]

Enhanced SSH command. You can specify a host label in '~/.ssh_hosts', it will
build the ssh command and connect to the remote.

All arguments after '-' should be valid ssh arguments, and will be passed into
ssh intactly.

By default an HTTP proxy will be listening at 8125 port on the remote. You can
disable this behavior by specifying '--disable-http-proxy'.

Options:
  -d, --dry-run Only output SSH command
  --http-proxy <proxy> Default is 'localhost:8125'
  -N, --disable-http-proxy
  -C Remote forward port 2224 and 2225 to access OSX system clipboard
EOF
  exit 1
}

proxy="localhost:8125"

cmd_ssh() {
  local host_label dry_run disable_http_proxy
  local osx_clipboard_shared
  local -a opts
  while [ $# -gt 0 ]; do
    case "$1" in
      -d)
        dry_run=1
        ;;
      -N | --disable-http-proxy)
        disable_http_proxy=1
        ;;
      --http-proxy)
        shift
        proxy="$1"
        ;;
      -C)
        osx_clipboard_shared="1"
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
    opts+=(-R 8125:$proxy)
  fi

  if [ -n "$osx_clipboard_shared" ]; then
    opts+=(-R 2224:localhost:2224 -R 2225:localhost:2225)
  fi

  if [ -z "$host_label" ]; then
    host_label=$("$DOTFILES_DIR/scripts/bin/select-ssh-host")
  fi
  [ -z "$host_label" ] && exit

  local cmd=$("$DOTFILES_DIR/scripts/bin/build-ssh-cmd" "$host_label")
  if [ -z "$cmd" ]; then
    cmd="ssh $host_label"
  fi

  for e in $cmd; do
    if [[ "$e" =~ ^.+@[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      export LC_REMOTE_USER="${e%@*}"
      export LC_REMOTE_IP="${e#*@}"
      opts+=(-o SendEnv="LC_REMOTE_USER LC_REMOTE_IP")
      break
    fi
  done

  echo $cmd "${opts[@]}" "$@"

  if [ -z "$dry_run" ]; then
    $cmd "${opts[@]}" "$@"
  fi
}
