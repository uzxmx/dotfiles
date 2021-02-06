source "$(dirname "$BASH_SOURCE")/common.sh"

usage_enable_bridge() {
  cat <<-EOF
Usage: vb enable_bridge [vm_name]

Enable bridged network for a vm, which operates on the 2nd nic.
EOF
  exit 1
}

select_bridge_device() {
  local name status
  while read name; do
    read status
    if [ "$(echo $status | tr -d '\r')" = "Up" ]; then
      echo "$name"
      return
    fi
  done < <("$VBOXMANAGE" list bridgedifs | grep -E "^Name:|^Status:" |  sed -E 's/^(Name|Status):\s*//')
}

cmd_enable_bridge() {
  local vm device
  vm="$(select_vm "$1")"
  device="$(select_bridge_device)"
  [ -z "$vm" -o -z "$device" ] && exit
  "$VBOXMANAGE" modifyvm "$vm" --nic2 bridged --bridgeadapter1 "$device"
}
