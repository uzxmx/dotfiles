# There is no need for this command to support changing to directories like `/` or `/foo`,
# because it's NOT that annoying to use the original 'cd' for those cases.
dir="$(dirname $(pwd))"
while [ ! "$dir" = "/" ]; do
  if [ -z "$directories" ]; then
    directories="$dir"
  else
    directories="$dir
$directories"
  fi
  dir="$(dirname "$dir")"
done

directories="$(echo "$directories" | sed 1d)"
if [ -z "$directories" ]; then
  echo "You'd better to use this command when the current working directory is too deep."
  exit
fi

main_loop_with_fzf --prompt "(CTRL-Y:yank CTRL-T:edit) Select a parent directory> " --expect="ctrl-t"
