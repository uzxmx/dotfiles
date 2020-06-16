#!/usr/bin/env bash

i=0
while [[ $i -lt 100000 ]]; do
  name=$(shuf -n 1 /usr/share/dict/words)
  gender=$(echo -e "0\n1" | shuf -n 1)
  description=$(shuf -n 1 /usr/share/dict/words)
  echo "insert into pets values ('$name', $gender, '$description');" >>/tmp/test.sql
  i=$((i+1))
done
