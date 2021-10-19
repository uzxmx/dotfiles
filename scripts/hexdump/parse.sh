usage_parse() {
  cat <<-EOF
Usage: hexdump parse [in-file]

By default, parse hexadecimal string to binary. Specify '-r' option to do the
reverse.

Options:
  -s <hex-str> Hexadecimal string
  -r Parse binary to hexadecimal string
  --reverse-continuous-bytes-order Reverse continuous bytes order. Continuous
                                   means two bytes not separated by a punctuation or line break.
                                   This is useful when dealing with endianness.
EOF
  exit 1
}

cmd_parse() {
  local reverse_mode hex_str infile
  local reverse_continuous_bytes_order
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -s)
        shift
        hex_str="$1"
        ;;
      -r)
        reverse_mode=1
        ;;
      --reverse-continuous--bytes-order)
        reverse_continuous_bytes_order=1
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
      if [ "$reverse_continuous_bytes_order" = "1" ]; then
        echo "$hex_str" | go run "$hexdump_dir/reverse_continuous_bytes_order.go"
      else
        echo "$hex_str" | xxd -r -p
      fi
    else
      if [ -z "$infile" ]; then
        abort "An input file is required or a hexadecimal string should be specified by '-s'."
      fi
      if [ ! -e "$infile" ]; then
        abort "File $infile does not exist."
      fi
      if [ "$reverse_continuous_bytes_order" = "1" ]; then
        go run "$hexdump_dir/reverse_continuous_bytes_order.go" "$infile"
      else
        xxd -r -p "$infile"
      fi
    fi
  fi
}
alias_cmd p parse
