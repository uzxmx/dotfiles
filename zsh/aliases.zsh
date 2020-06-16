alias dc="docker-compose"
alias e='$EDITOR'

alias f="fe"
alias fed="fe ~/.dotfiles"
alias fedb="fe ~/.dotfiles/bin"
alias fedd="fe ~/.dotfiles/doc"
alias fedz="fe ~/.dotfiles/zsh"
alias fedv="fe ~/.dotfiles/vim"
alias fedh="fe ~/.dotfiles/hooks"
alias feds="fe ~/.dotfiles/scripts"
alias fev="fe ~/.vim"

alias get='wget --continue --progress=bar'

# Git
alias ga="git add"
alias gaa="git add -A"
alias gb='git branch -v'
alias gbr="git browser"
alias gc='git commit -s'
alias gcb='git cleanb'
alias gcm='git commit -s -m'
alias gco="git checkout"
alias gcl="git clone"
alias gd="git diff"
alias gdc="git diff --cached"
alias gf="git fetch"
alias gh="git help"
alias gl="git log"
alias gp="git pull"
alias gps="git push"
alias gpss="git pushs"
alias gpr="git pr"
alias gr="git remote -v"
alias grb="git rebase"
alias grs="git reset"
alias gs="git status"
alias gsa="git stash apply"
alias gss="git stash"
alias gsp="git stash pop"
alias gt="git tag"

alias k='kubectl --namespace="$KUBECTL_NAMESPACE"'
alias l="ls -1tA"
alias la="ls -a"
alias ll="ls -lh"

alias lg="lazygit"

alias m="mkdir -p"
alias migrate="bundle exec rake db:migrate"
alias vi_tiny="vi -u NONE"
alias v='$VISUAL'
alias va="vagrant"
alias p="pwd"

# proxyctl
alias pe='() { source <(~/.dotfiles/scripts/proxyctl enable "$@") }'
alias pd='() { source <(~/.dotfiles/scripts/proxyctl disable "$@") }'
alias pi='() { source <(~/.dotfiles/scripts/proxyctl dump "$@") }'

alias sd="s ~/.dotfiles"
alias sdd="s ~/.dotfiles/doc"

alias ta="~/.dotfiles/scripts/tmuxctl attach"
alias td="~/.dotfiles/scripts/tmuxctl detach"
alias tl="ta"
alias tn="~/.dotfiles/scripts/tmuxctl new"
alias ts="ta"

case $OSTYPE in
  darwin*)
    alias ctags="ctags --languages=objectivec --langmap=objectivec:.h.m"
    ;;
esac

# Include custom aliases (keep this line at the very bottom)
[[ -f ~/.zsh/aliases.local ]] && source ~/.zsh/aliases.local
