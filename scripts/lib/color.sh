#!/bin/sh

color_set() {
  local color="$1"
  shift
  local num
  case "$color" in
    black)
      num=0
      ;;
    red)
      num=1
      ;;
    green)
      num=2
      ;;
    yellow)
      num=3
      ;;
    blue)
      num=4
      ;;
    magenta)
      num=5
      ;;
    cyan)
      num=6
      ;;
    white)
      num=7
      ;;
  esac
  echo -n "$(tput setaf $num)"
}

color_reset() {
  echo -n "$(tput sgr 0)"
}

# Show output with color.
#
# @params:
#   $1: color
#   VARARGS: variable arguments that need to output
#
# @ref http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
# @ref https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#
# @example
#    color_output red foo
#    echo "$(color_output red foo)$(color_output cyan foo)"
color_output() {
  local color="$1"
  shift
  # Set foreground color at the beginningg and reset at the end.
  echo "$(color_set "$color")$@$(color_reset)"
}

info() {
  echo "$@"
}

warn() {
  color_output yellow "$@"
}

error() {
  echo -e "\u274c $(color_output red "$@")"
}

success() {
  echo -e "\u2705 $(color_output green "$@")"
}

# Output error message to stderr, and exit.
abort() {
  # Here if we use /dev/stderr, nvim on WSL may raise error '/dev/stderr: no such device or address' when executing a job.
  error "$@" >&2

  exit 1
}
