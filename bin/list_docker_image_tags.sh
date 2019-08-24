#!/bin/sh
#
# Examples:
#   
#   ./list_docker_image_tags.sh library/debian
#   ./list_docker_image_tags.sh bitnami/phabricator

i=0
while [ $? == 0 ]
do 
   i=$((i+1))
   curl https://registry.hub.docker.com/v2/repositories/$1/tags/?page=$i 2>/dev/null | jq '."results"[]["name"]'
done
