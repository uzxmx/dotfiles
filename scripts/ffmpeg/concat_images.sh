usage_concat_images() {
  cat <<-EOF
Usage: ffmpeg concat_images <video-file> <images-dir>

Concatenate images to a video.

Options:
  -r <rate> set frame rate (Hz value, fraction or abbreviation), default is 30

Example:
  $> ffmpeg concat_images out.mp4 images
EOF
  exit 1
}

cmd_concat_images() {
  local remainder=()
  local rate=30
  while [ $# -gt 0 ]; do
    case "$1" in
      -r)
        shift
        rate="$1"
        ;;
      -*)
        usage_concat_images
        ;;
      *)
        remainder+=("$1")
        ;;
    esac
    shift
  done

  set - "${remainder[@]}"

  local video_file="$1"
  local images_dir="$2"
  if [ -z "$video_file" -o -z "$images_dir" ]; then
    usage_concat_images
  fi

  local list_file="list.txt"
  while read image_file; do
    echo "file $images_dir/$image_file" >>"$list_file"
  done < <(ls "$images_dir")

  ffmpeg -f concat -r "$rate" -i "$list_file" -c:v libx264 -r 5 -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2,format=yuv420p" "$video_file"

  rm "$list_file"
}
