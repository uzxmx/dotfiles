#!/usr/bin/env bash

usage() {
  echo "Usage: $0 [-E <regexp>]" 1>&2
  exit 1
}

while getopts "hE:" opt; do
  case $opt in
    E)
      regexp=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

if [ -n "$regexp" ]; then
  result=`kubectl get pv | grep -E $regexp | awk '{print $1}'`
else
  result=`kubectl get pv | tail -n +2 | awk '{print $1}'`
fi

for id in $result; do
  name=`kubectl get pv $id -o json | jq --raw-output '.spec.claimRef.name'`
  path=`kubectl get pv $id -o json | jq --raw-output '.spec.glusterfs.path'`
  mkdir -p $name
  mount -t glusterfs localhost:/$path $name
  tar zcvf $name.tar.gz $name
done
