#!/usr/bin/env bash
#
# Test connection with 5s timeout
#
# ./test_host_port.sh <host> <port>

# Note: some netcat implementation doesn't support `-z` option.
nc -z -v -w 5 "$@"
