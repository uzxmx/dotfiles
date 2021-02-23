usage_cm() {
  cat <<-EOF
Usage: g cm [<message>]

Enhanced commit utility.
EOF
  exit 1
}

cmd_cm() {
  local args=()
  if [ -n "$1" ]; then
    args+=(-m "$1")
  fi
  local last_unixtime="$(git log -n 1 --format="%at" 2>/dev/null)"
  local -a date_opts
  if [ -n "$last_unixtime" ]; then
    source "$dotfiles_dir/scripts/lib/system.sh"
    if is_mac; then
      date_opts=(-r "$last_unixtime")
    else
      date_opts=(--date "@$last_unixtime")
    fi
  fi
  source "$dotfiles_dir/scripts/lib/prompt.sh"
  local date
  ask_for_input date "Commit date: " "$(date "${date_opts[@]}" "+%Y-%m-%d %H:%M:%S")"
  git commit -s --date "$date" "${args[@]}"
}
