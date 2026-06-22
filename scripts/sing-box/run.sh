usage_run() {
  cat <<-EOF
Usage: sing-box run

Run the sing-box client. Config file should be put at '~/.config/sing-box/config.json'.
EOF
  exit 1
}

# 在 macOS 上以 TUN 模式运行 sing-box 客户端（需要 sudo 创建虚拟网卡 + 改路由）
cmd_run() {
  if ! is_mac; then
    abort "Unsupported system"
  fi

  if ! command -v sing-box &>/dev/null; then
    if is_mac; then
      abort 'sing-box not found. Install it first: brew install sing-box'
    else
      abort 'sing-box not found. Install it first: curl -fsSL https://sing-box.app/install.sh | bash'
    fi
  fi

  CLIENT_CONFIG="$HOME/.config/sing-box/config.json"

  if [ ! -f "$CLIENT_CONFIG" ]; then
    abort "Config not found: $CLIENT_CONFIG
Create it from the sample and fill in the server params (from 'sing-box server-setup'):

  mkdir -p \"$(dirname "$CLIENT_CONFIG")\"
  cp \"$singbox_dir/client-config.json.sample\" \"$CLIENT_CONFIG\""
  fi

  DNS_OVERRIDE=(8.8.8.8 1.1.1.1)

  sing-box check -c "$CLIENT_CONFIG"

  SERVICE=""
  ORIG_DNS=""
  primary_iface="$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')" || true
  if [ -n "${primary_iface:-}" ]; then
    SERVICE="$(networksetup -listnetworkserviceorder 2>/dev/null | awk -v dev="$primary_iface" '
      /^\([0-9]+\)/ { name = substr($0, index($0, ") ") + 2) }
      index($0, "Device: " dev ")") { print name; exit }
    ')" || true
  fi

  restore_dns() {
    [ -n "$SERVICE" ] || return 0
    # shellcheck disable=SC2086
    networksetup -setdnsservers "$SERVICE" $ORIG_DNS 2>/dev/null || true
    sudo -n dscacheutil -flushcache 2>/dev/null || true
    sudo -n killall -HUP mDNSResponder 2>/dev/null || true
    echo "==> 已还原 [$SERVICE] 的 DNS：$ORIG_DNS"
  }

  if [ -n "$SERVICE" ]; then
    ORIG_DNS="$(networksetup -getdnsservers "$SERVICE" 2>/dev/null || true)"
    if echo "$ORIG_DNS" | grep -qi "aren't any"; then ORIG_DNS="empty"; fi
    [ -n "$ORIG_DNS" ] || ORIG_DNS="empty"

    trap restore_dns EXIT
    trap 'exit 130' INT TERM

    echo "Current DNS server:"
    scutil --dns | awk '/nameserver\[/{print}' | sort -u

    sudo -v   # 先缓存一次 sudo 凭据（后面 flush 用 sudo -n，退出时不再弹密码）
    networksetup -setdnsservers "$SERVICE" "${DNS_OVERRIDE[@]}"
    sudo -n dscacheutil -flushcache 2>/dev/null || true
    sudo -n killall -HUP mDNSResponder 2>/dev/null || true
    echo "==> [$SERVICE] DNS：$ORIG_DNS  ->  ${DNS_OVERRIDE[*]}（退出自动还原）"
  else
    echo "未识别到主网络服务，跳过 DNS 接管" >&2
  fi

  echo "==> 启动 sing-box TUN（Ctrl-C 退出，会自动还原 DNS 与路由）"
  sudo sing-box run -c "$CLIENT_CONFIG"
}
