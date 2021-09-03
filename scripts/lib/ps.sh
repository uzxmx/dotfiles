#!/bin/sh

ps_fzf_select_pid() {
  ps -A -o pid,command | sed 1d | fzf --with-nth=2.. | awk '{print $1}'
}
