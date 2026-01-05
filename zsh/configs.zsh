# If the terminal is `alacritty`, remote commands may fail when ssh. So we
# override TERM here.
# See: https://github.com/alacritty/alacritty/issues/3962
if [ "$TERM" = "alacritty" ]; then
  TERM="xterm-256color"
fi

# Bash-like help support. To find help files, we may also need to set HELPDIR environment variable with
# something like /path/to/zsh_help_directory.
unalias run-help 2>/dev/null
autoload run-help
alias help=run-help

if [ -n "$DOTFILES_NON_INTRUSIVE_MODE" ]; then
  PROMPT='[%F{red}nim]$prompt_newline%F{grey}%* '$PROMPT
else
  PROMPT='%F{grey}%* '$PROMPT
fi
PURE_PROMPT_VICMD_SYMBOL="[VIM]❯"
# Keep dirty color same with git:branch.
zstyle :prompt:pure:git:dirty color 242

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
bindkey "^R" history-incremental-search-backward
bindkey "^W" vi-backward-kill-word
bindkey "^V" edit-command-line

# Press `CTRL-X /` to complete the filename.
bindkey "^X/" _bash_complete-word

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

# By using below option, we don't need to quote the url containing params like
# `curl localhost/foo?bar=baz`. Otherwise, zsh fails with `no matches found` error.
# This can also make `rax2 =16 0xe+0xf` (showing the hex result of 0xe plus 0xf) work.
setopt no_nomatch

unsetopt BEEP

if [ -t 0 ]; then
  # So as not to be disturbed by Ctrl-S ctrl-Q in terminals
  stty -ixon
fi

# Case-insensitive matching only if there are no case-sensitive matches
# Ref: https://superuser.com/questions/1092033/how-can-i-make-zsh-tab-completion-fix-capitalization-errors-for-directorys-and
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

export VISUAL=vi
export EDITOR=$VISUAL

export GOPATH="$DOTFILES_TARGET_DIR/go"

# This requires go version >= 1.11
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,https://gocenter.io,https://goproxy.io,direct

export FZF_DEFAULT_OPTS="--no-mouse --cycle --bind 'ctrl-y:execute-silent(echo -n {} | trim | cb)+abort' --bind 'ctrl-h:execute-silent(tmux select-pane -L),ctrl-j:execute-silent(tmux select-pane -D),ctrl-k:execute-silent(tmux select-pane -U),ctrl-l:execute-silent(tmux select-pane -R)'"

export THEOS="$DOTFILES_TARGET_DIR/theos"

# Change default language to English for java programs.
export JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -Duser.language=en"

# Use a clean PATH variable
PATH="$THEOS/bin:$DOTFILES_TARGET_DIR/.cargo/bin:$GOPATH/bin:$DOTFILES_TARGET_DIR/.dotnet/tools:$DOTFILES_TARGET_DIR/sdk/bin:$DOTFILES_TARGET_DIR/opt/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/share/dotnet:/usr/local/games:/usr/games:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"

if [[ "$(uname -r)" =~ [Mm]icrosoft ]]; then
  _path="$(/mnt/c/Windows/System32/cmd.exe /c "echo %PATH%" 2>/dev/null | tr ";" "\n" | sed -Ee 's/^([C-Z]):/\/mnt\/\l\1/' -e 's/\\/\//g' | tr "\n" ":")"
  if [[ -n "$_path" ]]; then
    PATH="$PATH:$_path"
  fi
fi

export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
