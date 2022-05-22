# We don't actually need `$DOTFILES_TARGET_DIR/.zshenv` file. Because in most cases, non-interactive shells are
# launched from interactive shell, so they inherite exported shell variables from parent
# shell. We only need to export variables in `$DOTFILES_TARGET_DIR/.zshrc`, they will be propagated into sub
# non-interactive shells.

[ -f "$DOTFILES_TARGET_DIR/.zshenv.pre.local" ] && source "$DOTFILES_TARGET_DIR/.zshenv.pre.local"
