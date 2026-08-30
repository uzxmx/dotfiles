usage_editor() {
  cat <<-EOF
Usage: image-utils editor

Open an image editor (GIMP). See https://www.gimp.org/.
EOF
  exit 1
}

cmd_editor() {
  if is_mac; then
    /Applications/GIMP.app/Contents/MacOS/gimp "$@"
  else
    echo "Unsupported system" >&2
    exit 1
  fi
}
alias_cmd e editor
