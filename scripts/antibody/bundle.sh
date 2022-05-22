usage_bundle() {
  cat <<-EOF
Usage: antibody bundle

Download plugins and save zsh settings to $DOTFILES_TARGET_DIR/.zsh_plugins.sh.

Notes:

After changing plugins branch, you must execute 'antibody purge' to remove caches, and then
bundle again.

The command 'antibody update' pulls new commits from remote, so if you've specified a branch
in plugins.txt, you won't want to run 'antibody update' command.
EOF
  exit 1
}

cmd_bundle() {
  "$DOTFILES_DIR/bin/antibody" purge -s &>/dev/null
  antibody bundle <"$DOTFILES_DIR/zsh/plugins.txt" >"$DOTFILES_TARGET_DIR/.zsh_plugins.sh"
}
