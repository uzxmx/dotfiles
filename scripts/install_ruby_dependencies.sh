#!/usr/bin/env bash
#
# Install ruby dependencies.

. $(dirname "$0")/utils.sh

echo -n 'Install ruby dependencies...'

if has_yum; then
  sudo yum install openssl-devel readline-devel
fi

echo 'Done'
