usage_engine() {
  cat <<-EOF
Usage: docker engine <subcommand>

Manage docker engine.

Subcommands:
  restart        - restart docker engine
  enable-mirror  - enable registry mirror
  disable-mirror - disable registry mirror
EOF
  exit 1
}

cmd_engine() {
  case "$1" in
    restart)
      cmd_restart
      ;;
    enable-mirror)
      cmd_enable_mirror
      ;;
    disable-mirror)
      cmd_disable_mirror
      ;;
    *)
      usage_engine
      ;;
  esac
}

cmd_restart() {
  if is_mac; then
    curl -H "Content-Type: application/json" -d '{ "openContainerView": false }' -ks --unix-socket ~/Library/Containers/com.docker.docker/Data/backend.sock http://localhost/engine/restart
  else
    sudo systemctl restart docker
  fi
}

cmd_enable_mirror() {
  if [ -z "$DOCKER_REGISTRY_MIRROR" ]; then
    # See https://www.coderjia.cn/archives/dba3f94c-a021-468a-8ac6-e840f85867ea
    DOCKER_REGISTRY_MIRROR="https://docker.unsee.tech"
  fi
  echo "Use docker registry mirror: $DOCKER_REGISTRY_MIRROR"

  local file sudo
  if is_mac; then
    file="$HOME/.docker/daemon.json"
  else
    file="/etc/docker/daemon.json"
    sudo="sudo"
  fi

  local content
  content="$(cat "$file")"
  if [ "$(echo "$content" | jq '."registry-mirrors"' -cMr)" = null ]; then
    echo "$content" | jq '. += {"registry-mirrors": [ "'"$DOCKER_REGISTRY_MIRROR"'" ]}' | $sudo tee "$file" >/dev/null
    cmd_restart
  fi
}

cmd_disable_mirror() {
  local file sudo
  if is_mac; then
    file="$HOME/.docker/daemon.json"
  else
    file="/etc/docker/daemon.json"
    sudo="sudo"
  fi

  local content
  content="$(cat "$file")"
  if ! [ "$(echo "$content" | jq '."registry-mirrors"' -cMr)" = null ]; then
    echo "$content" | jq 'del(."registry-mirrors")' | $sudo tee "$file" >/dev/null
    cmd_restart
  fi
}
