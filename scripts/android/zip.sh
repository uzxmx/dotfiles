usage_zip() {
  cat <<-EOF
Usage: android zip [flavor]...

Options:
  -f select one or more flavors to zip by fzf
EOF
  exit 1
}

cmd_zip() {
  local srcdir="build/outputs/apk"
  [ ! -d "$srcdir" ] && \
    echo -e -n "Cannot find $srcdir directory." \
      "Please make sure you're in a correct working directory and have built the apk." \
    && exit 1

  local flavors select_flavor
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -f)
        select_flavor=1
        ;;
      -*)
        usage_zip
        ;;
      *)
        flavors="$1\n$flavors"
        ;;
    esac
    shift
  done

  local old_pwd="$(pwd)"
  cd "$srcdir"

  ls_apks() {
    find . -type f -maxdepth 3 -path "./*/release/*.apk"
  }

  parse_flavor() {
    sed "s:^\./\([^/]*\).*$:\1:"
  }

  if [ -n "$select_flavor" ]; then
    flavors="$(ls_apks | parse_flavor | fzf -m --prompt "Select flavors> ")"
  fi

  local tmpdir="$(mktemp -d)"
  handle_exit() {
    [ -e "$tmpdir" ] && rm -rf "$tmpdir"
  }
  trap handle_exit EXIT
  local apks_dir="$tmpdir/apks"

  local apk
  while read apk; do
    local dir="$(dirname "$apk")"
    if [ -n "$flavors" ]; then
      local flavor="$(echo "$apk" | parse_flavor)"
      if ! echo "$flavors" | grep -Fx "$flavor" &>/dev/null; then
        continue
      fi
    fi
    mkdir -p "$apks_dir/$dir"
    cp "$apk" "$apks_dir/$dir"
  done < <(ls_apks)

  cd "$apks_dir/.."
  zip -r "$old_pwd/apks.zip" apks
}
