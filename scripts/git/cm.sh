usage_cm() {
  cat <<-EOF 1>&2
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
  source "$dotfiles_dir/scripts/lib/prompt.sh"
  local date
  ask_for_input date "Commit date: " "$(date "+%Y-%m-%d %H:%M:%S")"
  git commit -s --date "$date" "${args[@]}"
}
