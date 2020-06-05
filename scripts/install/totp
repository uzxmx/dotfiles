#!/usr/bin/env bash
#
# Install totp (https://github.com/arcanericky/totp)

set -e

# TODO `go get` doesn't install totp automatically.
go get github.com/arcanericky/totp
cd ~/go/pkg/mod/github.com/arcanericky
cd $(ls | grep '^totp@' | head -1)
go install totp/totp.go
