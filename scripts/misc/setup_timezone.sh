#!/usr/bin/env bash

if [ -e /etc/localtime ]; then
  ls -l /etc/localtime
fi

sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
