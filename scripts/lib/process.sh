#!/bin/sh

process_get_background_job_dir() {
  echo "$DOTFILES_DIR/tmp/background"
}

process_get_background_job_pid_file() {
  echo "$(process_get_background_job_dir)/$1.pid"
}

process_get_background_job_log_file() {
  echo "$(process_get_background_job_dir)/$1.log"
}

process_kill_background_job() {
  local pid_file="$(process_get_background_job_pid_file "$1")"

  if [ -e "$pid_file" ]; then
    kill -9 "$(cat "$pid_file")" &>/dev/null
  fi
}

# Run background job.
#
# @params:
#   $1: name
#   VARARGS: command to execute
process_run_background_job() {
  local name="$1"; shift

  local dir="$(process_get_background_job_dir)"
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
