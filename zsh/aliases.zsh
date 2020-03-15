alias dc="docker-compose"
alias e='$EDITOR'
alias f="fe"
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
alias gh="git help"
alias gl="git log"
alias gp="git pull"
alias gps="git push"
alias gpss="git pushs"
alias gpr="git pr"
alias gr="git remote -v"
alias grs="git reset"
alias gs="git status"
alias gss="git stash"

alias h="sudo vi /etc/hosts"
alias k='kubectl --namespace="$KUBECTL_NAMESPACE"'
alias l="ls -1tA"
alias la="ls -a"
alias ll="ls -lh"
alias m="mkdir -p"
alias migrate="bundle exec rake db:migrate"
alias vi_tiny="vi -u NONE"
alias v='$VISUAL'
alias va="vagrant"
alias p="pwd"
alias sd="s ~/.dotfiles"
alias sdd="s ~/.dotfiles/doc"

case $OSTYPE in
  darwin*)
    alias ctags="ctags --languages=objectivec --langmap=objectivec:.h.m"
    ;;
esac

# Include custom aliases (keep this line at the very bottom)
[[ -f ~/.zsh/aliases.local ]] && source ~/.zsh/aliases.local
