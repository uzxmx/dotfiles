#!/bin/sh

for file in $*; do
  sed -i 's/^\(.*\) < ActiveRecord::Base$/\1 < ApplicationRecord/' $file
done
