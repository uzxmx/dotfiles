# Utils
alias l="ls -1tA"
alias la="ls -a"
alias ll="ls -lh"
alias f="fe"
alias mkdir="mkdir -p"
alias get='wget --continue --progress=bar'
alias html2pug="html2pug -d"
alias vi_tiny="vi -u NONE"
alias e="$EDITOR"
alias v="$VISUAL"
alias h="sudo vi /etc/hosts"

# Git
alias ga="git add"
alias gaa="git add -A"
alias gb='git branch -v'
alias gbr="git browser"
alias gc='git commit -s'
alias gcm='git commit -s -m'
alias gco="git checkout"
alias gd="git diff"
alias gdc="git diff --cached"
alias gh="git help"
alias gl="git log"
alias gp="git pull"
alias gps="git push"
alias gpss="git pushs"
alias gpr="git pr"
alias gr="git reset"
alias gs="git stash"

# Bundler
alias b="bundle"

# Rails
alias migrate="bundle exec rake db:migrate"
alias s="bundle exec rspec"

# Docker
alias dc="docker-compose"

case $OSTYPE in
  darwin*)
    # alias ctags-objc="ctags --languages=objectivec --langmap=objectivec:.h.m"
    alias ctags="ctags --languages=objectivec --langmap=objectivec:.h.m"
    ;;
esac

# Include custom aliases (keep this line at the very bottom)
[[ -f ~/.zsh/aliases.local ]] && source ~/.zsh/aliases.local
