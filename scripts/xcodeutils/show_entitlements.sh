usage_show_entitlements() {
  cat <<-EOF
Usage: xcodeutils show_entitlements <app-path>

Show entitlements of an IPA file. You need to unzip the IPA file first, and
then pass in the path to the app in Payload.

Example:
  $> xcodeutils show_entitlements Payload/foo.app
EOF
  exit 1
}

cmd_show_entitlements() {
  if [ -z "$1" -o ! -d "$1" ]; then
    echo 'You should pass in a valid path.'
    exit 1
  fi

  codesign -d --entitlements :- "$1"
}
