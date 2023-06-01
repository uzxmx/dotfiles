alias ~="cd ~"
alias -- -="cd -"
alias ..="cd .."
alias ...="cd ../.."

alias a='capture_source_and_signal "$DOTFILES_DIR"/bin/asdf "$@"'
alias bi="bundle install"
alias c='capture_source_and_signal "$DOTFILES_DIR"/bin/c "$@"'
alias e='$EDITOR'

alias f="fe"
alias ff="fe -I"
alias fbr="\"$DOTFILES_DIR\"/scripts/fzf/git-branch"
alias fe='capture_source_and_signal "$DOTFILES_DIR"/bin/fe "$@"'
alias fed="fe \"$DOTFILES_DIR\""
alias fev="fe \"$DOTFILES_TARGET_DIR\"/.vim"
alias fmerge="\"$DOTFILES_DIR\"/scripts/fzf/git-merge"
alias fmergeto="\"$DOTFILES_DIR\"/scripts/fzf/git-merge-to"

# Git
alias ga="git add"
alias gaa="git add -A"
alias gbr="git browser"
alias gc='git commit -s'
alias gcm='git commit -s -m'
alias gco="git checkout"
alias gcl="git clone"
alias gd="g d"
alias gdc="g d -c"
alias gf="git fetch"
alias gl="g l"
alias gp="git pull"
alias gps="git push"
alias gpss="git pushs"
alias gpr="git pr"
alias gr="git remote -v"
alias grb="git rebase"
alias grs="git reset"
alias gsa="git stash apply"
alias gss="git stash"
alias gsp="git stash pop"
alias gt="git tag"

alias h='capture_source_and_signal "$DOTFILES_DIR"/bin/h "$@"'

alias k='kubectl --namespace="$KUBECTL_NAMESPACE"'
alias l="ls -1tA"
alias la="ls -a"

alias lg="lazygit"

alias m="mkdir -p"
alias migrate="bundle exec rake db:migrate"
alias mg="echo mg is aliased as no-op, if you want to use it, please remove the alias"
alias ncz="nc -z -v"
alias vi-tiny="vi -u NONE"
alias vad="va destroy"
alias vadf="va destroy -f"
alias vah="va halt"
alias vap="va provision"
alias vau="va up"
alias var="va reload"
alias vas="va ssh"
alias vass="va status"
alias p="pwd"

# proxyctl
alias px='capture_source_and_signal "$DOTFILES_DIR"/scripts/misc/proxyctl "$@"'
alias pe='px enable'
alias pd='px disable'
alias pi='px info'

# `r` is also a zsh built-in command.
alias r='capture_source_and_signal "$DOTFILES_DIR"/bin/r "$@"'

alias s='capture_source_and_signal "$DOTFILES_DIR"/bin/s "$@"'

alias ta="\"$DOTFILES_DIR\"/scripts/misc/tmuxctl attach"
alias td="\"$DOTFILES_DIR\"/scripts/misc/tmuxctl detach"
alias tl="ta"
alias tn="\"$DOTFILES_DIR\"/scripts/misc/tmuxctl new"
alias ts="ta"

alias wb="curl www.baidu.com"
alias wg="curl www.google.com"
alias zl="vi \"$DOTFILES_TARGET_DIR\"/.zshrc.local"

case $OSTYPE in
  darwin*)
    alias ctags="ctags --languages=objectivec --langmap=objectivec:.h.m"
    ;;
esac

# Include custom aliases (keep this line at the very bottom)
[ -f "$DOTFILES_TARGET_DIR/.zsh/aliases.local" ] && source "$DOTFILES_TARGET_DIR/.zsh/aliases.local"
