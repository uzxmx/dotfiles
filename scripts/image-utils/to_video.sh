# All xfade transitions supported by ffmpeg (excluding "custom", which needs an
# expr). Used for the -X option and for random selection.
IMAGE_UTILS_XFADE_TRANSITIONS=(
  fade wipeleft wiperight wipeup wipedown
  slideleft slideright slideup slidedown
  circlecrop rectcrop distance fadeblack fadewhite
  radial smoothleft smoothright smoothup smoothdown
  circleopen circleclose vertopen vertclose horzopen horzclose
  dissolve pixelize diagtl diagtr diagbl diagbr
  hlslice hrslice vuslice vdslice hblur fadegrays
  wipetl wipetr wipebl wipebr squeezeh squeezev
  zoomin fadefast fadeslow
)

usage_to_video() {
  cat <<-EOF
Usage: image-utils to_video [options] <image-dir> <video-file>

Combine all images in a directory into a video. Images are ordered by natural
sort of their filenames. Each frame is scaled to fit within the target canvas
(keeping aspect ratio) and letterboxed, so mixed image sizes are handled.

Options:
  -s <seconds>  seconds each image stays fully on screen  (default: 3)
  -r <fps>      output frame rate                          (default: 30)
  -m <WxH>      target canvas / max size                   (default: 1920x1080)
  -q <crf>      x264 quality, lower is better/bigger        (default: 23)
  -x <seconds>  crossfade transition duration between images, added on top of
                each image's -s solo time (0 = hard cut, the default).
                Total video length = count*-s + (count-1)*-x
  -X <effect>   transition effect when -x is set: a name (e.g. fade,
                slideleft, circleopen) or "random" per switch  (default: random)
  -a <file>     background music. Looped if shorter than the video, trimmed if
                longer, with a short fade-in and fade-out.
  -l            list all available transition effects and exit

Examples:
  $> image-utils to_video ./photos out.mp4
  $> image-utils to_video -x 1 ./photos out.mp4              # random transitions
  $> image-utils to_video -x 0.8 -X slideleft ./photos out.mp4
  $> image-utils to_video -x 1 -a bgm.mp3 ./photos out.mp4   # with music
EOF
  exit 1
}

cmd_to_video() {
  local seconds=3 fps=30 canvas=1920x1080 crf=23 xfade=0 effect=random audio=""

  local OPTIND opt
  while getopts "s:r:m:q:x:X:a:lh" opt; do
    case "$opt" in
      s) seconds="$OPTARG" ;;
      r) fps="$OPTARG" ;;
      m) canvas="$OPTARG" ;;
      q) crf="$OPTARG" ;;
      x) xfade="$OPTARG" ;;
      X) effect="$OPTARG" ;;
      a) audio="$OPTARG" ;;
      l)
        printf '%s\n' "${IMAGE_UTILS_XFADE_TRANSITIONS[@]}" | column
        exit 0
        ;;
      *) usage_to_video ;;
    esac
  done
  shift $((OPTIND - 1))

  [ "$#" -ne 2 ] && echo "Need an image directory and an output video file." && usage_to_video

  local dir="$1" out="$2"
  [ -d "$dir" ] || { echo "Not a directory: $dir" >&2; exit 1; }
  [ -n "$audio" ] && [ ! -f "$audio" ] && { echo "No such audio file: $audio" >&2; exit 1; }
  command -v ffmpeg >/dev/null || { echo "ffmpeg is required." >&2; exit 1; }

  local width="${canvas%x*}" height="${canvas#*x}"

  # Collect images (non-recursive) and natural-sort them.
  local -a files=()
  local img
  while IFS= read -r img; do
    files+=("$(cd "$(dirname "$img")" && pwd -P)/$(basename "$img")")
  done < <(find "$dir" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
    -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \
    -o -iname '*.tif' -o -iname '*.tiff' \) | sort -V)

  [ "${#files[@]}" -eq 0 ] && echo "No images found in: $dir" >&2 && exit 1

  # Downscale every source image to the target canvas once, up front. The scale
  # filter otherwise runs per output frame, so a full-res photo (e.g. 24MP) gets
  # resized hundreds of times — that, not the transitions, is the real cost. On
  # pre-shrunk images the per-frame scale becomes trivial (~6x faster in tests).
  local shrink_dir
  shrink_dir="$(mktemp -d -t image-utils-shrink.XXXXXX)"
  # Bake the path into the trap now: shrink_dir is a local and is out of scope by
  # the time the EXIT trap fires, so a single-quoted $shrink_dir would be empty.
  trap "rm -rf '$shrink_dir'" EXIT
  echo "Preprocessing ${#files[@]} image(s)..." >&2
  local -a shrunk=()
  local idx=0 sf
  for img in "${files[@]}"; do
    sf="$(printf '%s/%05d.jpg' "$shrink_dir" "$idx")"
    ffmpeg -y -loglevel error -i "$img" \
      -vf "scale=${width}:${height}:force_original_aspect_ratio=decrease" \
      -q:v 2 "$sf" </dev/null || { echo "Failed to preprocess: $img" >&2; exit 1; }
    shrunk+=("$sf")
    idx=$((idx + 1))
  done
  files=("${shrunk[@]}")

  # Render the silent slideshow. With music we render to a temp file first and
  # mux the audio in a second pass: feeding looped audio into the image/xfade
  # filtergraph deadlocks ffmpeg, whereas muxing onto a finished (finite) video
  # is reliable.
  local render_out="$out" vtmp=""
  if [ -n "$audio" ]; then
    vtmp="$(mktemp -u -t image-utils-to-video.XXXXXX).mp4"
    render_out="$vtmp"
  fi

  # No transition (or a single image): use the concat demuxer, which is cheap
  # and keeps per-image durations exact.
  if [ "$(awk "BEGIN{print ($xfade>0)}")" != 1 ] || [ "${#files[@]}" -lt 2 ]; then
    _to_video_hardcut "$render_out"
  else
    _to_video_xfade "$render_out"
  fi

  if [ -n "$audio" ]; then
    _mux_audio "$vtmp" "$out"
    rm -f "$vtmp"
  fi
}

