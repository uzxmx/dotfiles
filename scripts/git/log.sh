usage_l() {
  cat <<-EOF
Usage: g l [commit]

Enhanced log utility by fzf.

Options:
  -r, --range use range mode. This will ask you to select a start and end commit.
  -f Show a file history. This will ask you to select a file by fzf.

Commit format:
  commit1..commit2: This will show you commits that can be reached from
                    commit2, but not from commit1. (a.k.a between)

Examples:
  $> g l -f
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
    fzf_opts+=(--bind "ctrl-s:execute-silent(tmux display-popup -d '#{pane_current_path}' -T \" Squashed diff($another_commit..\$(echo {1})) \" -w 90% -h 90% -E \"$DOTFILES_DIR/bin/g show_commit {1} -d \"$another_commit\"\")")
  fi

  local preview_window
  if [ "$(tput cols)" -ge 160 ]; then
    preview_window="right"
  else
    preview_window="bottom"
  fi

  local selection="$(git log --first-parent --pretty="format:%h %<(30,trunc)%s %ai %an %d" "${remainder[@]}" \
    | fzf --no-mouse --cycle \
    --layout=reverse \
    --prompt="${prompt:-"$default_prompt> "}" \
    --preview="git show {1} --first-parent --pretty='commit %H%d%nParent: %p%nAuthor: %an%nDate:   %ai%n%n%w(0,4,4)%B%-' --name-status" \
    --preview-window="$preview_window:50%:wrap" \
    --bind=f1:top \
    --bind "ctrl-y:execute-silent(echo -n {1} | trim | cb && tmux display-message yanked)" \
    --bind "ctrl-v:execute-silent(tmux display-popup -d '#{pane_current_path}' -T \" \$(git log {1} -1 --oneline) \" -w 90% -h 90% -E \"tmux new-session 'tmux set status off && $DOTFILES_DIR/bin/g show_commit {1}'\")" \

    "${fzf_opts[@]}"
  )"
  if [ "$select" = "1" ]; then
    echo "$selection" | awk '{print $1}'
  fi
}

show_history_for_file() {
  local file="$1"
  local default_prompt="F1:newest-commit CTRL-Y:yank-commit CTRL-V:show-commit"

  local preview_window
  if [ "$(tput cols)" -ge 160 ]; then
    preview_window="right"
  else
    preview_window="bottom"
  fi

  local selection="$(git log --first-parent --pretty="format:%h %<(30,trunc)%s %ai %an %d" -- "$file" \
    | fzf --no-mouse --cycle \
    --layout=reverse \
    --prompt="${default_prompt}>" \
    --preview="git show {1} --first-parent --pretty='' --color=always -- \"$file\" | less -r" \
    --preview-window="$preview_window:50%:wrap" \
    --bind=f1:top \
    --bind "ctrl-y:execute-silent(echo -n {1} | trim | cb && tmux display-message yanked)" \
    --bind "ctrl-v:execute-silent(tmux display-popup -d '#{pane_current_path}' -T \" \$(git log {1} -1 --oneline) \" -w 90% -h 90% -E \"tmux new-session 'tmux set status off && $DOTFILES_DIR/bin/g show_commit {1}'\")"
  )"
}

cmd_l() {
  local range_mode commit show_file_history
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -r | --range)
        range_mode=1
        ;;
      -f)
        show_file_history=1
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
  elif [ "$show_file_history" = "1" ]; then
    local file=$(fe --print)
    if [ -n "$file" ]; then
      show_history_for_file "$file"
    fi
  else
    local commit="$(select_commit --select $commit)"
    if [ -n "$commit" ]; then
      source "$DOTFILES_DIR/scripts/lib/prompt.sh"
      [ "$(yesno "Checkout $commit? (Y/n)" "yes")" = "no" ] && echo "Cancelled" && exit
      git checkout "$commit"
    fi
  fi
}
