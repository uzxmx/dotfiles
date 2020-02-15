#!/usr/bin/env bash
#
# Install python dependencies.

. $(dirname "$0")/utils.sh

if has_yum; then
  echo -n 'Install python dependencies...'
  sudo yum install -y libffi-devel >/dev/null
else
  exit 0
fi

if [[ $? == 0 ]]; then
  echo 'Done'
else
  echo 'Failed'
fi
