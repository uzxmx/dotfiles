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
      check_system
      cmd_restart
      ;;
    enable-mirror)
      check_system
      cmd_enable_mirror
      ;;
    disable-mirror)
      check_system
      cmd_disable_mirror
      ;;
    *)
      usage_engine
      ;;
  esac
}

cmd_restart() {
  curl -H "Content-Type: application/json" -d '{ "openContainerView": false }' -ks --unix-socket ~/Library/Containers/com.docker.docker/Data/backend.sock http://localhost/engine/restart
}

cmd_enable_mirror() {
  if [ -z "$DOCKER_REGISTRY_MIRROR" ]; then
    abort "DOCKER_REGISTRY_MIRROR environment variable must be set."
  fi

  local content
  content="$(cat ~/.docker/daemon.json)"
  if [ "$(echo "$content" | jq '."registry-mirrors"' -cMr)" = null ]; then
    echo "$content" | jq '. += {"registry-mirrors": [ "'"$DOCKER_REGISTRY_MIRROR"'" ]}' >~/.docker/daemon.json
    cmd_restart
  fi
}

cmd_disable_mirror() {
  local content
  content="$(cat ~/.docker/daemon.json)"
  if ! [ "$(echo "$content" | jq '."registry-mirrors"' -cMr)" = null ]; then
    echo "$content" | jq 'del(."registry-mirrors")' >~/.docker/daemon.json
    cmd_restart
  fi
}

check_system() {
  if ! is_mac; then
    echo "Only Mac OSX system is supported."
    exit 1
  fi
}
