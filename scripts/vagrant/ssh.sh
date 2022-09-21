usage_ssh() {
  cat <<-EOF
Usage: vagrant ssh [vm] [-- <ssh-options>]

SSH into a virtual machine. The default SSH option is to enable agent forwarding (-A).
EOF
  exit 1
}

cmd_ssh() {
  local vm
  local -a ssh_opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --)
        shift
        while [ "$#" -gt 0 ]; do
          ssh_opts+=("$1")
          shift
        done
        break
        ;;
      -*)
        usage_ssh
        ;;
      *)
        if [ -z "$vm" ]; then
          vm="$1"
        else
          abort "Only one vm should be specified."
        fi
    esac
    shift
  done

  if [ -z "$vm" ]; then
    vm="$(ls .vagrant/machines | fzf --prompt "Select VM: " -1)"
  fi

  if [ "${#ssh_opts[@]}" -eq 0 ]; then
    ssh_opts=(-A)
  fi

  vagrant ssh "$vm" -- "${ssh_opts[@]}"
}
alias_cmd s ssh
