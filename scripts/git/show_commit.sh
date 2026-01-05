usage_show_commit() {
  cat <<-EOF 1>&2
Usage: g show_commit <commit>

Show files of a commit by fzf and tmux.

Options:
  -d <another-commit> see what have changed from <another-commit> to <commit>
EOF
  exit 1
}

cmd_show_commit() {
  local commit another_commit
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d)
        shift
        another_commit="$1"
        ;;
      -*)
        usage_show_commit
        ;;
      *)
        commit="$1"
        ;;
    esac
    shift
  done

  [ -z "$commit" ] && echo 'A commit is required.' && exit 1

  local cmd preview_cmd
  local edit_cmd="git show $commit --first-parent --pretty='' -- {2} | vi"
  if [ -z "$another_commit" ]; then
    cmd=(git show "$commit" --first-parent --pretty="" --name-status)
    preview_cmd="git show $commit --first-parent --pretty='' --color=always -- {2} | less -r"
  else
    cmd=(git diff "$another_commit" "$commit" --name-status)
    preview_cmd="git diff --color=always $another_commit $commit -- {2} | less -r"
  fi

  local preview_window
  if [ "$(tput cols)" -ge 160 ]; then
    preview_window="right"
  else
    preview_window="bottom"
  fi

  cd "$(git rev-parse --show-toplevel)"

  "${cmd[@]}" | fzf --no-mouse --cycle \
    --layout=reverse \
    --prompt="C-O:edit> " \
    --preview="$preview_cmd" \
    --preview-window="$preview_window:50%:wrap" \
    --bind "ctrl-o:execute(tmux split-window \"$edit_cmd\")"
}
