# Borrowed from https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/history.zsh
[[ -z "$HISTFILE" ]] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# Use ctrl-p/ctrl-n or arrow up/down to go through local history.
# Use ctrl-r to search global history.
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history

bindkey "^P"   up-line-or-local-history
bindkey "^[[A" up-line-or-local-history
bindkey "^N"   down-line-or-local-history
bindkey "^[[B" down-line-or-local-history

# We cannot use zsh default search history behavior, because zsh only searches from the timestamp when the last
# command was executed in the current session to the oldest event, new events from global history file after that
# time won't be searched. So we use `hstr` to search history from the latest event to the oldest.
_search_global_history() {
  selected=$(HSTR_CONFIG=raw-history-view hstr -n | FZF_DEFAULT_OPTS="--height 50% $FZF_DEFAULT_OPTS --tiebreak=index --bind=ctrl-r:toggle-sort --query=${(qqq)LBUFFER} +m" fzf)
  local ret=$?
  if [ -n "$selected" ]; then
    BUFFER=$selected
    zle end-of-line
  fi
  zle reset-prompt
  return $ret
}
zle -N _search_global_history
bindkey "^R" _search_global_history

# HISTFILE should be exported in order to be used by `hstr`.
export HISTFILE=~/.zsh_history
