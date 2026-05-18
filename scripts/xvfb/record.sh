usage_record() {
  cat <<-EOF
Usage: xvfb record [options]

Record the virtual display to a video file using ffmpeg.

Options:
  -d <display>  display number or name, e.g. 99 or :99 (default: :99)
  -s <WxH>      capture size (default: 1280x720)
  -r <fps>      frame rate (default: 30)
  -q <crf>      video quality, lower is better (default: 15)
  -o <file>     output file (default: /tmp/out.mkv)

Examples:
  xvfb record
  xvfb record -d :99 -o /tmp/recording.mkv
  xvfb record -s 1920x1080 -r 24 -q 20
EOF
  exit 1
}

cmd_record() {
  local display=":99"
  local size="1280x720"
  local fps="30"
  local crf="15"
  local output="/tmp/out.mkv"

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d) shift; display="$1" ;;
      -s) shift; size="$1" ;;
      -r) shift; fps="$1" ;;
      -q) shift; crf="$1" ;;
      -o) shift; output="$1" ;;
      -*) usage_record ;;
    esac
    shift
  done

  case "$display" in
    :*) ;;
    *)  display=":$display" ;;
  esac

  if ! type -p ffmpeg &>/dev/null; then
    abort "ffmpeg is not installed."
  fi

  local display_num="${display#:}"
  echo "Recording display $display ($size @ ${fps}fps) -> $output"
  echo "Press Ctrl-C to stop."
  exec ffmpeg -y \
    -r "$fps" \
    -f x11grab \
    -s "$size" \
    -i "${display_num}+nomouse" \
    -c:v libx264 \
    -crf "$crf" \
    -preset:v ultrafast \
    -c:a pcm_s16le \
    -af aresample=async=1:first_pts=0 \
    "$output"
}
