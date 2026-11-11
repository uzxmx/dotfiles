#!/usr/bin/env bash
#
# Make a curl progress meter line (12 columns) more readable, e.g.
#   '24 3941k 24 955k 0 0 16656 0 0:04:00 0:00:59 0:03:01 17000'
#   => 'Downloaded 24% (955k/3941k), 17000/s, ETA 0:03:01'
# Other lines are passed through unchanged.
_run_with_status_format_line() {
  awk '
    NF == 12 && $1 ~ /^[0-9]+$/ && $11 ~ /^([0-9-]+:){2}[0-9-]+$/ {
      if ($2 == "0") { print "Connecting..."; next }
      printf "Downloaded %s%% (%s/%s), %s/s, ETA %s\n", $1, $4, $2, $12, $11
      next
    }
    { print }
  '
}

# Run a command with all output redirected to a log file, while showing a
# single-line live status (elapsed time, current stage, last log line) on the
# terminal.
#
# A stage is any log line starting with '==> ', e.g. `echo "==> Compiling"`.
#
# When stdout is not a TTY, the command runs silently (output only goes to the
# log file).
#
# @params
#   $1: log file
#   VARARGS: command and its arguments
# @return the exit status of the command
run_with_status() {
  local log_file="$1"
  shift

  if [ ! -t 1 ]; then
    "$@" &>"$log_file"
    return
  fi

  "$@" &>"$log_file" &
  local pid=$!
  local start=$SECONDS elapsed stage last cols status_line

  # Make sure the command won't keep running in the background when we are
  # interrupted.
  trap "kill $pid 2>/dev/null; printf '\r\033[K'; exit 130" INT TERM

  while kill -0 "$pid" 2>/dev/null; do
    elapsed=$((SECONDS - start))
    stage="$(grep -a '^==> ' "$log_file" 2>/dev/null | tail -1 | cut -c5- || true)"
    # Use the text after the last '\r' (for progress output like curl), and
    # drop non-printable characters.
    last="$(tail -c 2000 "$log_file" 2>/dev/null | grep -av '^[[:space:]]*$' | tail -1 | awk -F'\r' '{print $NF}' | tr -cd '[:print:]' | _run_with_status_format_line || true)"
    cols="$(tput cols 2>/dev/null || echo 80)"

    status_line="$(printf '[%02d:%02d] %s' $((elapsed / 60)) $((elapsed % 60)) "${stage:-Running}")"
    [ -n "$last" ] && status_line="$status_line | $last"
    printf '\r\033[K%s' "${status_line:0:$((cols - 1))}"
    sleep 1
  done

  local ret=0
  wait "$pid" || ret=$?
  trap - INT TERM
  printf '\r\033[K'
  return "$ret"
}
