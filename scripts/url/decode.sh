usage_decode() {
  cat <<-EOF
Usage: url decode [data]

URL decode.

Options:
  -f <file> Decode data in a file
EOF
  exit 1
}

cmd_decode() {
  local data file
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -f)
        shift
        file="$1"
        ;;
      -*)
        usage_decode
        ;;
      *)
        data="$1"
        ;;
    esac
    shift
  done

  if [ -n "$file" ]; then
    ruby -e "require 'uri'; puts URI.decode_www_form_component(File.read('$file'))"
  elif [ -n "$data" ]; then
    ruby -e "require 'uri'; puts URI.decode_www_form_component('$data')"
  else
    usage_decode
  fi
}
alias_cmd d decode
