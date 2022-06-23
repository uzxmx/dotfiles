usage_ssh() {
  cat <<-EOF
Usage: ssh-utils ssh [host-label]

Enhanced SSH command. You can specify a host label in '~/.ssh_hosts', it will
build the ssh command and connect to the remote.

All arguments after '-' should be valid ssh arguments, and will be passed into
ssh intactly.
EOF
  exit 1
}

cmd_ssh() {
  local host_label
  while [ $# -gt 0 ]; do
    case "$1" in
      -)
        shift
        break
        ;;
      -*)
        usage_ssh
        ;;
      *)
        if [ -z "$host_label" ]; then
          host_label="$1"
        else
          abort "Only one host label should be specified."
        fi
        ;;
    esac
    shift
  done

  if [ -z "$host_label" ]; then
    host_label=$("$DOTFILES_DIR/scripts/bin/select-ssh-host")
  fi

  local cmd=$("$DOTFILES_DIR/scripts/bin/build-ssh-cmd" "$host_label")
  $cmd "$@"
}
