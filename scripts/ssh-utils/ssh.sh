usage_ssh() {
  cat <<-EOF
Usage: ssh-utils ssh [host-label | user@host]

Enhanced SSH command. You can specify a host label in '~/.ssh_hosts', it will
build the ssh command and connect to the remote.

All arguments after '-' should be valid ssh arguments, and will be passed into
ssh intactly.

By default an HTTP proxy will be listening at 8124 port on the remote. You can
disable this behavior by specifying '--disable-http-proxy'.

Options:
  -d, --dry-run Only output SSH command
  --http-proxy <proxy> Default is 'localhost:8125'
  -N, --disable-http-proxy
  -C Remote forward port 2224 and 2225 to access OSX system clipboard
  -S Open port 10800 for socks requests

Examples:
  $> ssh-utils ssh host --http-proxy localhost:8123
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
      -S)
        opts+=(-D 10800)
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
    opts+=(-R 8124:$proxy)
  fi

  if [ -n "$osx_clipboard_shared" ]; then
    opts+=(-R 2224:localhost:2224 -R 2225:localhost:2225)
  fi

  if [ -z "$host_label" ]; then
    local _tmp_sel
    _tmp_sel=$(mktemp)
    # 不重定向 stdout，将输出路径作为参数传入，使 curses TUI 可正常渲染到终端
    "$DOTFILES_DIR/scripts/bin/select-ssh-host" "$_tmp_sel" || { rm -f "$_tmp_sel"; exit; }
    local -a _sel=()
    while IFS= read -r _line; do
      [[ -n "$_line" ]] && _sel+=("$_line")
    done < "$_tmp_sel"
    rm -f "$_tmp_sel"
    [ ${#_sel[@]} -eq 0 ] && exit
    host_label="${_sel[0]}"
    local _i=1
    while [ $_i -lt ${#_sel[@]} ]; do
      opts+=("${_sel[$_i]}")
      _i=$((_i + 1))
    done
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
