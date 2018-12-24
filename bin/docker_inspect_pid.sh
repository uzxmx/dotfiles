#!/bin/bash
#
# This script lists process id of each docker container.
# More info see https://stackoverflow.com/questions/31265993/docker-networking-namespace-not-visible-in-ip-netns-list.

header_printed=0
while read line; do
  if [ "$header_printed" -eq "0" ]; then
    echo "CONTAINER_ID CONTAINER_NAME PID"
    header_printed=1
  fi

  id=`echo $line | cut -d ' ' -f 1`
  pid=`docker inspect --format '{{.State.Pid}}' $id`

  echo "$line $pid"
done < <(docker ps | awk '{print $1,$NF}' | tail -n +2) | column -t -s ' '
