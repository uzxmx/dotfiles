usage_build() {
  cat <<-EOF
Usage: android build [flavor]...

Build apks by using gradle wrapper script inside current project. You can build
one or more flavors. When no argument is specified, it builds all flavors.

When ANDROID_STUDIO_JAVA_HOME or ANDROID_STUDIO_HOME is set, it uses the Java
which is bundled with android studio.

Options:
  -f select one or more flavors to build by fzf
EOF
  exit 1
}

cmd_build() {
  source "$dotfiles_dir/scripts/lib/utils.sh"
  source "$dotfiles_dir/scripts/lib/utils/find.sh"
  local gradle_bin="$(find_file_hierarchical gradlew)"

  [ -z "$gradle_bin" ] && echo 'Cannot find gradle wrapper.' && exit 1

  local flavors select_flavor
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -f)
        select_flavor=1
        ;;
      -*)
        usage_build
        ;;
      *)
        flavors="$1\n$flavors"
        ;;
    esac
    shift
  done

  if [ -n "$select_flavor" ]; then
    flavors="$("$dotfiles_dir/bin/gradle" android showFlavors -q 2>/dev/null)"
    flavors="$(echo "$flavors" | fzf -m --prompt "Select flavors> ")"
  fi

  local -a args
  if [ -z "$flavors" ]; then
    args=(build)
  else
    local flavor
    while read flavor; do
      [ -z "$flavor" ] && continue
      args+=("assemble${flavor^}")
    done < <(echo -e "$flavors")
  fi

  # Update JAVA_HOME to the one bundled with android studio.
  if [ -n "$ANDROID_STUDIO_JAVA_HOME" ]; then
    JAVA_HOME="$ANDROID_STUDIO_JAVA_HOME"
  elif [ -n "$ANDROID_STUDIO_HOME" ]; then
    if is_mac; then
      JAVA_HOME="$ANDROID_STUDIO_HOME/Contents/jre/jdk/Contents/Home"
    else
      JAVA_HOME="$ANDROID_STUDIO_HOME/jre"
    fi
  fi

  if ! is_wsl; then
    export JAVA_HOME
    "$gradle_bin" "${args[@]}"
    exit
  fi

  local wslpath_bin="$dotfiles_dir/bin/wslpath"

  # For WSL, we need to use `cmd.exe' to build, otherwise it may fail with android build tools not found.
  # Note: the parenthesis here is very important. Once removed, the whitespace around `&' should also be removed, otherwise the JAVA_HOME will contain a trailing whitespace.
  cmd.exe /c "(set JAVA_HOME=$("$wslpath_bin" -w $JAVA_HOME)) & $("$wslpath_bin" -w "$gradle_bin")" "${args[@]}"
}
