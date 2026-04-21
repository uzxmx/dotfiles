usage_delete() {
  cat <<-EOF
Usage: cronjob delete [<name>]

Delete a cron job. If <name> is omitted, select interactively with fzf.

Arguments:
  <name>  filename in $DOTFILES_TARGET_DIR/opt/my_cron_jobs/
EOF
  exit 1
}

cmd_delete() {
  local cron_dir="$DOTFILES_TARGET_DIR/opt/my_cron_jobs"
  local selected

  if [ -n "$1" ]; then
    selected="$cron_dir/$1"
  else
    selected="$cron_dir/$(ls "$cron_dir" 2>/dev/null | fzf --prompt='Delete cron job> ')" || return 0
  fi

  [ -z "$selected" ] || [ "$selected" = "$cron_dir/" ] && return 0

  source "$DOTFILES_DIR/scripts/lib/cron.sh"
  delete_cron_job_file "$selected"
}

alias_cmd d delete
