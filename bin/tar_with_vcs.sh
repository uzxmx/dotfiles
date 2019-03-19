#!/usr/bin/env bash
#
# Examples:
#
#   tar_with_vcs.sh dest.tar.gz folder

tar zcvf "$@" --exclude-vcs --exclude-vcs-ignores
