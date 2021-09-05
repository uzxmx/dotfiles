usage_decode() {
  cat <<-EOF
Usage: protoc decode <file>

Decode protocol message.
EOF
  exit 1
}

cmd_decode() {
  source "$dotfiles_dir/scripts/lib/tmpfile.sh"

  local tmpfile
  create_tmpfile tmpfile
  xxd -r -p "$1" "$tmpfile"
  protoc --decode_raw <"$tmpfile"
}
alias_cmd d decode
