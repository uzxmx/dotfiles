#!/usr/bin/env zsh
#
# Change color scheme for vim.

schemes=(
  Solarized
  Snazzy
)

scheme=$(IFS=$'\n'; echo "${schemes[*]}" | fzf)
if [[ -n "$scheme" ]]; then
  scheme=$(echo $scheme | tr 'A-Z' 'a-z')
  vimfile="$HOME/.vim/vimrc.before.local"
  if [[ -f "$vimfile" ]]; then
    regexp="^(let g:current_colorscheme = ').*(')$"
    if grep -E "$regexp" "$vimfile" &>/dev/null; then
      sed -Ee "s/${regexp}/\1${scheme}\2/" -i "" "$vimfile"
      exit
    fi
  fi

  code="let g:current_colorscheme = '$scheme'"
  if [[ -f "$vimfile" ]]; then
    echo "$code" >>"$vimfile"
  else
    echo "$code" >"$vimfile"
  fi
fi
