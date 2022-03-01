run_gdb() {
  local gdbinit_post
  if [ -f gdbinit.post ]; then
    gdbinit_post="$(cat gdbinit.post)"
  fi

  local gdb_commands="$(cat <<EOF
$(
  for file in $(find $dotfiles_dir/gdb_extra/commands -name 'cmd_*.py'); do
    echo "source $file"
  done
)

$before_gdbinit_post_hook
$gdbinit_post
$after_gdbinit_post_hook
EOF
)"

  # Process substitution doesn't work, so we use a temporary file.
  # gdb -x <(echo "$gdb_commands") "$@"

  source "$dotfiles_dir/scripts/lib/tmpfile.sh"
  local tmpfile
  create_tmpfile tmpfile
  echo "$gdb_commands" >"$tmpfile"

  gdb -ex "python import sys; sys.path.append('$dotfiles_dir')" -x "$tmpfile" "$@"
}

common_help() {
  cat <<EOF
This script also imports 'gdb_extra' directory in this dotfiles repo to
PYTHONPATH, so you can use anything provided by 'gdb_extra' when you're in the
python interpreter.

You can put gdb commands in a file named as 'gdbinit.post' in current working
directory, it will be loaded when the program stops at the entrypoint.

If a binary cannot be attached or debugged, you may need to disable SIP (System
Integrity Protection) or remove code signature from that binary (see
'xcodeutils unsign'). Visit https://security.stackexchange.com/a/232914 for
more information.

Could not attach to process.  If your uid matches the uid of the target
process, check the setting of /proc/sys/kernel/yama/ptrace_scope, or try
again as the root user.  For more details, see /etc/sysctl.d/10-ptrace.conf
ptrace: Operation not permitted.
EOF
}
