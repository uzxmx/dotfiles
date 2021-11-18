source "$vpn_dir/common.sh"

usage_setup_client() {
  cat <<-EOF
Usage: vpn setup_client

Setup ipsec VPN for client.

You must define below environment variables in '~/.vpn_env':
  * VPN_SERVER_IP
  * VPN_IPSEC_PSK
  * VPN_USER
  * VPN_PASSWORD
EOF
  exit 1
}

cmd_setup_client() {
  source "$dotfiles_dir/scripts/lib/install.sh"

  echo "Check and install dependencies..."
  if has_apt; then
    sudo apt-get install -y libreswan xl2tpd &>/dev/null
  else
    abort "Unsupported system"
  fi

  source "$dotfiles_dir/scripts/lib/prompt.sh"
  source "$dotfiles_dir/scripts/lib/template.sh"

  render_template "$vpn_dir/ipsec-main.conf.tpl.sh" "/etc/ipsec.d/main.conf" VPN_SERVER_IP
  render_template "$vpn_dir/ipsec-main.secrets.tpl.sh" "/etc/ipsec.d/main.secrets" VPN_IPSEC_PSK
  render_template "$vpn_dir/xl2tpd.conf.tpl.sh" "/etc/xl2tpd/xl2tpd.conf" VPN_SERVER_IP
  render_template "$vpn_dir/options.l2tpd.client.tpl.sh" "/etc/ppp/options.l2tpd.client" VPN_USER VPN_PASSWORD

  echo "Enable services..."
  sudo systemctl enable ipsec xl2tpd
}

render_template() {
  local template_file="$1"
  local target_file="$2"
  if [ -e "$target_file" ]; then
    if [ "$(yesno "File $target_file already exists. Do you want to overwrite it? (y/N)" "no")" = "no" ]; then
      return
    fi
  fi

  shift 2
  for env in "$@"; do
    check_env_variable "$env"
  done

  echo "Render template file for $target_file..."
  render_shell_template_file "$template_file" | sudo tee "$target_file" >/dev/null
}
