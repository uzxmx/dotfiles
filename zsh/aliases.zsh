alias bi="bundle install"
alias dc="docker-compose"
alias e='$EDITOR'

alias f="fe"
alias fbr="~/.dotfiles/scripts/fzf/git-branch"
alias fe='capture_source_and_signal ~/.dotfiles/bin/fe "$@"'
alias fed="fe ~/.dotfiles"
alias fedb="fe ~/.dotfiles/bin"
alias fedd="fe ~/.dotfiles/doc"
alias fedz="fe ~/.dotfiles/zsh"
alias fedv="fe ~/.dotfiles/vim"
alias fedh="fe ~/.dotfiles/hooks"
alias feds="fe ~/.dotfiles/scripts"
alias fev="fe ~/.vim"
alias fmerge="~/.dotfiles/scripts/fzf/git-merge"
alias fmergeto="~/.dotfiles/scripts/fzf/git-merge-to"

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
alias ncz="nc -z -v"
alias vi_tiny="vi -u NONE"
alias v='$VISUAL'
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
alias px='capture_source_and_signal ~/.dotfiles/scripts/misc/proxyctl "$@"'
alias pe='px enable'
alias pd='px disable'
alias pi='px info'

alias sd="s ~/.dotfiles"
alias sdd="s ~/.dotfiles/doc"

alias ta="~/.dotfiles/scripts/misc/tmuxctl attach"
alias td="~/.dotfiles/scripts/misc/tmuxctl detach"
alias tl="ta"
alias tn="~/.dotfiles/scripts/misc/tmuxctl new"
alias ts="ta"

alias wb="wget www.baidu.com -O- >/dev/null"
alias wg="wget www.google.com -O- >/dev/null"
alias zl="vi ~/.zshrc.local"

case $OSTYPE in
  darwin*)
    alias ctags="ctags --languages=objectivec --langmap=objectivec:.h.m"
    ;;
esac

# Include custom aliases (keep this line at the very bottom)
[[ -f ~/.zsh/aliases.local ]] && source ~/.zsh/aliases.local
