#!/usr/bin/env bash
#
# Commonly used asdf workflow.

if [[ $# > 1 ]]; then
  echo 'Only accept zero or one parameter.'
  exit 1
elif [[ $# = 1 ]]; then
  package="$1"
  result=$(asdf current $package)
  if [[ $? = 0 ]]; then
    version=$(echo "$result" | awk '{print $1}')
  else
    asdf "$@"
    exit $?
  fi
else
  selection=$(asdf current 2>&1 | fzf)
  if [[ -n "$selection" ]]; then
    package=$(echo "$selection" | awk '{print $1}')
    version=$(echo "$selection" | awk '{print $2}')
  fi
fi

if [[ -n $package && -n $version ]]; then
  selection=$(asdf list $package | sed -e 's/ //g' | sed -e "s/^$version\$/$version */" | fzf --prompt="Select $package version: ")
  if [[ -n "$selection" ]]; then
    version=$(echo $selection | awk '{print $1}')
    echo "asdf shell $package $version && asdf current $package"
  fi
fi
