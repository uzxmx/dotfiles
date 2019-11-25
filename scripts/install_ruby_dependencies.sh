#!/usr/bin/env bash
#
# Install ruby dependencies.

. $(dirname "$0")/utils.sh


if has_yum; then
  echo -n 'Install ruby dependencies...'
  sudo yum install -y openssl-devel readline-devel >/dev/null
else
  exit 0
fi

if [[ $? == 0 ]]; then
  echo 'Done'
else
  echo 'Failed'
fi
