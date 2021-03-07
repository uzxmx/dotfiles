usage_extract() {
  cat <<-EOF
Usage: pdf extract <src-pdf-file> <dest-pdf-file>

Extract one or more contiguous pages from a pdf.

Options:
  -f <first-page>
  -l <last-page>
EOF
  exit 1
}

cmd_extract() {
  if ! type -p gs &>/dev/null; then
    echo "Cannot find ghostscript."
    exit 1
  fi

  local -a files
  local first_page last_page
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -f)
        shift
        first_page="$1"
        ;;
      -l)
        shift
        last_page="$1"
        ;;
      -*)
        usage_extract
        ;;
      *)
        files+=("$1")
        ;;
    esac
    shift
  done

  if [ -z "$first_page" -a -z "$last_page" ]; then
    echo "A first page or a last page should be specified."
    exit 1
  elif [ -z "$first_page" ]; then
    first_page="$last_page"
  elif [ -z "$last_page" ]; then
    last_page="$first_page"
  fi

  [ "${#files[@]}" -ne 2 ] && echo "You need to specify exactly one source pdf and one destination pdf file." && exit 1

  gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dFirstPage="$first_page" -dLastPage="$last_page" -sOutputFile="${files[1]}" "${files[0]}"
}
alias_cmd e extract
