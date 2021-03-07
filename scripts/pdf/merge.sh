usage_merge() {
  cat <<-EOF
Usage: pdf merge <pdf-file>... <merged-pdf-file>

Merge multiple pdfs into one. Below methods are tried, if one doesn't work,
then the next one is tried.

* gs is used if ghostscript is available on the system.

* pdfunite is used if poppler is available on the system.

* pdftk is used if it is available on the system.

* convert is used if imagemagick is available on the system. (the quality is worst)
EOF
  exit 1
}

cmd_merge() {
  local -a src
  local dest
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -*)
        usage_merge
        ;;
      *)
        if [ -n "$dest" ]; then
          src+=("$dest")
        fi
        dest="$1"
        ;;
    esac
    shift
  done

  [ "${#src[@]}" -lt 2 ] && echo "You need to at least specify two pdf files to merge, and one pdf to output." && exit 1

  if type -p gs &>/dev/null; then
    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$dest" "${src[@]}"
  elif type -p pdfunite &>/dev/null; then
    pdfunite "${src[@]}" "$dest"
  elif type -p pdftk &>/dev/null; then
    pdftk "${src[@]}" cat output "$dest"
  elif type -p convert &>/dev/null; then
    convert -density 150 "${src[@]}" "$dest"
  else
    echo "No more method to try."
    exit 1
  fi
}
alias_cmd m merge
