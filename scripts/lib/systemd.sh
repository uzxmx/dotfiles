#!/bin/sh

# Start a systemd service if it's not running.
#
# @params:
#   $1: service name
systemctl_start() {
  if [ ! "$(systemctl is-active "$1")" = "active" ]; then
    sudo systemctl start "$1"
  fi
}

# Stop a systemd service if it's running.
#
# @params:
#   $1: service name
systemctl_stop() {
  if [ "$(systemctl is-active "$1")" = "active" ]; then
    sudo systemctl stop "$1"
  fi
}
