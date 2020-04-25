#!/usr/bin/env bash
#
# Install nauniq (https://metacpan.org/pod/nauniq)

. $(dirname "$0")/utils.sh

if type cpan &>/dev/null; then
  sudo cpan App::nauniq
else
  abort 'Cannot find cpan'
fi