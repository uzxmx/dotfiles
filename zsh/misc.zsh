# Hook that zsh will invoke when a command cannot be found.
command_not_found_handler() {
  local name="$1"
  echo "Oops, command '$name' not found."

  ask() {
    echo -n "Would you like me to install it for you? (Y/n)"
    local input
    read input
    if ! [ -z "$input" -o "$input" = "Y" -o "$input" = "y" ]; then
      echo Cancelled.
      exit
    fi
  }

  case "$name" in
    dig | whois | tcpdump | route)
      ask
      "$DOTFILES_DIR/scripts/install/network_tools"
      ;;
    *)
      echo "Sorry, I couldn't help to install it, please do it by yourself."
      echo "Please also consider whether to update 'command_not_found_handler' so I could do it for you later."
      exit 1
      ;;
  esac
  echo 'Installed successfully.'
}
