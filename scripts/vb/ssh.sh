source "$(dirname "$BASH_SOURCE")/common.sh"

usage_ssh() {
  cat <<-EOF
Usage: vb ssh [vm_name]

SSH into a vm.
EOF
  exit 1
}

get_ssh_target() {
  local user="$(rlwrap -S "User(vagrant): " -o cat)"
  local ip="$("$VBOXMANAGE" guestproperty get "$1" "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{print $2}')"
  echo "${user:-vagrant}@$ip"
}

cmd_ssh() {
  local vm
  if vm="$(select_vm_and_check_running "$1")"; then
    [ -z "$vm" ] && exit
    ssh -A "$(get_ssh_target "$vm")"
  fi
}
