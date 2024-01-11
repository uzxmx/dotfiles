source "$(dirname "$BASH_SOURCE")/common.sh"

usage_start() {
  cat <<-EOF
Usage: utm start

Start a vm.
EOF
  exit 1
}

cmd_start() {
  local vm="$(select_vm)"
  [ -z "$vm" ] && exit
  "$utmctl" start $vm
}
