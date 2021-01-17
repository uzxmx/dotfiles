source "$(dirname $BASH_SOURCE)/common.sh"

cmd_list() {
  [ "$#" -gt 0 ] && (asdf list "$@" || true) && exit

  local plugin
  plugin="$(select_plugin --prompt "List package versions> ")"
  asdf list "$plugin"
}
alias_cmd l list
