usage_d() {
  cat <<-EOF 1>&2
Usage: g d

Enhanced diff utility by fzf.

Options:
  -c, --cached show staged changes
EOF
  exit 1
}

cmd_d() {
  local opts=()
  local cached
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -c | --cached)
        opts+=(--cached)
        cached=1
        ;;
    esac
    shift
  done

  if [ -z "$cached" ]; then
    # Record the fact that the path will be added later, so it can show new
    # files when executing `git diff`.
    (cd "$(git rev-parse --show-toplevel)" && git add -N .)
  fi

  local cmd=(git diff "${opts[@]}" --name-status)
  local preview_cmd="git diff ${opts[*]} --color=always -- {2} | less -r"
  local edit_cmd="${EDITOR:-vi} {2}"
  local output="$("${cmd[@]}")"
  if [ -z "$output" ]; then
    echo 'No changes found.'
  else
    fzf --no-mouse --cycle \
      --layout=reverse \
      --prompt="CTRL-V:diff-file CTRL-O:open-file CTRL-S:stage-file> " \
      --preview="$preview_cmd" \
      --preview-window="right:50%:wrap" \
      --bind "ctrl-v:execute(tmux new-window \"$preview_cmd\")" \
      --bind "ctrl-o:execute(tmux new-window \"$edit_cmd\")" \
      --bind "ctrl-s:execute-silent(git add {2})" \
      <<<"$output"
  fi
}
