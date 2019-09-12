#!/usr/bin/env bash
# 
# Convert multiple lines of pem file to one line.
#
# Example:
#
#   ./squeeze_pem.sh privkey.txt

if [ $# -lt 1 ]; then
  echo "Usage: $0 path_to_pem"
  exit 1
fi

awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $1
