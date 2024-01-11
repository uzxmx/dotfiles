source "$(dirname "$BASH_SOURCE")/common.sh"

usage_tty() {
  cat <<-EOF
Usage: utm tty

Connect to the vm by screen.

When connected, you may need to press ENTER key to get prompt. Press 'Ctrl-A, :quit' to exit.
EOF
  exit 1
}

get_serial_port() {
  osascript <<EOF
tell application "UTM"
    set vm to virtual machine named "$1"
    --- wait until vm is started
    repeat
        if status of vm is started then exit repeat
    end repeat
    --- get serial port address
    get address of first serial port of vm
end tell
EOF
}

cmd_tty() {
  local vm="$(select_vm_and_get_name)"
  [ -z "$vm" ] && exit

  tty="$(get_serial_port "$vm")"
  screen "$tty"
}
