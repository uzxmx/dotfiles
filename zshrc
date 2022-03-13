# Zsh 5.3.1 is required.

autoload -Uz compinit
if [[ -f ~/.zcompdump ]]; then
  if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    [[ $(date +'%j') == $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]]
  else
    [[ $(date +'%j') == $(date -d "`stat -c '%z' ~/.zcompdump`" +'%j') ]]
  fi
  if [[ $? != 0 ]]; then
    valid_zcompdump=0
  fi
else
  valid_zcompdump=0
fi
if [[ $valid_zcompdump == 0 ]]; then
  compinit
  # On mac, it seems that ~/.zcompdump modification time is not updated when
  # executing `compinit`, so we force updating it.
  touch ~/.zcompdump
else
  compinit -C
fi

source ~/.zsh_plugins.sh
source ~/.zsh/configs.zsh
source ~/.zsh/aliases.zsh
source ~/.zsh/completions.zsh
source ~/.zsh/library.zsh
source ~/.zsh/misc.zsh

# Load custom functions
for function in ~/.zsh/functions/*; do
  source $function
done

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/.zsh/history.zsh ]] && source ~/.zsh/history.zsh
[[ -f ~/.asdf/asdf.sh ]] && source ~/.asdf/asdf.sh

[[ -f ~/.zshrc.platform ]] && source ~/.zshrc.platform
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

type -p direnv &>/dev/null && eval "$(direnv hook zsh)"

if [ -z "$DOTFILES_DIR" ]; then
  DOTFILES_DIR="$HOME/.dotfiles"
fi
export DOTFILES_DIR

if [ -z "$PWN_DIR" ]; then
  PWN_DIR="$HOME/.pwn"
fi
export PWN_DIR

# To make wrapper utilities in `$DOTFILES_DIR/bin` work, we must add it before
# other paths, such as `~/.asdf/shims`.
PATH="$HOME/.local/bin:$DOTFILES_DIR/bin:$PWN_DIR/bin:$PATH:$DOTFILES_DIR/scripts/misc"
