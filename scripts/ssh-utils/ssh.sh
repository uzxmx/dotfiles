usage_ssh() {
  cat <<-EOF
Usage: ssh-utils ssh [host-label]

Enhanced SSH command. You can specify a host label in '~/.ssh_hosts', it will
build the ssh command and connect to the remote.

All arguments after '-' should be valid ssh arguments, and will be passed into
ssh intactly.

Options:
  -d, --dry-run Only output SSH command
  -p Enable http proxy
EOF
  exit 1
}

cmd_ssh() {
  local host_label dry_run
  local -a opts
  while [ $# -gt 0 ]; do
    case "$1" in
      -d)
        dry_run=1
        ;;
      -p)
        opts+=(-R 8123:localhost:8123)
        ;;
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
  [ -z "$host_label" ] && exit


  local cmd=$("$DOTFILES_DIR/scripts/bin/build-ssh-cmd" "$host_label")
  if [ -z "$dry_run" ]; then
    $cmd "${opts[@]}" "$@"
  else
    echo $cmd "${opts[@]}" "$@"
  fi
}
