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

usage_add_pubkey() {
  cat <<-EOF
Usage: vb add_pubkey [vm_name]

Add public key to a vm for passwordless ssh login.
EOF
  exit 1
}

cmd_add_pubkey() {
  local vm
  if vm="$(select_vm_and_check_running "$1")"; then
    [ -z "$vm" ] && exit
    "$dotfiles_dir/scripts/misc/add_pubkey_to_remote" "$(get_ssh_target "$vm")"
  fi
}
