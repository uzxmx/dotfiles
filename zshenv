# Use `~/.zshenv.pre.local` if you want to predefine values for PATH for some system.
[[ -f ~/.zshenv.pre.local ]] && source ~/.zshenv.pre.local

export GOPATH=$HOME/go

# This requires go version >= 1.11
export GO111MODULE=on
export GOPROXY=https://goproxy.io

# Use `asdf where java` to find the JAVA_HOME
export JAVA_HOME=$HOME/.asdf/installs/java/adopt-openjdk-9+181

PATH=$HOME/.local/bin:$HOME/.dotfiles/bin:$HOME/bin:$GOPATH/bin:/usr/local/bin:$PATH
