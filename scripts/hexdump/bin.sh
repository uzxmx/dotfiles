usage_bin() {
  cat <<-EOF
Usage: hexdump bin <integer>

Display the input integer in binary/hex.

Options:
  -x Display in hex

Example:
  $> hexdump bin 255
  $> hexdump bin -x 65536
EOF
  exit 1
}

cmd_bin() {
  local remainder=()
  local format="%b"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -x)
        format="%x"
        ;;
      -*)
        usage_bin
        ;;
      *)
        remainder+=("$1")
        ;;
    esac
    shift
  done

  set - "${remainder[@]}"

  [ "$#" -eq 0 ] && usage_bin
  for i in "$@"; do
    perl -e "printf \"$format\n\", $i"
  done
}
