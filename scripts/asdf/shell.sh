source "$(dirname $BASH_SOURCE)/common.sh"

cmd_shell() {
  [ "$#" -gt 0 ] && asdf shell "$@" && exit

  local plugin current version prompt
  plugin="$(select_plugin --prompt "Change version in current shell> ")"
  current="$(asdf current "$plugin" 2>/dev/null | awk '{print $1}')"
  if [ -z "$current" ]; then
    prompt="No current version"
  else
    prompt="Current version: $current"
  fi
  version="$(asdf list "$plugin" | fzf --prompt "$prompt> " | "$dotfiles_dir/bin/trim")"
  echo asdf shell "$plugin" "$version" ";" echo "$plugin" version has been changed to "$version" in current shell. >&3
  exit 104
}
alias_cmd s shell
