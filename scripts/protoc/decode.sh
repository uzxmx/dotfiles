usage_decode() {
  cat <<-EOF
Usage: protoc decode <data-file>

Decode protocol message. The data file can be either a binary file, or a file
containing hexadecimal text.

Optionally, you can specify a message file and a message type to decode the
data to a message.

Options:
  -p <proto_file> proto message definition file
  -t <message_type> proto message type
EOF
  exit 1
}

cmd_decode() {
  local proto_file message_type data_file
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -p)
        shift
        proto_file="$1"
        ;;
      -t)
        shift
        message_type="$1"
        ;;
      -*)
        usage_decode
        ;;
      *)
        data_file="$1"
        ;;
    esac
    shift
  done

  # The data file seems not a binary file, we try to convert it to binary file first.
  if [ ! "$(file -b "$data_file")" = "data" ]; then
    source "$dotfiles_dir/scripts/lib/tmpfile.sh"
    local tmpfile
    create_tmpfile tmpfile
    xxd -r -p "$data_file" "$tmpfile"
    data_file="$tmpfile"
  fi

  if [ -n "$proto_file" ]; then
    if [ -z "$message_type" ]; then
      message_type="$(basename "$proto_file" | sed 's/\..*$//')"
      echo -n "Infer message type from proto file: " >&2
      echo "$message_type"
    fi
    local include_dir="$(dirname "$proto_file")"
    echo "Infer proto include path: $include_dir" >&2

    cat "$data_file" | protoc -I "$include_dir" "$proto_file" --decode="$message_type"
  else
    protoc --decode_raw <"$data_file"
  fi
}
alias_cmd d decode
