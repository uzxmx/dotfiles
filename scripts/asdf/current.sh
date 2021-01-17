source "$(dirname $BASH_SOURCE)/common.sh"

cmd_current() {
  [ "$#" -gt 0 ] && (asdf current "$@" || true) && exit

  local plugin
  plugin="$(select_plugin --prompt "Show current versions> ")"
  asdf current "$plugin"
}
alias_cmd c current
