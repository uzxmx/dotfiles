#!/usr/bin/env bash
#
# ./test_host_port.sh <host> <port>

nc -z -v "$@"
