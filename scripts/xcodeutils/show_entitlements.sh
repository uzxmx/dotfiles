usage_show_entitlements() {
  cat <<-EOF
Usage: xcodeutils show_entitlements <app-path> | <executable-file>

Show entitlements of an executable or IPA file. For IPA file, you need to unzip
the IPA file first, and then pass in the path to the app in Payload.

Example:
  $> xcodeutils show_entitlements Payload/foo.app
EOF
  exit 1
}

cmd_show_entitlements() {
  codesign -d --entitlements :- "$1"
}
