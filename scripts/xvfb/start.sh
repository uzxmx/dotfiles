usage_start() {
  cat <<-EOF
Usage: xvfb start [options]

Start Xvfb in the foreground on a virtual display.

Options:
  -d <display>  display number or name, e.g. 99 or :99 (default: :99)
  -s <WxHxD>    screen size in WIDTHxHEIGHTxDEPTH format (default: 1920x1080x24)

Examples:
  xvfb start
  xvfb start -d :99
  xvfb start -d 100 -s 1280x720x24
EOF
  exit 1
}

cmd_start() {
  local display=":99"
  local screen="1920x1080x24"

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d) shift; display="$1" ;;
      -s) shift; screen="$1" ;;
      -*) usage_start ;;
    esac
    shift
  done

  case "$display" in
    :*) ;;
    *)  display=":$display" ;;
  esac

  if ! type -p Xvfb &>/dev/null; then
    abort "Xvfb is not installed. Run: $DOTFILES_DIR/scripts/install/xvfb"
  fi

  echo "Starting Xvfb on display $display (screen: $screen)..."
  echo "Run below command in a shell before launching GUI application:"
  echo "  export DISPLAY=$display"
  exec Xvfb "$display" -screen 0 "$screen"
}
