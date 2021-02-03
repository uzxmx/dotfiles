select_device() {
  local device="$(adb devices | sed 1d | awk '/.+/ { print $1 }' | fzf --select-1 --prompt "Select a device> " --exit-0)"
  if [ -z "$device" ]; then
    echo "No device available" >&2
    exit 1
  else
    echo "$device"
  fi
}

select_process() {
  local device="$1"
  local selected="$(adb -s "$device" shell ps -A -o PID,PPID,ARGS -w | sed 1d | fzf --with-nth=3 \
    --preview "adb -s '$device' shell ps --pid {1}")"
  if [ -n "$selected" ]; then
    echo "$selected" | awk '{print $1}'
  else
    exit 1
  fi
}
