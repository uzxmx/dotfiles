run_lldb() {
  local lldbinit_post
  if [ -f lldbinit.post ]; then
    lldbinit_post="$(cat lldbinit.post)"
  fi

  local lldb_commands="$(cat <<EOF
command script import $dotfiles_dir/lldb_extra
$(
  for file in $(find $dotfiles_dir/lldb_extra/commands -name 'cmd_*.py'); do
    echo "command script import $file"
  done
)
$before_lldbinit_post_hook
$lldbinit_post
$after_lldbinit_post_hook
EOF
)"

  lldb -s <(echo "$lldb_commands") "$@"
}

common_help() {
  cat <<EOF
This script also imports 'lldb_extra' directory in this dotfiles repo to
PYTHONPATH, so you can use anything provided by 'lldb_extra' when you're in the
python interpreter.

You can put lldb commands in a file named as 'lldbinit.post' in current working
directory, it will be loaded when the program stops at the entrypoint.

If a binary cannot be attached or debugged, you may need to disable SIP (System
Integrity Protection) or remove code signature from that binary (see
'xcodeutils unsign'). Visit https://security.stackexchange.com/a/232914 for
more information.
EOF
}
