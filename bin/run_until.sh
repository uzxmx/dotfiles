#!/usr/bin/env bash

max=10
termination="success"

usage() {
  cat <<-EOF 1>&2
Run a command until termination condition is met.

Usage: $0 [-e] [-s] [-m MAX COUNT] [-h] [COMMAND] [ARGS ...]

[-e]           Stop when some error occurs
[-s]           Stop when no error occurs
[-m MAX COUNT] Specify max try count, default is $max
[-h]           Show help

Examples:

# Run 'docker build .' until success.
$0 -s docker build .

# Run 'docker build .' until success with max count 20.
$0 -s -m 20 docker build .

# Run benchmark playbook until error occurs with max count 100.
$0 -e -m 100 ansible-playbook -i hosts benchmark.yml
EOF
  exit 1
}

if [[ "$#" == 0 ]]; then
  usage
fi

while getopts "hesm:" opt; do
  case "$opt" in
    e)
      termination="error"
      ;;
    s)
      termination="success"
      ;;
    m)
      max="$OPTARG"
      ;;
    *)
      usage
      ;;
  esac
done

i=0
while (( $i < $max )); do
  echo "========== Current count: $(expr $i + 1) =========="
  ("${@:$OPTIND}")
  ret=$?
  if [[ "$termination" == "success" && $ret == 0 ]]; then
    echo 'success'
    break
  elif [[ "$termination" == "error" && $ret != 0 ]]; then
    echo 'error'
    break
  fi
  i=$(expr $i + 1)
done
