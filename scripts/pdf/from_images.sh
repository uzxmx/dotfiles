usage_from_images() {
  cat <<-EOF
Usage: pdf from_images <image-file>... <pdf-file>

Convert images to a pdf. By default, the size of the generated pdf is A4.
EOF
  exit 1
}

cmd_from_images() {
  [ "$#" -lt 2 ] && echo "You need to specify at least an image file, and a pdf file to output." && exit 1
  convert -page a4 "$@"
}
alias_cmd fi from_images
