#!/usr/bin/env bash
#
# Install python dependencies.

. $(dirname "$0")/utils.sh

if has_yum; then
  echo -n 'Install python dependencies...'
  sudo yum install -y libffi-devel >/dev/null
elif has_apt; then
  echo -n 'Install python dependencies...'
  sudo apt-get install -y libffi-dev zlib1g-dev libssl-dev libreadline-dev >/dev/null
else
  exit 0
fi

if [[ $? == 0 ]]; then
  echo 'Done'
else
  echo 'Failed'
fi
