# Zsh 5.3.1 is required.

[ -z "$DOTFILES_DIR" ] && DOTFILES_DIR="$HOME/.dotfiles"
export DOTFILES_DIR

export DOTFILES_TARGET_DIR="${DOTFILES_TARGET_DIR:-$HOME}"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

autoload -Uz compinit
if [ -f "$DOTFILES_TARGET_DIR/.zcompdump" ]; then
  if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    [[ $(date +'%j') == $(stat -f '%Sm' -t '%j' "$DOTFILES_TARGET_DIR/.zcompdump") ]]
  else
    [[ $(date +'%j') == $(date -d "$(stat -c '%z' "$DOTFILES_TARGET_DIR/.zcompdump")" +'%j') ]]
  fi
  if [[ $? != 0 ]]; then
    valid_zcompdump=0
  fi
else
  valid_zcompdump=0
fi
if [[ $valid_zcompdump == 0 ]]; then
  compinit
  # On mac, it seems that $DOTFILES_TARGET_DIR/.zcompdump modification time is not updated when
  # executing `compinit`, so we force updating it.
  touch "$DOTFILES_TARGET_DIR/.zcompdump"
else
  compinit -C
fi
unset valid_zcompdump

[ -f "$DOTFILES_TARGET_DIR/.zsh_plugins.sh" ] && source "$DOTFILES_TARGET_DIR/.zsh_plugins.sh"
source "$DOTFILES_TARGET_DIR/.zsh/configs.zsh"
source "$DOTFILES_TARGET_DIR/.zsh/aliases.zsh"
source "$DOTFILES_TARGET_DIR/.zsh/completions.zsh"
source "$DOTFILES_TARGET_DIR/.zsh/library.zsh"
source "$DOTFILES_TARGET_DIR/.zsh/misc.zsh"

# Load custom functions
for function in "$DOTFILES_TARGET_DIR"/.zsh/functions/*; do
  source $function
done

[ -f "$DOTFILES_TARGET_DIR/.config/fzf/fzf.zsh" ] && source "$DOTFILES_TARGET_DIR/.config/fzf/fzf.zsh"
[ -f "$DOTFILES_TARGET_DIR/.zsh/history.zsh" ] && source "$DOTFILES_TARGET_DIR/.zsh/history.zsh"

if [ -f "$DOTFILES_TARGET_DIR/.asdf/asdf.sh" ]; then
  export ASDF_DATA_DIR="$DOTFILES_TARGET_DIR/.asdf"
  source "$DOTFILES_TARGET_DIR/.asdf/asdf.sh"
fi

[ -f "$DOTFILES_TARGET_DIR/.zshrc.platform" ] && source "$DOTFILES_TARGET_DIR/.zshrc.platform"
[ -f "$DOTFILES_TARGET_DIR/.zshrc.local" ] && source "$DOTFILES_TARGET_DIR/.zshrc.local"

type -p direnv &>/dev/null && eval "$(direnv hook zsh)"

if [ -z "$PWN_DIR" ]; then
  PWN_DIR="$DOTFILES_TARGET_DIR/.pwn"
fi
export PWN_DIR

PATH="$PWN_DIR/bin:$DOTFILES_TARGET_DIR/bin:$PATH:$DOTFILES_DIR/scripts/misc"

if [ -n "$DOTFILES_NON_INTRUSIVE_MODE" ]; then
  PATH="$DOTFILES_DIR/bin_nim:$PATH"
fi

# To make wrapper utilities in `$DOTFILES_DIR/bin` work, we must add it before
# other paths, such as `$DOTFILES_TARGET_DIR/.asdf/shims`.
#
# Add `$DOTFILES_DIR/bin` before `$DOTFILES_DIR/bin_nim`, so we can override
# utilities from the latter for both intrusive and non-intrusive mode.
#
# Add `$DOTFILES_TARGET_DIR/.local/bin` before `$DOTFILES_DIR/bin`, so we can override
# utilities from the latter for current host.
PATH="$DOTFILES_TARGET_DIR/.local/bin:$DOTFILES_DIR/bin:$PATH"
