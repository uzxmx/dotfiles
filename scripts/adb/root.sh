usage_root() {
  cat <<-EOF
Usage: adb root

Wrapped root command.

$(show_note)
EOF
  exit 1
}

show_note() {
  cat <<EOF
NOTE:
When executing 'android root' for an emulator, it may fail if its system
image is google API based. To make it work, you'd better to choose a system
image which doesn't contain google API.
EOF
}

cmd_root() {
  show_note >&2
  echo
  adb root "$@"
}
