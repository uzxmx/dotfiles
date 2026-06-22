#!/usr/bin/env bash
#
# 在 Ubuntu 服务器上一键安装并配置 sing-box (VLESS + Reality)。
#
# 可用环境变量覆盖：
#   PORT     监听端口，默认 443
#   SNI      Reality 借用的握手域名，默认 www.microsoft.com（需是一个支持 TLS1.3 的真实站点）
#   VERSION  指定 sing-box 版本，默认装最新 stable

set -euo pipefail

PORT="${PORT:-443}"
SNI="${SNI:-www.microsoft.com}"
CONFIG_DIR=/etc/sing-box
CONFIG="$CONFIG_DIR/config.json"

[ "$(id -u)" -eq 0 ] || { echo "请用 root 运行：sudo $0" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || { apt-get update -qq && apt-get install -y curl; }
command -v openssl >/dev/null 2>&1 || { apt-get update -qq && apt-get install -y openssl; }

# 1. 安装 sing-box
if ! command -v sing-box >/dev/null 2>&1; then
  echo "==> 安装 sing-box ..."
  if [ -n "${VERSION:-}" ]; then
    curl -fsSL https://sing-box.app/install.sh | bash -s -- --version "$VERSION"
  else
    curl -fsSL https://sing-box.app/install.sh | bash
  fi
fi
sing-box version

# 2. 生成凭据
echo "==> 生成 UUID / Reality 密钥对 / short_id ..."
UUID="$(sing-box generate uuid)"
KEYS="$(sing-box generate reality-keypair)"
PRIVATE_KEY="$(printf '%s\n' "$KEYS" | awk -F': *' '/PrivateKey/{print $2}')"
PUBLIC_KEY="$(printf '%s\n' "$KEYS" | awk -F': *' '/PublicKey/{print $2}')"
SHORT_ID="$(openssl rand -hex 8)"
SERVER_IP="$(curl -fsSL https://api.ipify.org || curl -fsSL https://ifconfig.me)"

# 3. 写服务端配置
mkdir -p "$CONFIG_DIR"
[ -f "$CONFIG" ] && cp "$CONFIG" "$CONFIG.bak.$(date +%s)"
cat > "$CONFIG" <<EOF
{
  "log": { "level": "info", "timestamp": true },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "::",
      "listen_port": $PORT,
      "users": [ { "uuid": "$UUID", "flow": "xtls-rprx-vision" } ],
      "tls": {
        "enabled": true,
        "server_name": "$SNI",
        "reality": {
          "enabled": true,
          "handshake": { "server": "$SNI", "server_port": 443 },
          "private_key": "$PRIVATE_KEY",
          "short_id": [ "$SHORT_ID" ]
        }
      }
    }
  ],
  "outbounds": [ { "type": "direct", "tag": "direct" } ]
}
EOF

# 4. 校验并启动
sing-box check -c "$CONFIG"
systemctl enable sing-box >/dev/null 2>&1 || true
systemctl restart sing-box
sleep 1
systemctl --no-pager --full status sing-box | head -n 5 || true

# 5. 放行端口（仅当 ufw 启用时）
if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q "Status: active"; then
  ufw allow "$PORT"/tcp >/dev/null 2>&1 || true
fi

sample_config_file="$(dirname "$0")/client-config.json.sample"

cat <<EOF

==================== Params ====================
server               : $SERVER_IP
server_port          : $PORT
uuid                 : $UUID
flow                 : xtls-rprx-vision
server_name / SNI    : $SNI
reality public_key   : $PUBLIC_KEY
reality short_id     : $SHORT_ID
===================================================

Paste the above params into $sample_config_file or copy 'config.json.generated',
and put it into client machine at '~/.config/sing-box/config.json'.
EOF

sed -e "s|SERVER_IP|$SERVER_IP|g" \
    -e "s|SERVER_PORT|$PORT|g" \
    -e "s|UUID_PLACEHOLDER|$UUID|g" \
    -e "s|SNI_PLACEHOLDER|$SNI|g" \
    -e "s|REALITY_PUBLIC_KEY|$PUBLIC_KEY|g" \
    -e "s|SHORT_ID|$SHORT_ID|g" \
    "$sample_config_file" >config.json.generated
