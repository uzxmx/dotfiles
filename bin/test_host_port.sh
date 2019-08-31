#!/usr/bin/env bash
#
# Test connection with 5s timeout
#
# ./test_host_port.sh <host> <port>

nc -z -v -w 5 "$@"
