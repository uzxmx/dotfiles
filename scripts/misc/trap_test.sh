#!/usr/bin/env bash

set -e

function handle_int() {
  echo 'handle_int Interrupted'
}
trap handle_int INT

function handle_err() {
  if [ $? -eq 130 ]; then
    echo 'Interrupted'
  else
    echo 'ERR'
  fi
}
trap handle_err ERR

sleep 10
cd /foo
