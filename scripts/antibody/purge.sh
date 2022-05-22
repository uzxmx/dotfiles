usage_purge() {
  cat <<-EOF
Usage: antibody purge [-s]

Purge antibody plugins.

Options:
  [-s] Synchronize bundle with plugins.txt to remove unused plugin
EOF
  exit 1
}

cmd_purge() {
  local sync list current
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -s)
        sync=1
        ;;
      *)
        usage
        ;;
    esac
    shift
  done

  if [ -z "$sync" ]; then
    list="$(antibody list | awk '{ print $1 }' | fzf -m --bind ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all)"
  else
    current="$(cat "$DOTFILES_DIR/zsh/plugins.txt" | sed -e '/^#.*/d' | sed -e '/^$/d' | awk '{ print $1 }')"
    list="$(antibody list | awk '{ print $1 }' | grep -F -v "$current" || true)"
  fi
  for i in $list; do
    antibody purge "$i"
  done
}
