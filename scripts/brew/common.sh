select_package() {
  (brew list --formula -1; brew list --cask -1) | fzf --prompt "Select a package: "
}
