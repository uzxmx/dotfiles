usage_mirror() {
  cat <<-EOF
Usage: brew mirror [--set | --reset] [--formular] [--bottle]

Options:
  --set Set mirrors
  --reset Reset mirrors
  --formular Operate on mirrors of formular type
  --bottle Operate on mirrors of bottle type
EOF
  exit 1
}

cmd_mirror() {
  local action="show"
  local types=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --set)
        action="set"
        ;;
      --reset)
        action="reset"
        ;;
      --formular | --bottle)
        types+=("${1:2}")
        ;;
    esac
    shift
  done

  if [ "$action" = "show" ]; then
    echo Repo: $(git -C "$(brew --repo)" config --get remote.origin.url)
    echo Core repo: $(git -C "$(brew --repo homebrew/core)" config --get remote.origin.url)
    echo Cask repo: $(git -C "$(brew --repo homebrew/cask)" config --get remote.origin.url)
    echo HOMEBREW_BOTTLE_DOMAIN=$HOMEBREW_BOTTLE_DOMAIN
  else
    local remote_url core_remote_url cask_remote_url
    for t in "${types[@]}"; do
      case "$t" in
        formular)
          if [ "$action" = "reset" ]; then
            remote_url="https://github.com/Homebrew/brew.git"
            core_remote_url="https://github.com/Homebrew/homebrew-core.git"
            cask_remote_url="https://github.com/Homebrew/homebrew-cask.git"
          else
            remote_url="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
            core_remote_url="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
            cask_remote_url="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git"
          fi
          local repo="$(brew --repo)"
          if [ -n "$repo" ]; then
            for url in "$remote_url" "$core_remote_url" "$cask_remote_url"; do
              git -C "$repo" remote set-url origin "$url"
            done
            echo -n "Formular mirrors have been "
            if [ "$action" = "reset" ]; then
              echo reset.
            else
              echo set.
            fi
            echo
          fi
          ;;
        bottle)
          if [ "$action" = "reset" ]; then
            echo Please execute below scripts to reset mirror for bottle:
            echo unset HOMEBREW_BOTTLE_DOMAIN
          else
            echo Please execute below scripts to set mirror for bottle:
            echo export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
          fi
          ;;
      esac
    done
  fi
}
alias_cmd m mirror
