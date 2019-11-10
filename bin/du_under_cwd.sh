#!/bin/sh
#
# Calculate the size of each file under the current working directory.
#
# Examples:
#
#   du_under_cwd.sh # Get stats under current working directory
#   du_under_cwd.sh foo # Get stats under foo directory

du -h -d 1 "$@"
