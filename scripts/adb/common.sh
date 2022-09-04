select_device() {
  local device="$(adb devices | sed 1d | awk '/.+/ { print $1 }' | fzf --select-1 --prompt "Select a device> " --exit-0)"
  if [ -z "$device" ]; then
    echo "No device available" >&2
    exit 1
  else
    echo "$device"
  fi
}

# Select android process.
#
# @params
#   $1: device serial
#   $2: string to be grepped, if given, fzf won't be used
select_process() {
  local device="$1"
  local str="$2"
  local output use_ps_vendor_format
  if ! output="$(adb -s "$device" shell ps -A -o PID,PPID,ARGS -w)" || [ "$(echo "$output" | wc -l)" -ge "1" ]; then
    # Old devices may not support `-A` option.
    if ! output="$(adb -s "$device" shell ps)"; then
      echo "$output" >&2
      exit 1
    else
      use_ps_vendor_format=1
    fi
  fi

  local selected pid_index
  local -a fzf_opts
  if [ "$use_ps_vendor_format" = "1" ]; then
    pid_index=2
  else
    fzf_opts=(--with-nth=3)
    pid_index=1
  fi

  if [ -n "$str" ]; then
    echo "$output" | grep "$str" | fzf --prompt "Select a process: " -1 | awk "{print \$$pid_index}"
  else
    local selected="$(echo "$output" | sed 1d | fzf "${fzf_opts[@]}" \
      --preview "adb -s '$device' shell ps --pid {1}")"
    if [ -n "$selected" ]; then
      echo "$selected" | awk "{print \$$pid_index}"
    else
      exit 1
    fi
  fi
}