# Mux looped, faded background music onto an already-rendered video. -shortest
# ends the output when the (finite) video ends; the video stream is copied.
_mux_audio() {
  local v="$1" o="$2" d
  d="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$v")"
  ffmpeg -y -i "$v" -stream_loop -1 -i "$audio" \
    -map 0:v -map 1:a -af "$(_afade_filter "$d")" \
    -c:v copy -c:a aac -b:a 192k -shortest -movflags +faststart "$o"
}

# Echo an audio filter that fades the music in at the start and out at the end
# of a <total>-second video (fades shrink for very short videos).
_afade_filter() {
  awk -v t="$1" 'BEGIN{
    fin  = (t < 2 ? t / 2 : 1);
    fout = (t < 4 ? t / 4 : 2);
    printf "afade=t=in:st=0:d=%.4f,afade=t=out:st=%.4f:d=%.4f", fin, t - fout, fout;
  }'
}

# Hard-cut slideshow via the concat demuxer. Writes a silent video to $1.
_to_video_hardcut() {
  local out="$1" list f total
  list="$(mktemp -t image-utils-to-video.XXXXXX)"
  trap 'rm -f "$list"' RETURN
  total="$(awk "BEGIN{printf \"%.4f\", ${#files[@]} * $seconds}")"

  for f in "${files[@]}"; do
    printf "file '%s'\n" "$f" >>"$list"
    printf "duration %s\n" "$seconds" >>"$list"
  done
  # concat demuxer ignores the last duration; repeat the final image to honor it.
  printf "file '%s'\n" "${files[$((${#files[@]} - 1))]}" >>"$list"

  # Note: use the output -r for frame rate. Putting fps= in the filter chain
  # breaks the concat demuxer's per-image durations. -t trims the repeated tail.
  ffmpeg -y -f concat -safe 0 -i "$list" \
    -vf "scale=${width}:${height}:force_original_aspect_ratio=decrease,pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2,setsar=1,format=yuv420p" \
    -r "$fps" -t "$total" \
    -c:v libx264 -preset medium -crf "$crf" -movflags +faststart \
    "$out"
}

# Crossfade slideshow: each image is its own looped input, chained with xfade.
# Writes a silent video to $1.
_to_video_xfade() {
  local out="$1" n="${#files[@]}"
  # Every image is fully static (not blending) for exactly <seconds>, with an
  # <xfade>-long crossfade between neighbours. So the timeline is:
  #   solo_0 | fade | solo_1 | fade | ... | solo_{n-1}
  # giving a total of n*seconds + (n-1)*xfade. Each input clip is made a bit
  # longer than it strictly needs (seconds + 2*xfade) so xfade never runs out of
  # frames; the extra tail is trimmed off the output with -t.
  local clip total
  clip="$(awk "BEGIN{print $seconds + 2 * $xfade}")"
  total="$(awk "BEGIN{printf \"%.4f\", $n * $seconds + ($n - 1) * $xfade}")"

  local -a args=()
  local pre="" i
  for ((i = 0; i < n; i++)); do
    args+=(-loop 1 -framerate "$fps" -t "$clip" -i "${files[$i]}")
    # Normalise every image to the same size/format/timebase so xfade accepts it.
    pre+="[$i:v]scale=${width}:${height}:force_original_aspect_ratio=decrease,"
    pre+="pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=${fps},"
    pre+="format=yuv420p,settb=AVTB[v$i];"
  done

  # Chain xfades. Transitions are spaced (seconds + xfade) apart, with the first
  # starting after the opening image's solo time: offset_k = k*seconds + (k-1)*xfade.
  local chain="" prev="[v0]" k off trans
  for ((k = 1; k < n; k++)); do
    off="$(awk "BEGIN{printf \"%.4f\", $k * $seconds + ($k - 1) * $xfade}")"
    if [ "$effect" = random ]; then
      trans="${IMAGE_UTILS_XFADE_TRANSITIONS[RANDOM % ${#IMAGE_UTILS_XFADE_TRANSITIONS[@]}]}"
    else
      trans="$effect"
    fi
    chain+="${prev}[v$k]xfade=transition=${trans}:duration=${xfade}:offset=${off}[x$k];"
    prev="[x$k]"
  done

  # Strip trailing ';' and map the final label.
  local filter="${pre}${chain}"
  filter="${filter%;}"

  # xfade outputs yuv444p even when fed yuv420p, which many players (QuickTime,
  # Safari, phones) can't decode. Force yuv420p on the encoded output.
  ffmpeg -y "${args[@]}" \
    -filter_complex "$filter" -map "$prev" -t "$total" \
    -r "$fps" -c:v libx264 -preset medium -crf "$crf" -pix_fmt yuv420p \
    -movflags +faststart \
    "$out"
}
alias_cmd tv to_video
