check_vboxmanage

listvms() {
  "$VBOXMANAGE" list vms | awk '{print $1}' | sed 's/^"\(.*\)"$/\1/'
}

select_vm() {
  if [ -n "$1" ]; then
    echo "$1"
  else
    listvms | fzf
  fi
}

showvminfo() {
  "$VBOXMANAGE" showvminfo --machinereadable "$1"
}

is_running() {
  [ "$(showvminfo "$1" | grep "^VMState=" | sed "s/^VMState=\"\(.*\)\"/\\1/" | tr -d '\r')" = "running" ]
}

startvm() {
  "$VBOXMANAGE" startvm "$1"
}

stopvm() {
  "$VBOXMANAGE" controlvm "$1" poweroff
}

select_vm_and_check_running() {
  local vm="$(select_vm "$1")"
  [ -z "$vm" ] && exit
  if ! is_running "$vm"; then
    startvm "$vm"
    # TODO It seems we don't have a good way to detect when vm is booted up.
    echo 'VM is starting. Please execute your command again when it is started.' >&2
    exit 1
  fi
  echo "$vm"
}
