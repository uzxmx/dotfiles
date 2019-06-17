# CTRL-W will delete to the space
autoload -U select-word-style
select-word-style shell

bindkey '^F' forward-char
bindkey '^B' backward-char

# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/.bin:$HOME/bin:/usr/local/bin:$PATH

# Disable pry in rails console by default.
export DISABLE_PRY_RAILS=1

source ~/.zsh_plugins.sh

_load_settings() {
  _dir="$1"
  if [ -d "$_dir" ]; then
    if [ -d "$_dir/pre" ]; then
      for config in "$_dir"/pre/**/*(N-.); do
        if [ ${config:e} = "zwc" ] ; then continue ; fi
        . $config
      done
    fi

    for config in "$_dir"/**/*(N-.); do
      case "$config" in
        "$_dir"/pre/*)
          :
          ;;
        "$_dir"/post/*)
          :
          ;;
        *)
          if [[ -f $config && ${config:e} != "zwc" ]]; then
            . $config
          fi
          ;;
      esac
    done

    if [ -d "$_dir/post" ]; then
      for config in "$_dir"/post/**/*(N-.); do
        if [ ${config:e} = "zwc" ] ; then continue ; fi
        . $config
      done
    fi
  fi
}
_load_settings "$HOME/.zsh/configs"

unsetopt share_history

# Change directory without prefix cd
setopt AUTO_CD

# Bash like completion
setopt noautomenu

file="/usr/share/autojump/autojump.sh"
if [ -e $file ]; then
  source $file
fi

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

export SDKMAN_DIR="$HOME/.sdkman"
load_sdkman() {
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
}

export PATH="$HOME/.rbenv/bin:$PATH"
if type rbenv >/dev/null; then
  rbenv() {
    eval "$(command rbenv init -)"
    [ -s /etc/profile.d/rbenv.sh ] && . /etc/profile.d/rbenv.sh
    rbenv "$@"
  }
fi

load_lua() {
  [ -s ~/.luaver/luaver ] && . ~/.luaver/luaver
}

# So as not to be disturbed by Ctrl-S ctrl-Q in terminals
stty -ixon

load_kubectl() {
  if [ $commands[kubectl] ]; then
    source <(kubectl completion zsh)
  fi
}
