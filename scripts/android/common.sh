list_avds() {
  emulator -list-avds
}

select_avd() {
  list_avds | fzf
}
