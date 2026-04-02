source "$(dirname $BASH_SOURCE)/common.sh"

_asdf_shell_export() {
  local plugin="$1" version="$2"
  local env_var="ASDF_$(echo "$plugin" | tr '[:lower:]-' '[:upper:]_')_VERSION"
  local export_cmd="export ${env_var}=${version}"
  if { true >&3; } 2>/dev/null; then
    echo "$export_cmd" >&3
    exit 104
  else
    echo -e "Run below command in your shell:\n"
    echo "$export_cmd"
  fi
}

cmd_shell() {
  if [ "$#" -gt 1 ]; then
    _asdf_shell_export "$1" "$2"
    return
  fi

  local plugin current version prompt
  plugin="$(select_plugin --prompt "Change version in current shell> ")"
  current="$(asdf current "$plugin" 2>/dev/null | awk '{print $2}' || true)"
  if [ -z "$current" ]; then
    prompt="No current version"
  else
    prompt="Current version: $current"
  fi
  version="$(asdf list "$plugin" | fzf --prompt "$prompt> " | "$DOTFILES_DIR/bin/trim" | sed 's/^\*//')"
  _asdf_shell_export "$plugin" "$version"
}
alias_cmd s shell
