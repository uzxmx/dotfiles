usage_parse() {
  cat <<-EOF
Usage: hexdump parse [in-file]

By default, parse hexadecimal string to binary. Specify '-r' option to do the
reverse.

Options:
  -s <hex-str> Hexadecimal string
  -r Parse binary to hexadecimal string
EOF
  exit 1
}

cmd_parse() {
  local reverse_mode hex_str infile
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -s)
        shift
        hex_str="$1"
        ;;
      -r)
        reverse_mode=1
        ;;
      -*)
        usage_parse
        ;;
      *)
        infile="$1"
        ;;
    esac
    shift
  done

  if [ "$reverse_mode" = "1" ]; then
    if [ -z "$infile" ]; then
      abort "A binary file is required."
    fi
    if [ ! -e "$infile" ]; then
      abort "File $infile does not exist."
    fi
    hexdump -e '16/1 "%02x"' "$infile"
    echo
  else
    if [ -n "$hex_str" ]; then
      echo "$hex_str" | xxd -r -p
    else
      if [ -z "$infile" ]; then
        abort "An input file is required or a hexadecimal string should be specified by '-s'."
      fi
      if [ ! -e "$infile" ]; then
        abort "File $infile does not exist."
      fi
      xxd -r -p "$infile"
    fi
  fi
}
alias_cmd p parse
