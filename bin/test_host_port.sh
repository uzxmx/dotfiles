#!/usr/bin/env bash
#
# Test connection with 5s timeout
#
# Usage:
#   ./test_host_port.sh <host> <port>
#   ./test_host_port.sh <host> <port> -u # Test UDP connection

# Note: some netcat implementation doesn't support `-z` option.
nc -z -v -w 5 "$@"
