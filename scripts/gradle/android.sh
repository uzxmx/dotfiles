usage_android() {
  cat <<-EOF
Usage: gradle android

Android related utilities. For other utilities, please refer to android command
inside dotfiles bin directory.

Subcommands:
  showFlavors - show flavors
EOF
  exit 1
}

cmd_android() {
  local cmd="$1"
  case "$cmd" in
    showFlavors)
      shift
      run_task android.gradle "$cmd" "$@"
      ;;
    *)
      usage_android
      ;;
  esac
}
