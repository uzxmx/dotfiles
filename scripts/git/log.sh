usage_l() {
  cat <<-EOF
Usage: g l [commit]

Enhanced log utility by fzf.

Options:
  -r, --range use range mode. This will ask you to select a start and end commit.
  -f [file] Show a file history. If no file is given, it will ask you to select a file by fzf.
  -D Select a deleted file by fzf.

Commit format:
  commit1..commit2: This will show you commits that can be reached from
                    commit2, but not from commit1. (a.k.a between)

Examples:
  $> g l -f -D
  $> g l -f path/to/file.txt
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

  local default_prompt="C-T:top C-G:go-to C-Y:yank-commit C-V:show-commit"
  local fzf_opts=()
  if [ -n "${remainder[0]}" ] && [[  "${remainder[0]}" =~ .+\.\..+ ]]; then
    default_prompt="$default_prompt CTRL-S:squash-diff"
    local another_commit="$(echo "${remainder[0]}" | awk -F. '{print $1}')"
    fzf_opts+=(--bind "ctrl-s:execute-silent(tmux display-popup -d '#{pane_current_path}' -T \" Squashed diff($another_commit..\$(echo {2})) \" -w 90% -h 90% -E \"$DOTFILES_DIR/bin/g show_commit {2} -d \"$another_commit\"\")")
  fi

  local preview_window
  if [ "$(tput cols)" -ge 160 ]; then
    preview_window="right"
  else
    preview_window="bottom"
  fi

  local pos=1
  while true; do
    local selection="$(git log --first-parent --pretty="format:%h %<(30,trunc)%s %ai %an %d" "${remainder[@]}" \
      | cat -n \
      | fzf --no-mouse --cycle \
      --with-nth 2.. \
      --layout=reverse \
      --prompt="${prompt:-"$default_prompt> "}" \
      --preview="git show {2} --first-parent --pretty='commit %H%d%nParent: %p%nAuthor: %an%nDate:   %ai%n%n%w(0,4,4)%B%-' --name-status" \
      --preview-window="$preview_window:50%:wrap" \
      --bind "load:pos($pos)" \
      --bind "ctrl-t:top" \
      --bind "ctrl-g:execute(echo -n pos:{1})+abort" \
      --bind "ctrl-y:execute-silent(echo -n {2} | $DOTFILES_DIR/bin/trim | $DOTFILES_DIR/bin/cb && tmux display-message yanked)+abort" \
      --bind "ctrl-v:execute-silent(tmux display-popup -d '#{pane_current_path}' -T \" \$(git log {2} -1 --oneline) \" -w 90% -h 90% -E \"tmux new-session 'tmux set status off && $DOTFILES_DIR/bin/g show_commit {2}'\")" \

      "${fzf_opts[@]}"
    )"
    if [[ "$selection" == pos:* ]]; then
      pos="$(echo "$selection" | awk -F: '{print $2}')"
      continue
    fi
    if [ "$select" = "1" ]; then
      echo "$selection" | awk '{print $2}'
    fi
    break
  done
}

show_history_for_file() {
  local file="$1"
  local default_prompt="C-T:top C-Y:yank-commit C-V:show-commit"

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
    --bind "ctrl-t:top" \
    --bind "ctrl-y:execute-silent(echo -n {1} | $DOTFILES_DIR/bin/trim | $DOTFILES_DIR/bin/cb && tmux display-message yanked)+abort" \
    --bind "ctrl-v:execute-silent(tmux display-popup -d '#{pane_current_path}' -T \" \$(git log {1} -1 --oneline) \" -w 90% -h 90% -E \"tmux new-session 'tmux set status off && $DOTFILES_DIR/bin/g show_commit {1}'\")"
  )"
}

cmd_l() {
  local range_mode arg show_file_history select_deleted_file
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -r | --range)
        range_mode=1
        ;;
      -f)
        show_file_history=1
        ;;
      -D)
        select_deleted_file=1
        ;;
      -*)
        usage_l
        ;;
      *)
        arg="$1"
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
    local file="$arg"
    if [ -z "$file" ]; then
      if [ -z "$select_deleted_file" ]; then
        file="$("$DOTFILES_DIR/bin/fe" --print)"
      else
        file="$(git log --diff-filter=D --summary | grep 'delete mode ' | awk '{print $NF}' | fzf)"
      fi
    fi
    if [ -n "$file" ]; then
      show_history_for_file "$file"
    fi
  else
    local commit="$(select_commit --select $arg)"
    if [ -n "$commit" ]; then
      source "$DOTFILES_DIR/scripts/lib/prompt.sh"
      [ "$(yesno "Checkout $commit? (Y/n)" "yes")" = "no" ] && echo "Cancelled" && exit
      git checkout "$commit"
    fi
  fi
}
