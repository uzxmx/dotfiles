usage_gallery() {
  cat <<-EOF
Usage: image-utils gallery [options] [image-dir]

Generate an HTML page showing all images in a directory as a thumbnail grid,
then open it in the browser. Useful for browsing many images (e.g. SVG icons)
at once. Click a thumbnail to open the full image; type in the filter box to
narrow down by filename.

Options:
  -s <px>    thumbnail size                                  (default: 160)
  -e <exts>  comma-separated extensions to include
             (default: svg,png,jpg,jpeg,gif,webp,bmp,ico,avif)
  -r         search sub-directories recursively
  -o <file>  write the page to <file> instead of a temp file
  -n         don't open the page, just print its path

Examples:
  $> image-utils gallery                   # current directory
  $> image-utils gallery -e svg ./icons
  $> image-utils gallery -r -s 96 -o icons.html ./assets
EOF
  exit 1
}

cmd_gallery() {
  local size=160 exts="svg,png,jpg,jpeg,gif,webp,bmp,ico,avif" recursive=0 out="" no_open=0

  local OPTIND opt
  while getopts "s:e:o:rnh" opt; do
    case "$opt" in
      s) size="$OPTARG" ;;
      e) exts="$OPTARG" ;;
      r) recursive=1 ;;
      o) out="$OPTARG" ;;
      n) no_open=1 ;;
      *) usage_gallery ;;
    esac
  done
  shift $((OPTIND - 1))

  [ "$#" -gt 1 ] && usage_gallery
  local dir="${1:-.}"
  [ -d "$dir" ] || { echo "Not a directory: $dir" >&2; exit 1; }
  dir="$(cd "$dir" && pwd -P)"

  # Build: find <dir> [-maxdepth 1] -type f ( -iname '*.a' -o -iname '*.b' ... )
  local -a find_args=("$dir")
  [ "$recursive" = 1 ] || find_args+=(-maxdepth 1)
  find_args+=(-type f "(")
  local ext first=1
  for ext in ${exts//,/ }; do
    [ "$first" = 1 ] || find_args+=(-o)
    find_args+=(-iname "*.${ext#.}")
    first=0
  done
  find_args+=(")")

  local -a files=()
  local f
  while IFS= read -r f; do
    files+=("$f")
  done < <(find "${find_args[@]}" | sort -V)

  [ "${#files[@]}" -eq 0 ] && echo "No images found in: $dir" >&2 && exit 1

  if [ -z "$out" ]; then
    out="$(mktemp -t image-utils-gallery.XXXXXX).html"
  fi

  {
    _gallery_head "$dir" "${#files[@]}"
    local rel
    for f in "${files[@]}"; do
      rel="${f#"$dir"/}"
      printf '<figure data-name="%s"><a href="%s" target="_blank"><img src="%s" loading="lazy"></a><figcaption>%s</figcaption></figure>\n' \
        "$(_gallery_html_escape "$rel" | tr '[:upper:]' '[:lower:]')" \
        "$(_gallery_file_url "$f")" "$(_gallery_file_url "$f")" \
        "$(_gallery_html_escape "$rel")"
    done
    echo '</main></body></html>'
  } >"$out"

  echo "$out"
  [ "$no_open" = 1 ] && return
  if is_mac; then
    open "$out"
  elif command -v xdg-open >/dev/null; then
    xdg-open "$out"
  fi
}

_gallery_html_escape() {
  printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'
}

# Absolute file:// URL, with the characters that break a URL path encoded.
_gallery_file_url() {
  printf 'file://%s' "$(printf '%s' "$1" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/#/%23/g' \
    -e 's/?/%3F/g' -e 's/"/%22/g' -e 's/&/%26/g' -e 's/</%3C/g' -e 's/>/%3E/g')"
}

_gallery_head() {
  local title
  title="$(_gallery_html_escape "$1")"
  cat <<-EOF
<!doctype html>
<html><head><meta charset="utf-8"><title>$title ($2)</title>
<style>
  :root { --size: ${size}px; color-scheme: light dark; }
  body { margin: 0; font: 12px -apple-system, sans-serif; background: Canvas; color: CanvasText; }
  header { position: sticky; top: 0; display: flex; gap: 12px; align-items: center;
    padding: 8px 16px; background: Canvas; border-bottom: 1px solid #8884; z-index: 1; }
  header input { flex: 0 1 240px; padding: 4px 8px; font: inherit; }
  header label { cursor: pointer; }
  main { display: grid; grid-template-columns: repeat(auto-fill, minmax(var(--size), 1fr));
    gap: 12px; padding: 16px; }
  figure { margin: 0; text-align: center; }
  figure a { display: flex; align-items: center; justify-content: center;
    height: var(--size); border: 1px solid #8884; border-radius: 4px; background: #fff; }
  body.checker figure a { background: repeating-conic-gradient(#ccc 0 25%, #fff 0 50%) 0 0 / 16px 16px; }
  body.dark figure a { background: #222; }
  figure img { max-width: 90%; max-height: 90%; }
  figcaption { margin-top: 4px; word-break: break-all; opacity: .8; }
</style></head>
<body>
<header>
  <strong>$title</strong><span id="count">$2</span>
  <input id="filter" placeholder="Filter by name" autofocus>
  <label><input type="radio" name="bg" value="" checked> white</label>
  <label><input type="radio" name="bg" value="checker"> checker</label>
  <label><input type="radio" name="bg" value="dark"> dark</label>
</header>
<script>
  addEventListener('DOMContentLoaded', () => {
    const figs = [...document.querySelectorAll('figure')];
    const count = document.getElementById('count');
    document.getElementById('filter').addEventListener('input', e => {
      const q = e.target.value.toLowerCase();
      let n = 0;
      for (const f of figs) { const show = f.dataset.name.includes(q); f.hidden = !show; n += show; }
      count.textContent = n + ' / ' + figs.length;
    });
    for (const r of document.querySelectorAll('input[name=bg]'))
      r.addEventListener('change', () => { document.body.className = r.value; });
  });
</script>
<main>
EOF
}
alias_cmd g gallery
