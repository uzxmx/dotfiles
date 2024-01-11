source "$(dirname "$BASH_SOURCE")/common.sh"

usage_stop() {
  cat <<-EOF
Usage: utm stop

Stop a vm.
EOF
  exit 1
}

cmd_stop() {
  local vm="$(select_vm)"
  [ -z "$vm" ] && exit
  "$utmctl" stop $vm
}
