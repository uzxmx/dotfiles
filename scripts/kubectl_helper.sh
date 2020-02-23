#!/bin/sh
#
# Usage: source ~/.dotfiles/scripts/kubectl_helper.sh

alias k="kubectl --namespace=\$KUBECTL_NAMESPACE"

if [[ "$SHELL" =~ "bash" ]]; then
  source <(kubectl completion bash)
  # TODO show completion with correct KUBECTL_NAMESPACE
  complete -F __start_kubectl k
elif [[ "$SHELL" =~ "zsh" ]]; then
  source <(kubectl completion zsh)
fi
