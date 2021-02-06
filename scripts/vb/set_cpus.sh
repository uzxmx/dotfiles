source "$(dirname "$BASH_SOURCE")/common.sh"

usage_set_cpus() {
  cat <<-EOF
Usage: vb set_cpus <vm_name> <num-of-cpus>

Set the number of cpu.
EOF
  exit 1
}

cmd_set_cpus() {
  local vm size
  if [ "$#" -gt 1 ]; then
    vm="$1"
    num="$2"
  elif [ "$#" -eq 1 ]; then
    vm="$(select_vm)"
    num="$1"
  else
    echo "The number of CPU is required"
    exit 1
  fi
  [ -z "$vm" ] && exit
  "$VBOXMANAGE" modifyvm "$vm" --cpus "$num"
}
