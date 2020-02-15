# We don't actually need `~/.zshenv` file. Because in most cases, non-interactive shells are
# launched from interactive shell, so they inherite exported shell variables from parent
# shell. We only need to export variables in `~/.zshrc`, they will be propagated into sub
# non-interactive shells.

[[ -f ~/.zshenv.pre.local ]] && source ~/.zshenv.pre.local
