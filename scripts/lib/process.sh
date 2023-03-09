#!/bin/sh

# Run background job.
#
# @params:
#   $1: name
#   VARARGS: command to execute
run_background_job() {
  local name="$1"; shift

  local dir="$DOTFILES_DIR/tmp/background"
  mkdir -p "$dir"

  local pid_file="$dir/$name.pid"

  if [ -e "$pid_file" ]; then
    if ps -p "$(cat "$pid_file")" &>/dev/null; then
      return
    fi
  fi

  local log_file="$dir/$name.log"

  # Ref: https://stackoverflow.com/questions/3430330/best-way-to-make-a-shell-script-daemon
  nohup "$@" 0<&- &>"$log_file" &

  echo "$!" >"$pid_file"
}
