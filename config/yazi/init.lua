-- Plugins are declared in package.toml and installed by `ya pkg install`.

require("full-border"):setup()
require("git"):setup()
-- Include hidden files like the `s` keymap, but skip .git.
-- The bat preview is hidden by default for speed; ctrl-/ toggles it.
require("fr"):setup({
  rg = "--hidden --glob '!.git'",
  fzf = "--preview-window=hidden --bind='ctrl-/:toggle-preview'",
})
