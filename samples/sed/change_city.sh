#!/bin/sh

for file in $*; do
  sed -i 's/^\(.*\)city:\(.*\)$/\1district:\2/' $file
  sed -i '/district_id:/d' $file
  sed -i 's/^\(.*\)province:\(.*\)$/\1province:\2\n\1city:\2/' $file
done
