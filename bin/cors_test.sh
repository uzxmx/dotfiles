#!/bin/sh

if [ $# != 2 ]; then
  echo "Usage: $(basename $0) <url> <origin>"
  echo "e.g. $(basename $0) http://example.com http://foo.example.com"
  exit 1
fi

url=$1
origin=$2

curl "$url" -H "Origin: $origin" -X OPTIONS -I
