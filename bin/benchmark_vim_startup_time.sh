#!/usr/bin/env bash

subcommand="default-vpm"

while getopts "hf:" opt; do
  case $opt in
    f)
      file=$OPTARG
      ;;
    *)
      ;;
  esac
done

niter=5

if [ "$subcommand" = "default-vpm" ]; then
  for n in $(seq 1 $niter); do
    echo -ne "\rDefault vpm #$n"
    # vim_autoclose_after_started --startuptime /tmp/vim-startuptime.log "\"+set noswapfile\"" $file
    vim_autoclose_after_started --startuptime /tmp/vim-startuptime.log $file
    rm ".$file.swp" 2>/dev/null
    tail -1 /tmp/vim-startuptime.log >> /tmp/vim-default-vpm.log
  done
  echo
  cat /tmp/vim-default-vpm.log | awk '{ sum += $1 } END { printf "Average time is %d", sum / NR }'
  rm /tmp/vim-startuptime.log /tmp/vim-default-vpm.log
fi
