# Bash-like help support. To find help files, we may also need to set HELPDIR environment variable with
# something like /path/to/zsh_help_directory.
unalias run-help 2>/dev/null
autoload run-help
alias help=run-help

PURE_PROMPT_VICMD_SYMBOL="[VIM]❯"

# KEYTIMEOUT is only used when a bound key is also used as a prefix key. If timeout happens,
# action of that prefix key will be taken. The unit is 10ms.
export KEYTIMEOUT=100

bindkey -v

# It may be for the sake of convenience, zsh uses CTRL-[ that is the same key as ESC. By default CTRL-[ is mapped to
# enter into vi-cmd-mode in zle vi mode. But as CTRL-[ may be used as a prefix key and I specified a long KEYTIMEOUT above,
# in order to enter into vi-cmd-mode quickly, here I just map CTRL-[,CTRL-[ to vi-cmd-mode.
bindkey "\e\e" vi-cmd-mode

bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search
bindkey '^R' history-incremental-search-backward
bindkey '^W' backward-kill-word
bindkey "^V" edit-command-line

# TODO bindkey "^S" to search something
# ^Y
# ^F
# ^Z

_versatile_open() {
  local program result filetype cmd
  program=$(echo "$BUFFER" | awk '{print $1}')
  if [[ -z "$program" ]]; then
    if [[ "$OSTYPE" == darwin* ]]; then
      open .
    fi
  else
    result=`which $program`
    if [[ -f "$result" ]]; then
      filetype=$(file -I "$result" | awk '{print $3}')
      if [[ "$filetype" == "charset=binary" ]]; then
        cmd="exec man $program"
      else
        cmd="exec $EDITOR $result"
      fi
    else
      cmd="exec echo '$result' | $EDITOR -"
    fi
    tmux new-window "$cmd"
  fi
}
zle -N _versatile_open
bindkey "^O" _versatile_open

# TODO remove these
# _run_compinit() {
#   if compinit; then
#     zle end-of-list
#     echo "Completion initialized\n"
#     zle reset-prompt
#     return 0
#   fi
# }
# zle -N _run_compinit
# bindkey "^Xc" _run_compinit

# Borrowed from https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/key-bindings.zsh
# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line

# file rename magick
bindkey "^[m" copy-prev-shell-word

# Borrowed from https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/theme-and-appearance.zsh
if [[ "$OSTYPE" == darwin* ]]; then
  ls -G . &>/dev/null && alias ls='ls -G'
else
  if [[ -z "$LS_COLORS" ]]; then
    (( $+commands[dircolors] )) && eval "$(dircolors -b)"
  fi

  ls --color -d . &>/dev/null && alias ls='ls --color=tty' || { ls -G . &>/dev/null && alias ls='ls -G' }

  # Take advantage of $LS_COLORS for completion as well.
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# Bash like completion
setopt noautomenu

# So as not to be disturbed by Ctrl-S ctrl-Q in terminals
stty -ixon

# Case-insensitive matching only if there are no case-sensitive matches
# Ref: https://superuser.com/questions/1092033/how-can-i-make-zsh-tab-completion-fix-capitalization-errors-for-directorys-and
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

export VISUAL=vi
export EDITOR=$VISUAL

PATH=$HOME/.local/bin:$HOME/.bin:$HOME/bin:/usr/local/bin:$PATH

# TODO add doc
ZSH_UTILS_CD_PATH=(~/tmp)

export GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# This requires go version >= 1.11
export GO111MODULE=on
export GOPROXY=https://goproxy.io

# Use `asdf where java` to find the JAVA_HOME
export JAVA_HOME=$HOME/.asdf/installs/java/adopt-openjdk-9+181
