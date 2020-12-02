# Hook that zsh will invoke when a command cannot be found.
command_not_found_handler() {
  local name="$1"
  echo "Oops, command '$name' not found."
  echo -n "Would you like me to try to install it? (Y/n)"
  local input
  read input
  if ! [ -z "$input" -o "$input" = "Y" -o "$input" = "y" ]; then
    echo Cancelled.
    exit
  fi

  case "$name" in
    dig | whois | tcpdump | route)
      ~/.dotfiles/scripts/install/network_tools
      ;;
    *)
      echo "Cannot install it automatically, please do it by yourself."
      exit 1
      ;;
  esac
  echo 'Installed successfully.'
}
