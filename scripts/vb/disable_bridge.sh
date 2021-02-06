source "$(dirname "$BASH_SOURCE")/common.sh"

usage_disable_bridge() {
  cat <<-EOF
Usage: vb disable_bridge [vm_name]

Disable bridged network for a vm, which operates on the 2nd nic.
EOF
  exit 1
}

cmd_disable_bridge() {
  local vm
  vm="$(select_vm "$1")"
  [ -z "$vm" ] && exit
  "$VBOXMANAGE" modifyvm "$vm" --nic2 none
}
