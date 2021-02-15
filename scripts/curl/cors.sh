usage_cors() {
  cat <<-EOF
Usage: curl cors <test-url> <origin>

Test if the remote resource specified by <test-url> allows the browser to
visit from the <origin>.

CORS is checked by using OPTIONS method. When it is allowed, the HTTP
header 'Access-Control-Allow-Origin' and 'Access-Control-Allow-Methods'
will be present.

The <test-url> may be a non-existent remote resource, and it still returns
'200 OK' when CORS is allowed.

Example:
  $> curl cors http://example.com http://foo.example.com
EOF
  exit 1
}

cmd_cors() {
  local url="$1"
  local origin="$2"
  if [ -z "$url" -o -z "$origin" ]; then
    usage_cors
  fi

  source ~/.dotfiles/scripts/lib/utils/common.sh
  source ~/.dotfiles/scripts/lib/io.sh
  source ~/.dotfiles/scripts/lib/utils/trim.sh

  local output
  io_run_capture_and_display output curl "$url" -H "Origin: $origin" -XOPTIONS -I -s

  echo -e "----\n"

  source "$dotfiles_dir/scripts/lib/gsed.sh"
  local allowed_origin="$(str_trim "$(echo "$output" | grep -i Access-Control-Allow-Origin | "$SED" 's/^access-control-allow-origin:[[:space:]]*//i')")"
  if [ "$allowed_origin" = "$origin"  ]; then
    echo -n 'CORS is allowed with such methods: '
    str_trim "$(echo "$output" | grep -i Access-Control-Allow-Methods | "$SED" 's/^access-control-allow-methods:[[:space:]]*//i')"
  else
    echo 'CORS is NOT allowed.'
  fi
}
