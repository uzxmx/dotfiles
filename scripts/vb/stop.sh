source "$(dirname "$BASH_SOURCE")/common.sh"

usage_stop() {
  cat <<-EOF
Usage: vb stop [vm_name]

Power off one or more vms.

Options:
  -a, --all power off all vms
EOF
  exit 1
}

cmd_stop() {
  local all name
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -a | --all)
        all=1
        ;;
      *)
        name="$1"
    esac
    shift
  done

  local vm
  if [ "$all" = "1" ]; then
    while read vm; do
      if is_running "$vm"; then
        stopvm "$vm"
        echo $vm is stopped.
      fi
    done < <(listvms)
  else
    vm="$(select_vm "$name")"
    [ -z "$vm" ] && exit
    stopvm "$vm"
  fi
}
