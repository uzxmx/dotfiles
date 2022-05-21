# Borrowed from https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/history.zsh
[ -z "$HISTFILE" ] && HISTFILE="$DOTFILES_TARGET_DIR/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

# Save each command’s beginning timestamp (in seconds since the epoch) and the
# duration (in seconds) to the history file. The format of this prefixed data
# is: ': <beginning time>:<elapsed seconds>;<command>'
#
# Ref: https://zsh.sourceforge.io/Doc/Release/Options.html
setopt extended_history

setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE

# If a new command line being added to the history list duplicates an older
# one, the older command is removed from the list (even if it is not the
# previous event).
setopt hist_ignore_all_dups

setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

zshaddhistory() {
  # Do not add command to history whose length is too short (the newline char is at the end of the command).
  if [ "${#1}" -lt 5 ]; then
    return 1;
  fi
  return 0;
}

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

# By default, `fc -l` only searches from the history when the terminal's
# session starts plus the local events (executed commands in the current
# terminal's session). This means new events from other terminal's sessions won't
# be searched.
#
# Previously, we used `hstr` to read the history file, so we could resolve the
# above issue, and get the history from other terminal's sessions. But `hstr`
# seems not supporting multi-lines commands well. So we resort to the original
# zshell `fc` builtin.
#
# We use `fc -p -a $HISTFILE` to push the current history list onto a stack,
# read `$HISTFILE` and switch to a new history list. When the current function
# scope is exited, this history list will be automatically popped. This way, we
# can also search new events from other terminal's sessions.
#
# Below function is borrowed from [here](https://github.com/junegunn/fzf/blame/master/shell/key-bindings.zsh).
#
# Ref: https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html (search `fc -l`)
_search_global_history() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  fc -p -a "$HISTFILE"
  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore  --with-nth=2.. $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" fzf) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}

zle -N _search_global_history
bindkey "^R" _search_global_history
