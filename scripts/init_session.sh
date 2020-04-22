#!/usr/bin/env zsh

. $(dirname "$0")/utils.sh

PROG="$0"

ensure_passwordless_sudo() {
  if ! sudo echo foo; then
    tmux display-message "$PROG: Passwordless sudo is required."
    exit 1
  fi
}

if is_wsl; then
  ensure_passwordless_sudo

  if ! service ssh status &>/dev/null; then
    sudo service ssh start
  fi

  if ! nc -z localhost 8123; then
    sudo polipo
  fi
fi
