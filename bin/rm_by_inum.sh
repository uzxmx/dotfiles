#!/usr/bin/env bash
#
# Remove a file by inode number. This script can be used when the filename contains special characters.
# You can use `ls -li` to find the inode of the file.
#
# Examples:
#
#   rm_by_inum.sh 11273502

find . -maxdepth 1 -inum $1  -exec rm -i {} \;
