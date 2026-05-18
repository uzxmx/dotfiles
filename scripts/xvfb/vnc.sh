usage_vnc() {
  cat <<-EOF
Usage: xvfb vnc [options]

Attach x11vnc to a running virtual display for remote viewing/debugging.

Options:
  -d <display>  display to attach to (default: :99)
  -p <port>     VNC port to listen on (default: 5900)
  -P            prompt for a VNC password

Examples:
  xvfb vnc
  xvfb vnc -d :100 -p 5901
EOF
  exit 1
}

cmd_vnc() {
  local display=":99"
  local port="5900"
  local use_password=0

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d) shift; display="$1" ;;
      -p) shift; port="$1" ;;
      -P) use_password=1 ;;
      -*) usage_vnc ;;
    esac
    shift
  done

  case "$display" in
    :*) ;;
    *)  display=":$display" ;;
  esac

  if ! type -p x11vnc &>/dev/null; then
    abort "x11vnc is not installed. Run: $DOTFILES_DIR/scripts/install/xvfb"
  fi

  local -a vnc_opts=(-display "$display" -rfbport "$port" -forever -shared)
  [ "$use_password" -eq 0 ] && vnc_opts+=(-nopw)

  echo "Starting x11vnc on display $display, VNC port $port..."
  echo "Connect with a VNC client to: localhost:$port"
  exec x11vnc "${vnc_opts[@]}"
}
