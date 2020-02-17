#!/usr/bin/env bash
#
# Install bat (https://github.com/sharkdp/bat)

. $(dirname "$0")/utils.sh

if is_mac; then
  brew_install bat
elif has_yum && [ -z "$SKIP_ASDF" ]; then
  $(dirname "$0")/install_rust.sh

  # We won't need clang if below issue is resolved.
  # Ref: https://github.com/sharkdp/bat/issues/650
  #
  # clang is available after `yum install epel-release`
  sudo yum install -y clang

  cargo install bat
else
  echo 'Skipped'
fi
