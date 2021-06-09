source "$(dirname "$BASH_SOURCE")/common.sh"

usage_status() {
  cat <<-EOF
Usage: vb status [vm_name]

Show status of a vm.
EOF
  exit 1
}

cmd_status() {
  local vm="$(select_vm "$1")"
  [ -z "$vm" ] && exit
  if is_running "$vm"; then
    echo $vm is running
  else
    echo $vm is NOT running
  fi
}
alias_cmd s status
