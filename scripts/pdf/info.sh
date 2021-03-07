usage_info() {
  cat <<-EOF
Usage: pdf info <pdf-file>

Show pdf info.

Note: we can also use exiftool, which is implemented in perl.

Options:
  -box print the page bounding boxes
  -f <page-num> first page to convert
  -l <page-num> last page to convert
EOF
  exit 1
}

cmd_info() {
  pdfinfo "$@"
}
alias_cmd i info
