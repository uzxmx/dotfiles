#!/usr/bin/env bash
#
# Install fzf (https://github.com/junegunn/fzf)

. $(dirname "$0")/utils.sh

if is_mac; then
  brew_install fzf
  /usr/local/opt/fzf/install --key-bindings --completion --no-bash --no-update-rc
elif has_apt; then
  sudo apt-get install -y fzf
else
  if $(test -d ~/.fzf && cd ~/.fzf && git status &>/dev/null); then
    git pull
  else
    rm -rf ~/.fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  fi
  ~/.fzf/install --key-bindings --completion --no-bash --no-update-rc
fi
