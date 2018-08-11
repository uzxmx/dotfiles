#!/usr/bin/env bash
#
# This script will remove the local branches which are tracking remote branches that no longer
# exist on the remote.

git fetch -p \
  && for branch in `LANG=en_US git branch -vv | grep ': gone]' | awk '{print $1}'`; do \
  git branch -D $branch; \
done
