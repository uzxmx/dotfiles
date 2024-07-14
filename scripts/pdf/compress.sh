usage_compress() {
  cat <<-EOF
Usage: pdf compress <input-pdf-file> <output-pdf-file>

Compress pdf to a readable quality by ghostscript.
EOF
  exit 1
}

cmd_compress() {
  local infile="$1"
  local outfile="$2"

  [ -z "$infile" ] && abort "An input pdf file is required."
  [ -z "$outfile" ] && abort "An output pdf file is required."

  # PDFSETTINGS: screen, ebook, printer, prepress, default
  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$outfile" "$infile"
}
alias_cmd c compress
