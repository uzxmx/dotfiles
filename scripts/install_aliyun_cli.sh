#!/usr/bin/env bash
#
# Install aliyun-cli (https://github.com/aliyun/aliyun-cli)

. $(dirname "$0")/utils.sh

version="3.0.38"
path_to_save="/tmp/aliyun-cli-3.0.38.tgz"
if is_mac; then
  url="https://aliyuncli.alicdn.com/aliyun-cli-macosx-$version-amd64.tgz"
else
  url="https://aliyuncli.alicdn.com/aliyun-cli-linux-$version-amd64.tgz"
fi

~/.dotfiles/bin/cget $url $path_to_save
tar zxf $path_to_save -C ~/bin
