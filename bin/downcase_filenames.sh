#!/bin/sh

while true; do
    read -p "Are you sure you want to change all file names to downcase in current directory? (yes/no)" yn
    case $yn in
        yes ) rename 'y/A-Z/a-z/' *; break;;
        no ) exit;;
    esac
done
