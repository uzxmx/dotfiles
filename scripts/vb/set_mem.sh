source "$(dirname "$BASH_SOURCE")/common.sh"

usage_set_mem() {
  cat <<-EOF
Usage: vb set_mem <vm_name> <size-in-gigabyte>

Change memory of a vm (unit is gigabyte).
EOF
  exit 1
}

cmd_set_mem() {
  local vm size
  if [ "$#" -gt 1 ]; then
    vm="$1"
    size="$2"
  elif [ "$#" -eq 1 ]; then
    vm="$(select_vm)"
    size="$1"
  else
    echo "Memory size is required"
    exit 1
  fi
  [ -z "$vm" ] && exit
  "$VBOXMANAGE" modifyvm "$vm" --memory $(($size * 1024))
}
