# Borrowed from https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/history.zsh
[ -z "$HISTFILE" ] && HISTFILE="$DOTFILES_TARGET_DIR/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# Eternal history: append-only log, never truncated by zsh.
# Used by ctrl-r global search so commands are never lost across sessions.
HISTFILE_ETERNAL="${HISTFILE}_eternal"

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
setopt inc_append_history     # append each command to HISTFILE immediately (avoids re-importing own entries via share_history)

zshaddhistory() {
  local cmd="${1%%$'\n'}"
  # Do not add command to history whose length is too short (the newline char is at the end of the command).
  if [ "${#1}" -lt 5 ]; then
    return 1;
  fi
  # Append to eternal log in extended_history format so it can be loaded by fc.
  print -r -- ": $(date +%s):0;${cmd}" >> "$HISTFILE_ETERNAL"
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
#
# TODO Check when `ctrl-r` is issued, whether the history file will be rewritten.
_search_global_history() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  # Read the eternal history file directly (no fc load into memory) so search
  # stays fast regardless of file size. tac gives newest-first order; sed strips
  # the ': timestamp:duration;' prefix from extended_history format.
  selected=$(
    tac "$HISTFILE_ETERNAL" 2>/dev/null \
    | sed 's/^: [0-9]*:[0-9]*;//' \
    | perl -ne 'print if !$seen{$_}++' \
    | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" fzf
  )
  local ret=$?
  if [[ -n "$selected" ]]; then
    LBUFFER="$selected"
  fi
  zle reset-prompt
  return $ret
}

zle -N _search_global_history
bindkey "^R" _search_global_history

# tac is not available by default on macOS (it's a GNU coreutils tool).
if ! command -v tac &>/dev/null; then
  tac() { tail -r "$@"; }
fi

# Compact the eternal history file: keep only the most recent occurrence of each
# command. Run automatically on shell startup when the file exceeds 10MB.
_compact_eternal_history() {
  [[ -f "$HISTFILE_ETERNAL" ]] || return
  local tmpfile
  tmpfile=$(mktemp) || return
  # tac = newest first; awk extracts command (everything after first ';'),
  # skips duplicates, tac again to restore chronological order.
  tac "$HISTFILE_ETERNAL" | awk '
    /^: [0-9]+:[0-9]+;/ {
      cmd = substr($0, index($0, ";") + 1)
      if (!seen[cmd]++) print
    }
  ' | tac > "$tmpfile" && mv "$tmpfile" "$HISTFILE_ETERNAL"
}

if [[ -f "$HISTFILE_ETERNAL" ]]; then
  local _eternal_size
  _eternal_size=$(stat -f%z "$HISTFILE_ETERNAL" 2>/dev/null || stat -c%s "$HISTFILE_ETERNAL" 2>/dev/null || echo 0)
  (( _eternal_size > 10485760 )) && _compact_eternal_history  # compact if > 10MB
fi
