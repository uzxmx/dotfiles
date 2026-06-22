SERVER_CONFIG="/etc/sing-box/config.json"

require_linux_server() {
  if is_mac; then
    abort 'server-* commands run on the Linux server (systemd), not on macOS.'
  fi
}

cmd_server_setup() {
  require_linux_server
  sudo bash "$singbox_dir/setup.sh"
}

cmd_server_start() {
  require_linux_server
  if [ ! -f "$SERVER_CONFIG" ]; then
    cmd_server_setup
  else
    sudo systemctl start sing-box
  fi
}

cmd_server_stop() {
  require_linux_server
  sudo systemctl stop sing-box
}

cmd_server_restart() {
  require_linux_server
  sudo systemctl restart sing-box
}

cmd_server_status() {
  require_linux_server
  systemctl --no-pager --full status sing-box
}

cmd_server_log() {
  require_linux_server
  sudo journalctl -u sing-box -f
}
