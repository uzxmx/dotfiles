source "$(dirname "$BASH_SOURCE")/common.sh"

usage_ps() {
  cat <<-EOF
Usage: adb ps

Show processes running on an Android device.
EOF
  exit 1
}

cmd_ps() {
  local device
  device="$(select_device)"
  select_process "$device" >/dev/null
}
