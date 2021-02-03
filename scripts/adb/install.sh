source "$(dirname "$BASH_SOURCE")/common.sh"

usage_install() {
  cat <<-EOF
Usage: adb install <apk>

Enhanced adb install.
EOF
  exit 1
}

cmd_install() {
  local device
  device="$(select_device)"
  adb -s "$device" install "$@"
}
alias_cmd i install
