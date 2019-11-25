#!/usr/bin/env zsh

# Add identities to ssh-agent. Borrowed from oh-my-zsh ssh-agent plugin.
ssh_add_identities() {
  local id line sig
  local -a identities loaded_sigs loaded_ids not_loaded

  # check for .ssh folder presence
  if [[ ! -d $HOME/.ssh ]]; then
    return
  fi

  [[ -f "$HOME/.ssh/id_rsa" ]] && identities+=id_rsa

  # get list of loaded identities' signatures and filenames
  for line in ${(f)"$(ssh-add -l)"}; do
    loaded_sigs+=${${(z)line}[2]}
    loaded_ids+=${${(z)line}[3]}
  done

  # add identities if not already loaded
  for id in $identities; do
    # check for filename match, otherwise try for signature match
    if [[ ${loaded_ids[(I)$HOME/.ssh/$id]} -le 0 ]]; then
      sig="$(ssh-keygen -lf "$HOME/.ssh/$id" | awk '{print $2}')"
      [[ ${loaded_sigs[(I)$sig]} -le 0 ]] && not_loaded+="$HOME/.ssh/$id"
    fi
  done

  [[ -n "$not_loaded" ]] && ssh-add ${^not_loaded}
}
