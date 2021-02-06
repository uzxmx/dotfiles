source "$(dirname "$BASH_SOURCE")/common.sh"

usage_start() {
  cat <<-EOF
Usage: vb start [vm_name]

Start a vm.
EOF
  exit 1
}

cmd_start() {
  local vm="$(select_vm "$1")"
  [ -z "$vm" ] && exit
  startvm "$vm"
}
