source "$(dirname "$BASH_SOURCE")/common.sh"

usage_show() {
  cat <<-EOF
Usage: vb show [vm_name]

Show a vm.
EOF
  exit 1
}

cmd_show() {
  local vm="$(select_vm "$1")"
  [ -z "$vm" ] && exit
  showvminfo "$vm"
}
