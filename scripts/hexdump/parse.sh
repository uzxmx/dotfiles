usage_parse() {
  cat <<-EOF
Usage: hd parse [in-file]

By default, parse hexadecimal string to its binary format. Specify '-r' option
to convert a file or a string to its hexadecimal string format.

Pipe is supported in both modes.

Common options:
  -s <str> Input string
  -r Convert a file or a string to its hexadecimal string format

Options for non-reverse mode:
  --reverse-continuous-bytes-order Reverse continuous bytes order. Continuous
                                   means two bytes not separated by a punctuation or line break.
                                   This is useful when dealing with endianness.

Options for reverse mode:
  -f <format> output format, provided formats include squeezed/separated/decimal/oct.
              (squeezed: 616263)
              (separated: 0x61, 0x62, 0x63)
              (decimal: 97, 98, 99)
              (oct: 141, 142, 143)
              You can also specify a custom format, see hexdump manual.
  --space combined with '-f' option to make the output to be space-separated.

Examples:
  # Convert hexadecimal string to binary format.
  hd p -s 616263
  echo -n 616263 | hd p

  # Convert string to hexadecimal string format.
  hd p -s abc -r

  # Convert string input through pipe to hexadecimal string format.
  echo -n abc | hd p -r

  # Convert a text file to hexadecimal string format.
  hd p -r foo.txt

  # Convert a binary file to hexadecimal string format.
  hd p -r bar.bin
EOF
  exit 1
}

cmd_parse() {
  local reverse_mode input_str infile
  local reverse_continuous_bytes_order
  local format="squeezed"
  local separator=", "
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -s)
        shift
        input_str="$1"
        ;;
      -r)
        reverse_mode=1
        ;;
      --reverse-continuous-bytes-order)
        reverse_continuous_bytes_order=1
        ;;
      -f)
        shift
        format="$1"
        ;;
      --space)
        separator=" "
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
    case "$format" in
      squeezed)
        format='16/1 "%02x"'
        ;;
      separated)
        format='"0x" 1/1 "%02x" '"\"$separator\""
        ;;
      decimal)
        format='"" 1/1 "%d" '"\"$separator\""
        ;;
      oct)
        format='"" 1/1 "%o" '"\"$separator\""
        ;;
    esac

    if [ ! -t 0 ]; then
      hexdump -v -e "$format"
    else
      if [ -n "$input_str" ]; then
        echo -n "$input_str" | hexdump -v -e "$format"
      else
        if [ -z "$infile" ]; then
          abort "A file is required."
        fi
        if [ ! -e "$infile" ]; then
          abort "File $infile does not exist."
        fi
        hexdump -v -e "$format" "$infile"
      fi
    fi
    echo
  else
    if [ ! -t 0 ]; then
      if [ "$reverse_continuous_bytes_order" = "1" ]; then
        go run "$hexdump_dir/reverse_continuous_bytes_order.go"
      else
        xxd -r -p
      fi
    else
      if [ -n "$input_str" ]; then
        if [ "$reverse_continuous_bytes_order" = "1" ]; then
          echo "$input_str" | go run "$hexdump_dir/reverse_continuous_bytes_order.go"
        else
          echo "$input_str" | xxd -r -p
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
  fi
}
alias_cmd p parse
