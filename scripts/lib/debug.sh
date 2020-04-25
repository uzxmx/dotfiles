#!/bin/sh

_report_err() {
    echo "Error occurred (LINE $1):"
    if [ -n "$BASH" ]; then
      file="$0"
    else
      file="$ZSH_ARGZERO"
    fi
    echo $ZSH_ARGZERO
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n", NR, (NR==L ? ">>> ":""), $0 }' L=$1 $file
}

trap '_report_err $LINENO' ERR
