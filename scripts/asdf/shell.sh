source "$(dirname $BASH_SOURCE)/common.sh"

cmd_shell() {
  [ "$#" -gt 0 ] && (asdf shell "$@" || true) && exit

  local plugin current version prompt
  plugin="$(select_plugin --prompt "Change version in current shell> ")"
  current="$(asdf current "$plugin" 2>/dev/null | awk '{print $2}' || true)"
  if [ -z "$current" ]; then
    prompt="No current version"
  else
    prompt="Current version: $current"
  fi
  version="$(asdf list "$plugin" | fzf --prompt "$prompt> " | "$DOTFILES_DIR/bin/trim" | sed 's/^\*//')"
  if { true >&3; } 2> /dev/null; then
    echo asdf shell "$plugin" "$version" ";" echo "$plugin" version has been changed to "$version" in current shell. >&3
    exit 104
  else
    echo -e "Run below command in your shell:\n"
    echo asdf shell "$plugin" "$version"
  fi
}
alias_cmd s shell
