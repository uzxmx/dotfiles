compdef g="git"

# Helper for commands that expose --complete to list subcommands.
# Usage: _complete_subcmd <cmd>
_complete_subcmd() {
  local cmd="$1"
  if (( CURRENT == 2 )); then
    local -a subcmds
    subcmds=($($cmd --complete 2>/dev/null))
    _values 'subcommand' $subcmds
  elif (( CURRENT == 3 )); then
    local -a subcmds
    subcmds=($($cmd "$words[2]" --complete 2>/dev/null))
    [[ ${#subcmds} -gt 0 ]] && _values 'subcommand' $subcmds
  fi
}

_aliyun() { _complete_subcmd aliyun }
compdef _aliyun aliyun

_npm() { _complete_subcmd npm }
compdef _npm npm
