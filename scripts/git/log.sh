usage_l() {
  cat <<-EOF 1>&2
Usage: g l [commit]

Enhanced log utility by fzf.

Options:
  -r, --range use range mode. This will ask you to select a start and end commit.
EOF
  exit 1
}

select_commit() {
  local prompt select
  local remainder=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --prompt)
        shift
        prompt="$1"
        ;;
      --select)
        select=1
        ;;
      *)
        remainder+=("$1")
        ;;
    esac
    shift
  done

  local default_prompt="F1:newest-commit CTRL-Y:yank-commit CTRL-V:show-commit"
  local fzf_opts=()
  if [ -n "${remainder[0]}" ] && [[  "${remainder[0]}" =~ .+\.\..+ ]]; then
    default_prompt="$default_prompt CTRL-S:squash-diff"
    local another_commit="$(echo "${remainder[0]}" | awk -F. '{print $1}')"
    fzf_opts+=(--bind "ctrl-s:execute(tmux split-window \"$dotfiles_dir/bin/g show_commit {1} -d \"$another_commit\"\")")
  fi

  local selection="$(git log --first-parent --pretty="format:%h %<(30,trunc)%s %ai %an %d" "${remainder[@]}" \
    | fzf --no-mouse --cycle \
    --layout=reverse \
    --prompt="${prompt:-"$default_prompt> "}" \
    --preview="git show {1} --first-parent --pretty='commit %H%d%nParent: %p%nAuthor: %an%nDate:   %ai%n%n%w(0,4,4)%B%-' --name-status" \
    --preview-window="right:50%:wrap" \
    --bind=f1:top \
    --bind "ctrl-y:execute-silent(echo -n {1} | trim | cb && tmux display-message yanked)" \
    --bind "ctrl-v:execute(tmux split-window \"$dotfiles_dir/bin/g show_commit {1}\")" \
    "${fzf_opts[@]}"
  )"
  if [ "$select" = "1" ]; then
    echo "$selection" | awk '{print $1}'
  fi
}

cmd_l() {
  local range_mode commit
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -r | --range)
        range_mode=1
        ;;
      -*)
        usage_l
        ;;
      *)
        commit="$1"
        ;;
    esac
    shift
  done

  if [ "$range_mode" = "1" ]; then
    local start_commit end_commit
    end_commit="$(select_commit --prompt "Select the newest commit> " --select)"
    if [ -n "$end_commit" ]; then
      start_commit="$(select_commit --prompt "Select the oldest commit> " --select "$end_commit")"
    fi
    if [ -n "$start_commit" -a -n "$end_commit" ]; then
      select_commit "$start_commit~1..$end_commit"
    fi
  else
    select_commit $commit
  fi
}
