usage_d() {
  cat <<-EOF 1>&2
Usage: g d [commit1] [commit2] [--] [<path>...]

Enhanced diff utility by fzf. By default it shows the diffs between the HEAD
and the working tree (what changes have been done from the HEAD).

When only commit1 is given, it compares commit1 with the working tree (what
changes have been done from commit1 to the working tree). If you want to
reverse the comparison, use -R.

When both commit1 and commit2 are given, it compares the commit1 with the
commit2 (what changes have been done from commit1 to commit2).

When a commit is given, fzf mode is used by default.

Options:
  -c, --cached show staged changes
  -f, --fzf use fzf mode
  -n | --no-fzf don't use fzf mode
  -R reverse the comparison (show differences from index or on-disk file to tree contents)
EOF
  exit 1
}

cmd_d() {
  local opts=()
  local fzf_mode=1
  local double_dash
  local commits=()
  local paths=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -c | --cached)
        opts+=(--cached)
        ;;
      -f | --fzf)
        fzf_mode=1
        ;;
      -n | --no-fzf)
        fzf_mode=0
        ;;
      -R)
        opts+=(-R)
        ;;
      --)
        double_dash=1
        ;;
      -*)
        usage_d
        ;;
      *)
        if [ "$double_dash" = "1" ]; then
          paths+=("$1")
        else
          if [ -n "$(git rev-parse -q --verify "$1" || true)" ]; then
            if [ -e "$1" ]; then
              echo "Warning: $1 is ambiguous to be a commit or a path. We identify it as a commit by default. If it's a path, please specify it after -- option."
            fi
            commits+=("$1")
          else
            paths+=("$1")
          fi
        fi
        ;;
    esac
    shift
  done

  if [ -z "$fzf_mode" -a "${#commits[@]}" -gt 0 ]; then
    fzf_mode=1
  fi

  [ "$fzf_mode" = "1" ] || exec git diff "${opts[@]}" "${commits[@]}" "${paths[@]}"

  local cmd=(git diff "${opts[@]}" --name-status "${commits[@]}" "${paths[@]}")
  local preview_cmd="git diff ${opts[*]} "${commits[@]}" --color=always -- {2} | less -r"
  local edit_cmd="${EDITOR:-vi} +'map q :q<enter>' {2}"

  source "$DOTFILES_DIR/scripts/lib/utils/common.sh"
  source "$DOTFILES_DIR/scripts/lib/fzf.sh"
  local query
  while true; do
    unset result

    local output="$("${cmd[@]}")"
    if [ -z "$output" ]; then
      echo "No changes found."
      break
    else
      # Because `git diff` shows files relative to the git root, so if we are not in
      # the git root, preview or bind command may fail to find the file. To resolve this,
      # we change to the git root first.
      local old_dir="$(pwd)"
      cd "$(git rev-parse --show-toplevel)"
      call_fzf result --no-mouse --cycle \
        --query="$query" --print-query \
        --layout=reverse \
        --prompt="C-V:diff-file C-O:open-file C-S:stage-file Enter:edit> " \
        --preview="$preview_cmd" \
        --preview-window="right:50%:wrap" \
        --bind "ctrl-v:execute(tmux new-window \"$preview_cmd\")" \
        --bind "ctrl-o:execute(tmux new-window \"$edit_cmd\")" \
        --expect "ctrl-s" \
        <<<"$output"

      [ -z "${result[*]}" ] && break

      query="${result[0]}"
      local key="${result[1]}"
      local selection="${result[2]}"
      local file="$(echo "$selection" | awk '{print $2}')"

      case "$key" in
        ctrl-s)
          git add "$file"
          ;;
        "")
          ${EDITOR:-vi} "$file"
          exit
          ;;
      esac

      cd "$old_dir"
    fi
  done
}
