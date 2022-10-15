usage_open() {
  cat <<-EOF
Usage: android-studio open [project-dir]

Open a project specified by a directory, or current working directory if no
argument is specified.
EOF
  exit 1
}

cmd_open() {
  if is_mac; then
    open -a "/Applications/Android Studio.app" "$1"
  else
    abort "Unsupported system."
  fi
}
alias_cmd o open
